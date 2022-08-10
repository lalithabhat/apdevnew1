public class AP_BHStoreManagementService {
    public virtual class CustomException extends Exception {}
    public static void convertParent(List<Lead> leads){
        Lead lead = leads[0];
        system.debug('In convert paent '+lead.ConvertedOpportunityId +' Acc id '+ lead.ConvertedOpportunity.AccountId);
        List<Lead> otherChildLeads = [Select Id from Lead where BH_Store_Lead__c =: lead.BH_Store_Lead__c AND ID !=: lead.Id];
        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('BH_Store').getRecordTypeId();
        //List<Account> accList = new List<Account>();
        ///accList = convertlead.getDupAccountList(lead);
        //system.debug('accList: '+accList);
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(lead.BH_Store_Lead__c);
        lc.setAccountId(lead.ConvertedOpportunity.AccountId);
        lc.setContactId(lead.ConvertedOpportunity.Account.PersonContactId);
        /*  if(!accList.isEmpty() && accList.size() > 0) {
lc.setAccountId(accList[0].Id);
lc.setContactId(accList[0].PersonContactId);
}*/
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.LeadConvertResult lcr = Database.convertLead(lc, dml);
        system.debug(lcr);
        system.debug('Lead conver error:'+lcr.getErrors());
        if(lcr.isSuccess()){
            Opportunity o = new Opportunity();
            o.Id = lcr.getOpportunityId();
            o.RecordtypeId = recordTypeId;
            update o;
            Opportunity original = new Opportunity();
            original.id = lead.ConvertedOpportunityId;
            original.BH_Store_Opportunity__c = o.Id;
            update original;
            for(Lead l :otherChildLeads){
                l.BH_Store_Lead__c = null;
                l.BH_Store_Opportunity__c =o.Id;
            }
            update otherChildLeads;
        }
        //  throw new CustomException('test');
        
    }
    //-----------------added by Saransh----------------------------------------------------//
    public static void changestatus(List<Lead> leadList){
        for(Lead l:leadlist){
            l.Status='Allocation Done';
            
        }
    }
    public static void allocatedealer(List<Lead> leadList,Set<string> pincodeset){
        Map<String,Id> dealerMap = new Map<string,Id>();
        
        for(SA_Pincode_Mapping__c pinMap : [SELECT Pincode__c,Service_Master__r.Service__c, SA__r.Account.Name, SA__r.Account.Id  
                                            FROM SA_Pincode_Mapping__c 
                                            WHERE Pincode__c IN:pincodeset
                                            AND Service_Master__r.Service__c ='BH_Store']){
                                                dealerMap.put(pinMap.Pincode__c, pinMap.SA__r.Account.Id);
                                            }
        // system.debug('dealer map:'+dealerMap);
        for(Lead l:leadlist){
            if(l.Pincode__c!=null && dealerMap.containskey(l.Pincode__c)){
                l.Dealer__c=dealermap.get(l.Pincode__c);
            }
            
        }
    }
    //-----------------------------new bh store parent added by Saransh--------------------------------------------------------//
    public static void createBhStoreParentLead(Map<Id,Id> bhstoreleadmap,List<Lead> childleadlist){
        Lead newparentlead;
        Map<Id,Id> newparentleadmap= new Map<Id,Id>();
        Map<Id,Id> tagparentleadmap= new Map<Id,Id>();
        List<Lead> existingparentbhstore=new List<Lead>();
        List<Lead> newparentbhstore=new List<Lead>();
        if(!bhstoreleadmap.isempty()){
            existingparentbhstore=[SELECT Id,FirstName,LastName,Status,Pincode__c, LeadSource,Source_of_Awarness_SOA_New__c, MobilePhone, Email, Street,CampaignName__c,RecordTypeId from Lead where ID IN:bhstoreleadmap.values()];
            
        }    
        for(Lead parentlead:existingparentbhstore){
            newparentlead=parentlead.clone(false,false,false,false);
            newparentlead.Child_Lead_Id__c=parentlead.Id;
            newparentlead.Is_Allow_Duplicates__c=true;
            newparentbhstore.add(newparentlead);
        }
        if(newparentbhstore!=null){
            insert newparentbhstore;
            for(Lead l:newparentbhstore){
                newparentleadmap.put(l.Child_Lead_Id__c,l.Id);
            }
        }
        if(!bhstoreleadmap.isempty())
        {
            for(Id key:bhstoreleadmap.keySet()){
                if(!newparentleadmap.isempty() && newparentleadmap.containskey(bhstoreleadmap.get(key))  ){
                    tagparentleadmap.put(key,newparentleadmap.get(bhstoreleadmap.get(key)));
                }
                
            }
        }        if(childleadlist!=null){
            for(Lead l:childleadlist){
                if(!tagparentleadmap.isempty() && tagparentleadmap.containskey(l.Id)){
                    l.BH_Store_Lead__c=tagparentleadmap.get(l.Id);
                    l.Is_Child_Lead__c=true;
                }
            }
        }
    }
    //-----------method to check if a store serves particular skillset or not added by Saransh--------------------------//
    public static Boolean isSkillSetAvailable(string pincode,Set<String> skillset){
        List<SA_Pincode_Mapping__c> pincodecoveragelist=new  List<SA_Pincode_Mapping__c>();   
        
        pincodecoveragelist=[SELECT Id,Pincode__c,Dealer__c,Skills__c,SA__r.Account.Id from SA_Pincode_Mapping__c WHERE Pincode__c=:pincode AND Skills__c IN:skillset];
        
        if(!pincodecoveragelist.isempty()){
            return true;
        }
        else{
            return false;
        }
    }
    //-------------------------------------------------------------------------------------------------------------------------------------------------// 
    @AuraEnabled public List<bhstorewrapper> bhstorestlist {get;set;}
     public class bhstoreWrapper{
       @AuraEnabled public string  storeid {get;set;}
       @AuraEnabled public string  storename {get;set;}
       @AuraEnabled public string weightage{get;set;}
       @AuraEnabled public Set<string> items{get;set;}
    }
    @AuraEnabled
    public static List<bhstoreWrapper> getStore(string leadId){
        Set<String> skillset=new Set<string>();
        List<bhstorewrapper> itemslist=new List<bhstorewrapper>();
        Lead bhstorelead=[SELECT Id,Name,Pincode__c,Product_Categories__c from LEAD where ID=:leadId];
        if(bhstorelead!=null){
            
            if(bhstorelead.Product_Categories__c!=null && bhstorelead.Pincode__c!=null){
               skillset.addall(bhstorelead.Product_Categories__c.split(';'));  
                system.debug('Skillset '+skillset);
                
                itemslist= AP_BHStoreManagementService.getAllStoreBySkillSet(bhstorelead.Pincode__c, skillset);
                system.debug('itemlist '+itemslist);
             
            }

        }
   return itemslist; 
    }
    
    public static List<bhstoreWrapper> getAllStoreBySkillSet(string pincode,Set<String> skillset){
        
        List<skillset__mdt> skills=[SELECT QualifiedApiName,Weightage__c from skillset__mdt];
        Map<String,Double> skillmdtmap=new Map<String,Double>();
        if(!skills.isempty()){
            for (skillset__mdt s:skills){
                skillmdtmap.put(s.QualifiedApiName,s.Weightage__c/100);
            }
        }
        
        List<SA_Pincode_Mapping__c> pincodecoveragelist=new  List<SA_Pincode_Mapping__c>();
        Map<Id,Set<String>> itemsmap=new Map<Id,Set<String>>();
        Map<Id,Double> dealerskillmap=new Map<Id,Double>();     
        Map<Id,Double> weightagemap=new Map<Id,Double>();
        Map<Id,String> dealermap=new Map<Id,String>();
        
        pincodecoveragelist=[SELECT Id,Pincode__c,Dealer__c,Skills__c,SA__r.Account.Id,SA__r.Account.Name,Role__c from SA_Pincode_Mapping__c WHERE Pincode__c=:pincode AND Skills__c IN:skillset AND Role__c='DA' order by SA__r.Account.Id desc];
        system.debug(pincodecoveragelist);
        
        if(!pincodecoveragelist.isempty()){
            for (SA_Pincode_Mapping__c pcm:pincodecoveragelist){
                if(pcm.SA__r.Account.Id!=null && pcm.Skills__c!=null){
                    
                    dealermap.put(pcm.SA__r.Account.Id,pcm.SA__r.Account.Name);
                    
                    if(dealerskillmap.size()>0  && dealerskillmap.containskey(pcm.SA__r.Account.Id)  ){
                        dealerskillmap.put(pcm.SA__r.Account.Id,skillmdtmap.get(pcm.Skills__c)+dealerskillmap.get(pcm.SA__r.Account.Id));   
                    }
                    else{
                        dealerskillmap.put(pcm.SA__r.Account.Id,skillmdtmap.get(pcm.Skills__c));
                    }
                    if(itemsmap.size()>0  && itemsmap.containskey(pcm.SA__r.Account.Id)){
                        Set<String> itemset1=new Set<String>(itemsmap.get(pcm.SA__r.Account.Id));
                        itemset1.add(pcm.Skills__c);
                        itemsmap.put(pcm.SA__r.Account.Id,itemset1);    
                    }
                    else{
                        Set<String> itemset=new Set<String>();
                        itemset.add(pcm.Skills__c);
                        itemsmap.put(pcm.SA__r.Account.Id,itemset);
                    } 
                    system.debug(pcm.Sa__r.Account.Id+' '+pcm.Dealer__c+' '+pcm.Pincode__c+' '+pcm.Skills__c);
                }    
            }
            system.debug('Dealer skill map'+dealerskillmap);
            system.debug('Items map'+itemsmap); 
            system.debug('dealer map'+dealermap); 
        }
        
        List<bhstorewrapper> itemslist=new List<bhstorewrapper>();
        if(dealerskillmap.size()>0 && !dealerskillmap.isempty() && !itemsmap.isempty() && !dealermap.isempty()){
            for(Id storeid:dealerskillmap.keyset()){
                bhstorewrapper bhwrap= new bhstorewrapper();
                bhwrap.storeid=storeid;
                bhwrap.storename=dealermap.get(storeid);
                bhwrap.weightage=Integer.valueof(dealerskillmap.get(storeid)*100)+'%';
                bhwrap.items=itemsmap.get(storeid);
                itemslist.add(bhwrap);
            }
        }
        if(itemslist!=null){
            system.debug('allstoreitemlist'+itemslist);
            return itemslist; 
        }
        else{
            return null;
        }   
    }
    //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
    public static List<bhstoreWrapper> getTopStoreBySkillSet(string pincode,Set<String> skillset){
	
          List<skillset__mdt> skills=[SELECT QualifiedApiName,Weightage__c from skillset__mdt];
        Map<String,Double> skillmdtmap=new Map<String,Double>();
        if(!skills.isempty()){
            for (skillset__mdt s:skills){
                skillmdtmap.put(s.QualifiedApiName,s.Weightage__c/100);
            }
        }
        
        List<SA_Pincode_Mapping__c> pincodecoveragelist=new  List<SA_Pincode_Mapping__c>();
        Map<Id,Set<String>> itemsmap=new Map<Id,Set<String>>();
        Map<Id,Double> dealerskillmap=new Map<Id,Double>();
        Map<Id,Double> topdealerskillmap=new Map<Id,Double>(); 
        Map<Id,Double> weightagemap=new Map<Id,Double>();   
        
        pincodecoveragelist=[SELECT Id,Pincode__c,Dealer__c,Skills__c,SA__r.Account.Id,Role__c from SA_Pincode_Mapping__c WHERE Pincode__c=:pincode AND Skills__c IN:skillset AND Role__c='DA' order by SA__r.Account.Id desc];
        system.debug(pincodecoveragelist);
        
        if(!pincodecoveragelist.isempty()){
            for (SA_Pincode_Mapping__c pcm:pincodecoveragelist){
                if(pcm.SA__r.Account.Id!=null && pcm.Skills__c!=null){
                    
                    if(dealerskillmap.size()>0  && dealerskillmap.containskey(pcm.SA__r.Account.Id)  ){
                        dealerskillmap.put(pcm.SA__r.Account.Id,skillmdtmap.get(pcm.Skills__c)+dealerskillmap.get(pcm.SA__r.Account.Id));   
                    }
                    else{
                        dealerskillmap.put(pcm.SA__r.Account.Id,skillmdtmap.get(pcm.Skills__c));
                    }
                    if(itemsmap.size()>0  && itemsmap.containskey(pcm.SA__r.Account.Id)){
                        Set<String> itemset1=new Set<String>(itemsmap.get(pcm.SA__r.Account.Id));
                        itemset1.add(pcm.Skills__c);
                        itemsmap.put(pcm.SA__r.Account.Id,itemset1);    
                    }
                    else{
                        Set<String> itemset=new Set<String>();
                        itemset.add(pcm.Skills__c);
                        itemsmap.put(pcm.SA__r.Account.Id,itemset);
                    } 
                    system.debug(pcm.Sa__r.Account.Id+' '+pcm.Dealer__c+' '+pcm.Pincode__c+' '+pcm.Skills__c);
                }    
            }
            system.debug('Dealer skill map'+dealerskillmap);
            system.debug('Items map'+itemsmap); 
            if(!dealerskillmap.isempty()){
                List<Double> skillList=dealerskillmap.values();
                skillList.sort();
                Double topweightage=skillList[skillList.size()-1];
                for(Id storeid:dealerskillmap.keyset()){
                    if(dealerskillmap.get(storeid)==topweightage){
                        topdealerskillmap.put(storeid,dealerskillmap.get(storeid));
                        break;
                    }
                }
            }
        } 
            List<bhstorewrapper> itemslist=new List<bhstorewrapper>();
        if(topdealerskillmap.size()>0 && !topdealerskillmap.isempty() && !itemsmap.isempty()){
            for(Id storeid:topdealerskillmap.keyset()){
                bhstorewrapper bhwrap= new bhstorewrapper();
                bhwrap.storeid=storeid;
                bhwrap.weightage=(topdealerskillmap.get(storeid)*100)+'%';
                bhwrap.items=itemsmap.get(storeid);
                itemslist.add(bhwrap);
            }
        }
        if(itemslist!=null){
            system.debug('topstoreitemlist'+itemslist);
            return itemslist; 
        }
        else{
            return null;
        }  
    }
    //--------------------------------------------------------------------------------------------------------------------//
}