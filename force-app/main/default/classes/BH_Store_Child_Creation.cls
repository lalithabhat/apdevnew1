public without sharing class BH_Store_Child_Creation {
    public virtual class CustomException extends Exception{}
    @AuraEnabled
    public static Lead getOriginalLead(String recordId){
        return [Select Status,Pincode__c, LeadSource,Source_of_Awarness_SOA_New__c, MobilePhone, Email, Street,CampaignName__c from Lead where ID =: recordId];
    }
    @AuraEnabled(cacheable=true)
    public static List<leadOptions> getleadOptions(String recordId){
        String spsValidationMsg = '<p><span style="color: rgb(255, 0, 0);">SPS Lead has been disabled as one of the following mandatory fields are missing. Please edit the lead and update the values to enable SPS Lead.</span></p><p><br></p><ul><li>Pincode</li><li>Lead source </li><li>Source of Awareness</li><li>Mobile </li><li>Campaign </li></ul>';
        String bhsValidationMsg = '<p><span style="color: rgb(255, 0, 0);">BHS Lead has been disabled as one of the following mandatory fields are missing. Please edit the lead and update the values to enable BHS Lead.</span></p><p><br></p><ul><li>Pincode</li><li>Lead source </li><li>Source of Awareness</li><li>Email</li><li>Mobile </li><li>Campaign </li><li>Street (should be less than 255 characters)</li></ul>';
        Map<String,leadOptions> buMap = new Map<String, leadOptions>();
        Lead ol = getOriginalLead(recordId);
        Boolean isValidSPS = true;
        Boolean isValidBHS = true;
        if(ol.Pincode__c == null ||  ol.LeadSource == null || ol.Source_of_Awarness_SOA_New__c == null || ol.MobilePhone ==null || ol.CampaignName__c ==null)
            isValidSPS =false;
        
        if(ol.Pincode__c == null ||  ol.LeadSource == null || ol.Source_of_Awarness_SOA_New__c == null || ol.MobilePhone ==null || ol.CampaignName__c ==null || ol.email == null || ol.Street == null || ol.Street.length()> 255)
            isValidBHS =false;
        
        buMap.put('SPS',new leadOptions('SPS','SPS',isValidSPS,spsValidationMsg));
        buMap.put('BHS',new leadOptions('BHS','BHS',isValidBHS,bhsValidationMsg));
        buMap.put('SLEEK',new leadOptions('SLEEK','SLEEK'));
        buMap.put('BH_Store_Product_Sales',new leadOptions('BH Store Product Sales','BH_Store_Product_Sales'));
        
        // To remove a lead option if its already created
/*for(Lead l :  [Select Id, recordType.DeveloperName from Lead where BH_Store_Lead__c = : recordid]){
if( buMap.containsKey(l.recordType.DeveloperName)){
buMap.get(l.recordType.DeveloperName).available =false;
}
}*/
        
        List<leadOptions> options  = new List<leadOptions>();
        
        for(leadOptions lo : buMap.values()){
            if(lo.available)
                options.add(lo);
        }
        system.debug(options);
        return options;
        //sps, bhs, sleek, product sales
    }
    @AuraEnabled
    public static void insertLeads(List<String> buList, string recordId){
        Lead lead =[SELECT ID, FirstName, LastName, Pincode__c, Dealer__c, MobilePhone, Email,
                    House__c, Floor__c, Pincode_Lookup__c,
                    CampaignName__c,LeadSource,Source_of_Awarness_SOA_New__c, Street FROM Lead WHERE ID =: recordId][0];
        
        if(lead.Dealer__c == null){
            Map<Id,String> dealerMap = DealerOnLeadHandler.getDealer(recordId);
            
            if(dealerMap.size() >0)
            { 
                for(Id  i: dealerMap.keySet()){
                    lead.Dealer__c = i;
                    break;
                }
                List<SA_Pincode_Mapping__c> daContact = [SELECT  SA__r.Employee_Code__c FROM SA_Pincode_Mapping__c WHERE Pincode__c =: lead.Pincode__c
                                                         AND Service_Master__r.Service__c =: 'BH_Store' ];
                if(!daContact.isEmpty()){
                    List<User> daUser =    [Select Id from User Where Employee_Number__c =: daContact[0].SA__r.Employee_Code__c AND Employee_Number__c !=null];
                    if(!daUser.isEmpty()) lead.OwnerId = daUser[0].Id;
                }
                lead.status = 'Allocation Done';
                update lead;
                
            }
            else throw new CustomException ('No Dealer found for this pincode');
        }
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        dml.optAllOrNone = true;
        List<Lead> leadsToInsert= new List<Lead>();
        for(String bu : buList){
            system.debug('bu '+bu);
            Lead l =  lead.clone(false, false, false, false);
            l.RecordTypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(bu).getRecordTypeId();
            l.BH_Store_Lead__c = recordId;
            l.Status = 'Allocation Done';
            l.Is_Child_Lead__c = true;
            //l.ownerId = '';
            leadsToInsert.add(l);
        }
        List<Database.SaveResult> sr = Database.insert(leadsToInsert,dml);
    }
    
    public  class leadOptions {
        @AuraEnabled public string BU {get;set;}
        @AuraEnabled public string BU_API {get;set;}
        @AuraEnabled public string leadId {get;set;}
        @AuraEnabled public string validationMsg {get;set;}
        @AuraEnabled public boolean isValid {get;set;}
        @AuraEnabled public boolean available {get;set;}
        public leadOptions(String BU, String BU_API){
            this.BU = BU;
            this.BU_API = BU_API;
            this.isValid = true;
            this.available = true;
            
        }
        public leadOptions(String BU, String BU_API,Boolean isValid, String validationMsg){
            this.BU = BU;
            this.BU_API = BU_API;
            this.validationMsg =validationMsg;
            this.isValid = isValid;
            this.available = true;
            
        }
        
    }
}