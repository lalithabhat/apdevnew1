/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 26-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and filter all the Lead based on the trigger actions.
*********************************************************************************************************/
public class AP_LeadTriggerHandler {
    public static void onBeforeInsert(List<Lead> leadList) {
        List<Lead> preCheckLeadList = new List<Lead>();
        //-------------------------------------new additions by Saransh---------------------------------------//
        Id spsrecId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();//new addition
        List<Lead> dedupeCheckLeadList = new List<Lead>();
        Id bhStoreRecId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BH Store').getRecordTypeId();//new addition 
        List<Lead> bhStoreLeadList = new List<Lead>();//new addition
        List<Lead> bhsLeadList =new List<Lead>();
        Set<String> bhsphone = new Set<String>();
        Set<String> bhsemail = new Set<String>();
        Set<String> spsphone = new Set<String>();
        Set<String> spsemail = new Set<String>();
        Set<String> spsunderbhstorephone = new Set<String>();
        Set<String> spsunderbhstoreemail = new Set<String>();
        Id bhsRecId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();//new addition 
        set<String> pincodeset=new Set<String>();
        Id sleekRecId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SLEEK').getRecordTypeId();//new addition 
        Id productsalesRecId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BH Store Product Sales').getRecordTypeId();//new addition 
        Set<String> sleekphone = new Set<String>();
        Set<String> sleekemail = new Set<String>();
        Set<String> productsalesphone = new Set<String>();
        Set<String> productsalesemail = new Set<String>();
        Map<Id,Id> bhstoreparentmap=new Map<Id,Id>();
        List<Lead> SpsChildLeadList=new List<Lead>();
        List<Lead> SleekChildLeadList=new List<Lead>();
        List<Lead> ProductSalesChildLeadList=new List<Lead>();   
        List<Lead> localLeadList = new List<Lead>();
        Set<Id> ownerId = new Set<Id>();
        List<Lead> SpsChildUnderBhStoreCA=new List<Lead>();
        List<Lead> SpsChildUnderBhStoreDA=new List<Lead>();   
        //-------------------------------------------------------------------------------------//
        
        
        for(Lead l: leadList) {
            //-------------------------new Additions by Saransh----------------------------------------------------------//          
            if(l.RecordTypeId==bhStoreRecId && l.Click_To_Action__c=='Visit' && l.Dealer__c==Null){
                bhStoreLeadList.add(l);
                pincodeset.add(l.Pincode__c);
            }
                
            if(l.MobilePhone!=null && l.RecordTypeId==spsRecId && l.BH_Store_Lead__c!=null){
                spsunderbhstorephone.add(l.MobilePhone);
            }
            if(l.Email!=null &&  l.RecordTypeId==spsRecId && l.BH_Store_Lead__c!=null){
                spsunderbhstoreemail.add(l.Email);
            }
            if(l.MobilePhone!=null && l.RecordTypeId==bhsRecId){
                bhsphone.add(l.MobilePhone);
            }
            if(l.Email!=null &&  l.RecordTypeId==bhsRecId){
                bhsemail.add(l.Email);
            }
            if(l.MobilePhone!=null && l.RecordTypeId==spsRecId){
                spsphone.add(l.MobilePhone);
            }
            if(l.Email!=null &&  l.RecordTypeId==spsRecId){
                spsemail.add(l.Email);
            }
            if(l.MobilePhone!=null && l.RecordTypeId==sleekRecId){
                sleekphone.add(l.MobilePhone);
            }
            if(l.Email!=null &&  l.RecordTypeId==sleekRecId){
                sleekemail.add(l.Email);
            }
            if(l.MobilePhone!=null && l.RecordTypeId==productsalesRecId){
                productsalesphone.add(l.MobilePhone);
            }
            if(l.Email!=null &&  l.RecordTypeId==productsalesRecId){
                productsalesemail.add(l.Email);
            }   
            //------------------------------------------------------------------------------------//    
                 
            if(l.OwnerId != null) { //&& !l.Legacy_Upload__c
                ownerId.add(l.OwnerId);
                localLeadList.add(l);
            }
            if(!l.Is_Digital__c && !l.Is_Allow_Duplicates__c && !l.Is_Bot__c && !l.Legacy_Upload__c)
                preCheckLeadList.add(l);    
        }
        //-----------------------------new dedupe addition  by Saransh--------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
        Map<String,Id> bhsleadphonemap=new Map<String,Id>();
        Map<String,Id> bhsleademailmap=new Map<String,Id>();
        Map<String,Id> spsleadphonemap=new Map<String,Id>();
        Map<String,Id> spsleademailmap=new Map<String,Id>();
        Map<String,Id> spsleadphonemap1=new Map<String,Id>();
        Map<String,Id> spsleademailmap1=new Map<String,Id>();
        Map<String,Id> spsleadphonemap2=new Map<String,Id>();
        Map<String,Id> spsleademailmap2=new Map<String,Id>();
        Map<String,Id> sleekleadphonemap=new Map<String,Id>();
        Map<String,Id> sleekleademailmap=new Map<String,Id>();
        Map<String,Id> productsalesleadphonemap=new Map<String,Id>();
        Map<String,Id> productsalesleademailmap=new Map<String,Id>();
        
        Set<Id> bhstoreCAIdset=new Set<ID>();
        Set<Id> bhstoreDAIdset=new Set<ID>();
        Set<Id> CAIdset=new Set<Id>();
        
        List<User> bhstoreCAlist=[SELECT Id,Name,Store_CA__c from User WHERE Store_CA__c=true AND Id IN:OwnerId ];
        if(bhstoreCAlist!=null){
            for(User u:bhstoreCAlist){
                bhstoreCAIdset.add(u.Id);
            }  
        }
        
        List<User> CAlist=[SELECT Id,Name,CA__c from User WHERE CA__c=true AND Id IN:OwnerId];
        if(CAlist!=null){
            for(User u:CAlist){
                CAIdset.add(u.Id);
            }  
        }
        List<User> bhstoreDAlist=[SELECT Id,Name,Store_DA__c from User WHERE Store_DA__c=true AND Id IN:OwnerId ];
        if(bhstoreDAlist!=null){
            for(User u:bhstoreDAlist){
                bhstoreDAIdset.add(u.Id);
            }  
        }
        
        List<Lead> existingSpsPhoneList2=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c FROM Lead WHERE MobilePhone IN:spsunderbhstorephone AND Status='New' AND Is_Local__c=False  ];
        List<Lead> existingSpsEmailList2=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c FROM Lead WHERE Email IN:spsunderbhstoreemail AND Status='New' AND Is_Local__c=False];
        if(!existingSpsPhoneList2.isEmpty() && existingSpsPhoneList2!=null ){
            for(Lead spsl:existingSpsPhoneList2){
                spsleadphonemap2.put(spsl.MobilePhone,spsl.BH_Store_Lead__c); } 
        }
        if(!existingSpsEmailList2.isEmpty() && existingSpsEmailList2!=null ){
            for(Lead spsl:existingSpsEmailList2){
                spsleademailmap2.put(spsl.Email,spsl.BH_Store_Lead__c); } 
        }
        
        List<Lead> existingBhsPhoneList=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c FROM Lead WHERE MobilePhone IN:bhsphone AND Status='Allocation Done' AND BH_Store_Lead__r.Status='Allocation Done'];
        List<Lead> existingBhsEmailList=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c FROM Lead WHERE Email IN:bhsemail AND Status='Allocation Done' AND BH_Store_Lead__r.Status='Allocation Done'];
        if(!existingBhsPhoneList.isEmpty() && existingBhsPhoneList!=null ){
            for(Lead bhsl:existingBhsPhoneList){
                bhsleadphonemap.put(bhsl.MobilePhone,bhsl.BH_Store_Lead__c); } 
        }
        if(!existingBhsEmailList.isEmpty() && existingBhsEmailList!=null ){
            for(Lead bhsl:existingBhsEmailList){
                bhsleademailmap.put(bhsl.Email,bhsl.BH_Store_Lead__c); } 
        }
        List<Lead> existingSpsPhoneList=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c FROM Lead WHERE MobilePhone IN:spsphone AND Status='Allocation Done' AND BH_Store_Lead__r.Status='Allocation Done' ];
        List<Lead> existingSpsEmailList=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c FROM Lead WHERE Email IN:spsemail AND Status='Allocation Done' AND BH_Store_Lead__r.Status='Allocation Done' ];
        if(!existingSpsPhoneList.isEmpty() && existingSpsPhoneList!=null ){
            for(Lead spsl:existingSpsPhoneList){
                spsleadphonemap.put(spsl.MobilePhone,spsl.BH_Store_Lead__c); } 
        }
        if(!existingSpsEmailList.isEmpty() && existingSpsEmailList!=null ){
            for(Lead spsl:existingSpsEmailList){
                spsleademailmap.put(spsl.Email,spsl.BH_Store_Lead__c); } 
        }
        List<Lead> existingSpsPhoneList1=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c,Status FROM Lead WHERE MobilePhone IN:spsphone AND BH_Store_Lead__r.Status='New' AND Status='New' ];
        List<Lead> existingSpsEmailList1=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c,Status FROM Lead WHERE Email IN:spsemail AND BH_Store_Lead__r.Status='New' AND Status='New'];
        if(!existingSpsPhoneList1.isEmpty() && existingSpsPhoneList1!=null ){
            for(Lead spsl:existingSpsPhoneList1){
                spsleadphonemap1.put(spsl.MobilePhone,spsl.BH_Store_Lead__c); } 
        }
        if(!existingSpsEmailList1.isEmpty() && existingSpsEmailList1!=null ){
            for(Lead spsl:existingSpsEmailList1){
                spsleademailmap1.put(spsl.Email,spsl.BH_Store_Lead__c); } 
        }
        
        List<Lead> existingSleekPhoneList=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c,Status FROM Lead WHERE MobilePhone IN:sleekphone AND BH_Store_Lead__r.Status='New' AND Status='New'];
        List<Lead> existingSleekEmailList=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c,Status FROM Lead WHERE Email IN:sleekemail AND BH_Store_Lead__r.Status='New' AND Status='New'];
        if(!existingSleekPhoneList.isEmpty() && existingSleekPhoneList!=null ){
            for(Lead sleekl:existingSleekPhoneList){
                sleekleadphonemap.put(sleekl.MobilePhone,sleekl.BH_Store_Lead__c); } 
        }
        if(!existingSleekEmailList.isEmpty() && existingSleekEmailList!=null ){
            for(Lead sleekl:existingSleekEmailList){
                sleekleademailmap.put(sleekl.Email,sleekl.BH_Store_Lead__c); } 
        }
        
        List<Lead> existingproductsalesPhoneList=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c,Status FROM Lead WHERE MobilePhone IN:productsalesphone AND BH_Store_Lead__r.Status='New'AND Status='New' ];
        List<Lead> existingproductsalesEmailList=[SELECT Id,Name,MobilePhone,Email,BH_Store_Lead__c,Status FROM Lead WHERE Email IN:productsalesemail AND BH_Store_Lead__r.Status='New' AND Status='New'];
        if(!existingproductsalesPhoneList.isEmpty() && existingproductsalesPhoneList!=null ){
            for(Lead productsalesl:existingproductsalesPhoneList){
                productsalesleadphonemap.put(productsalesl.MobilePhone,productsalesl.BH_Store_Lead__c); } 
        }
        if(!existingproductsalesEmailList.isEmpty() && existingproductsalesEmailList!=null ){
            for(Lead productsalesl:existingproductsalesEmailList){
                productsalesleademailmap.put(productsalesl.Email,productsalesl.BH_Store_Lead__c); } 
        }
        
        for(Lead l: leadList){
            system.debug(' Mail and owner profile'+l.Email+l.Owner.Profile.Name);
            if(!existingSpsPhoneList2.isempty() && l.RecordTypeId==spsRecId && l.BH_Store_Lead__c!=null && bhstoreCAIdset.contains(l.OwnerId)){         
                bhstoreparentmap.put(l.Id,l.BH_Store_Lead__c);
                SpsChildUnderBhStoreCA.add(l);
            }
            else if( !existingSpsEmailList2.isempty() && l.RecordTypeId==spsRecId && l.BH_Store_Lead__c!=null && bhstoreCAIdset.contains(l.OwnerId)){
                bhstoreparentmap.put(l.Id,l.BH_Store_Lead__c);
                SpsChildUnderBhStoreCA.add(l);
            }
            else if(!existingSpsPhoneList2.isempty() && l.RecordTypeId==spsRecId && l.BH_Store_Lead__c!=null && bhstoreDAIdset.contains(l.OwnerId)){         
                bhstoreparentmap.put(l.Id,l.BH_Store_Lead__c);
                SpsChildUnderBhStoreDA.add(l);
            }
            else if( !existingSpsEmailList2.isempty() && l.RecordTypeId==spsRecId && l.BH_Store_Lead__c!=null && bhstoreDAIdset.contains(l.OwnerId)){
                bhstoreparentmap.put(l.Id,l.BH_Store_Lead__c);
                SpsChildUnderBhStoreDA.add(l);
            }
            else if(!bhsleadphonemap.isempty()&& l.RecordTypeId==bhsRecId && bhsleadphonemap.containskey(l.MobilePhone) ){
                l.BH_Store_Lead__c=bhsleadphonemap.get(l.MobilePhone);
                l.Is_Child_Lead__c=true;
            } 
            else if( !bhsleademailmap.isempty() && l.RecordTypeId==bhsRecId && bhsleademailmap.containskey(l.Email)){
                l.BH_Store_Lead__c=bhsleademailmap.get(l.Email);
                l.Is_Child_Lead__c=true;
            }
            
            else if(!existingSpsPhoneList.isempty() && l.RecordTypeId==spsRecId && spsleadphonemap.containskey(l.MobilePhone) && bhstoreCAIdset.contains(l.OwnerId)){         
                l.BH_Store_Lead__c=spsleadphonemap.get(l.MobilePhone);
                l.Is_Child_Lead__c=true;
            }
            else if( !existingSpsEmailList.isempty() && l.RecordTypeId==spsRecId && spsleademailmap.containskey(l.Email) && bhstoreCAIdset.contains(l.OwnerId)){
                l.BH_Store_Lead__c=spsleademailmap.get(l.Email);
                l.Is_Child_Lead__c=true;
            }
            else if((!existingSpsPhoneList.isempty() || !existingSpsEmailList.isempty())&& l.RecordTypeId==spsRecId &&( spsleadphonemap.containskey(l.MobilePhone) || spsleadphonemap.containskey(l.Email) ) && CAIdset.contains(l.OwnerId) && l.Is_Local__c==True){         
                
            }
            else if((!existingSpsPhoneList.isempty() || !existingSpsEmailList.isempty())&& l.RecordTypeId==spsRecId && (spsleadphonemap.containskey(l.MobilePhone) || spsleademailmap.containskey(l.Email) )&& l.Is_Local__c==False){
                
            }
            else if(!existingSpsPhoneList1.isempty() && l.RecordTypeId==spsRecId && spsleadphonemap1.containskey(l.MobilePhone) &&  bhstoreDAIdset.contains(l.OwnerId)){         
                bhstoreparentmap.put(l.Id,spsleadphonemap1.get(l.MobilePhone));
                SpsChildLeadList.add(l);            
            }
            else if(!existingSpsEmailList1.isempty() && l.RecordTypeId==spsRecId && spsleademailmap1.containskey(l.Email) && bhstoreDAIdset.contains(l.OwnerId)){
                bhstoreparentmap.put(l.Id,spsleademailmap1.get(l.Email));
                SpsChildLeadList.add(l);         
            }
            else if(!existingSleekPhoneList.isempty() && l.RecordTypeId==sleekRecId && sleekleadphonemap.containskey(l.MobilePhone) && bhstoreDAIdset.contains(l.OwnerId)){         
                bhstoreparentmap.put(l.Id,sleekleadphonemap.get(l.MobilePhone));
                SleekChildLeadList.add(l);
            }
            
            else if(!existingSleekEmailList.isempty() && l.RecordTypeId==sleekRecId && sleekleademailmap.containskey(l.Email) && bhstoreDAIdset.contains(l.OwnerId)){
                bhstoreparentmap.put(l.Id,sleekleademailmap.get(l.Email));
                SleekChildLeadList.add(l);
            }
            else if(!existingproductsalesPhoneList.isempty() && l.RecordTypeId==productsalesRecId && productsalesleadphonemap.containskey(l.MobilePhone) && bhstoreDAIdset.contains(l.OwnerId)){         
                bhstoreparentmap.put(l.Id,productsalesleadphonemap.get(l.MobilePhone));
                ProductSalesChildLeadList.add(l);
            }
            else if(!existingproductsalesEmailList.isempty() && l.RecordTypeId==productsalesRecId && productsalesleademailmap.containskey(l.Email) && bhstoreDAIdset.contains(l.OwnerId)){
                bhstoreparentmap.put(l.Id,productsalesleademailmap.get(l.Email));
                ProductSalesChildLeadList.add(l);
            }
            
            else if(!l.Is_Digital__c && !l.Is_Allow_Duplicates__c && !l.Is_Bot__c && !l.Legacy_Upload__c)
            {
                dedupeCheckLeadList.add(l);
            } 
            //----------------------------------------------------------------------------------------------//
            
        }
        
         //-------------------------------------------new dedupe additon by Saransh----------------------------------------------//
        if(bhStoreLeadList!=null && !bhStoreLeadList.isEmpty() && pincodeset!=null && !pincodeset.isEmpty()){
            AP_BHStoreManagementService.changestatus(bhStoreLeadList);
            AP_BHStoreManagementService.allocatedealer(bhStoreLeadList,pincodeset);
        }
         //---------------------------------------------------------------------------------------------------------------------//
   
        if(!ownerId.isEmpty() && !leadList.isEmpty())
            AP_LeadManagementService.updateAssignmentDateTime(ownerId, leadList, true);
        if(!preCheckLeadList.isEmpty()) {
            AP_LeadManagementService.runPrehook(preCheckLeadList);
            AP_LeadManagementService.checkServiceability(preCheckLeadList);
            // AP_LeadManagementService.runDedupeCheck(preCheckLeadList);
        }
        //-------------------------------------------new dedupe additon by Saransh----------------------------------------------//
        if(!dedupeCheckLeadList.isEmpty()) {
            AP_LeadManagementService.runDedupeCheck(dedupeCheckLeadList);
        }
        if(!bhstoreparentmap.IsEmpty() && !SpsChildUnderBhStoreCA.isEmpty()){
            AP_BHStoreManagementService.createBhStoreParentLead(bhstoreparentmap, SpsChildUnderBhStoreCA);
        }
        if(!bhstoreparentmap.IsEmpty() && !SpsChildUnderBhStoreDA.isEmpty()){
            AP_BHStoreManagementService.createBhStoreParentLead(bhstoreparentmap, SpsChildUnderBhStoreDA);
        }
        if(!bhstoreparentmap.IsEmpty() && !SpsChildLeadList.isEmpty()){
            AP_BHStoreManagementService.createBhStoreParentLead(bhstoreparentmap, SpsChildLeadList);
        }
        if(!bhstoreparentmap.IsEmpty() && !SleekChildLeadList.isEmpty()){
            AP_BHStoreManagementService.createBhStoreParentLead(bhstoreparentmap, SleekChildLeadList);
        }
        if(!bhstoreparentmap.IsEmpty() && !ProductSalesChildLeadList.isEmpty()){
            AP_BHStoreManagementService.createBhStoreParentLead(bhstoreparentmap, ProductSalesChildLeadList);
        }
        //-------------------------------------------------------------------------------------------------------------//
        AP_LeadManagementService.tagServiceTerritoryDetail(leadList);
        
    }
    
    public static void onAfterInsert(Map<Id, Lead> newLeadMap) {
        Id bhStoreRecId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BH Store').getRecordTypeId();//new addition 
        List<Lead> BhChildLeads = new List<Lead>();// by raghu
        List<Lead> leadList = new List<Lead>();
        Map<Id,Schema.RecordTypeInfo> rtMap = Lead.sobjectType.getDescribe().getRecordTypeInfosById();
        Set<Id> lIdCTISet = new Set<Id>();
        Set<Id> lIdMessageUserSet = new Set<Id>();
        List<Lead> leadListC4CBHS = new List<Lead>();
        //Set<Id> userIdSet = new Set<Id>();
        Map<Id, Set<Id>> apexShareUserMap = new Map<Id, Set<Id>>();
        
        leadList = [Select Id,Name, BH_Store_Lead__c,RecordTypeId, Status, Is_Bot__c, Whatsapp_Notification__c, Legacy_Upload__c, AOD_Master__c,
                    Integration_Source__c, TL1__c, TL2__c, CampaignName__c, Campaign_Code__c, Owner.Profile.Name, OwnerId,Inter_Related_BU_1__c,Cross_Sell_By__c
                    from Lead where Id IN: newLeadMap.keySet()];//BH_Store_Lead__c  --- added
        
        
        if(!leadList.isEmpty()) {
            for(Lead l: leadList) {
                if(l.BH_Store_Lead__c != Null){
                    BhChildLeads.add(l);
                }
                if(!l.Is_Bot__c && l.Whatsapp_Notification__c && !l.Legacy_Upload__c)
                    lIdMessageUserSet.add(l.Id);
                //-----Inter_Related_BU_1__c and cross_Sell_by__c added by Saransh--------------------------------------------------------//
                if(l.AOD_Master__c != null && !l.Legacy_Upload__c ){
                    if( l.Inter_Related_BU_1__c!=null && l.Cross_Sell_By__c!='Field Team'){     
                        system.debug('cross sell lead by helpline should not go or calling'); }
                    else if(l.RecordTypeId==bhStoreRecId && l.Status=='Allocation Done'){
                        system.debug('bh allocation done leads should not go for calling');
                    }
                    else{
                        lIdCTISet.add(l.Id);  
                    }        
                }
                
                //------------------------------------------------------------------------------------------------------------------//
                if(String.isNotBlank(l.Integration_Source__c) && l.Integration_Source__c.equalsIgnoreCase('C4C') && rtMap.get(l.RecordTypeId).getDeveloperName() == 'BHS')
                    leadListC4CBHS.add(l);
                //if(rtMap.get(l.RecordTypeId).getDeveloperName() == 'SPS' && l.Owner.Profile.Name == 'Customer Associate (CA)' && (l.Status == 'Lost' || l.Status == 'Allocation Done'))
                //userIdSet.add(l.OwnerId);
                // Create Apex Sharing With TL1 & TL2 //
                if(l.TL1__c != null) {
                    if(apexShareUserMap.containsKey(l.Id)) {
                        apexShareUserMap.get(l.Id).add(l.TL1__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(l.TL1__c);
                        apexShareUserMap.put(l.Id, idSet);
                    }
                }
                if(l.TL2__c != null) {
                    if(apexShareUserMap.containsKey(l.Id)) {
                        apexShareUserMap.get(l.Id).add(l.TL2__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(l.TL2__c);
                        apexShareUserMap.put(l.Id, idSet);
                    }
                }
            }
        }
        AP_LeadManagementService.tagCampaignLead(leadList);
        if(!lIdMessageUserSet.isEmpty() && lIdMessageUserSet != null)
            AP_BotManagementServices.initiateJourney(lIdMessageUserSet);
        if(!lIdCTISet.isEmpty() && lIdCTISet != null)
            AP_CTIManagementService.pushLeadtoCallingQueue(lIdCTISet);
        if(!leadListC4CBHS.isEmpty() && leadListC4CBHS != null)
            AP_LeadManagementService.makeAllocationforC4CBHSLead(leadListC4CBHS);
        //if(!userIdSet.isEmpty() && userIdSet != null)
        //AP_LeadManagementService.calculateLeadOpporunityInfo(userIdSet);
        if(!apexShareUserMap.isEmpty() && apexShareUserMap != null)
            AP_ApexSharingService.leadApexShare(apexShareUserMap);
        if(!BhChildLeads.isEmpty()){
            AP_LeadManagementService.updateChildLeads(BhChildLeads);
        }
    }
    
    public static void onAfterDelete(List<Lead> oldLead){
        List<Lead> BhChildLeads = new List<Lead>();
        //  List<Lead> leadList = new List<Lead>();
        
        // leadList = [Select Id,BH_Store_Lead__c, Name, RecordTypeId from Lead where Id IN: oldLeadMap.keySet()];
        System.debug('Old Leads deleted:'+ oldLead);
        //  if(!leadList.isEmpty()) {
        for(Lead l: oldLead) {
            if(l.BH_Store_Lead__c != Null){
                BhChildLeads.add(l);
            }
            // }
            
            
            System.debug('Bhleads deleted:'+ BhChildLeads );
        }
        if(!BhChildLeads.isEmpty()){
            AP_LeadManagementService.updateChildLeads(BhChildLeads);
        }
    }
    
    public static void onBeforeUpdate(Map<Id, Lead> oldLeadMap, Map<Id, Lead> newLeadMap) {
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        List<Lead> preCheckLeadList = new List<Lead>();
        List<Lead> leadList = new List<Lead>();
        List<Lead> pincodeLeadList = new List<Lead>();
        Set<Id> ownerId = new Set<Id>();
        
        for(Lead lead : newLeadMap.values()) {
            Lead oldLead = oldLeadMap.get(lead.Id);
            if(((lead.MobilePhone != oldLead.MobilePhone && !String.isBlank(lead.MobilePhone)) || (lead.Email != oldLead.Email && !String.isBlank(lead.Email))) && !lead.Legacy_Upload__c)
                preCheckLeadList.add(lead);
            if(lead.Pincode__c != oldLead.Pincode__c && !String.isBlank(lead.Pincode__c))
                pincodeLeadList.add(lead);
            if(lead.RecordTypeId == recId && lead.OwnerId != oldLead.OwnerId) {
                ownerId.add(lead.OwnerId);
                leadList.add(lead);
            }
        }
        if(!preCheckLeadList.isEmpty())
            AP_LeadManagementService.runDedupeCheck(preCheckLeadList);
        if(!pincodeLeadList.isEmpty() && pincodeLeadList != null)
            AP_LeadManagementService.pincodeChangeImplementation(pincodeLeadList);
        if(!ownerId.isEmpty() && !leadList.isEmpty())
            AP_LeadManagementService.updateAssignmentDateTime(ownerId, leadList, false);
    }
    
    public static void onAfterUpdate(Map<Id, Lead> oldLeadMap, Map<Id, Lead> newLeadMap) {
        List<Lead> BhChildLeads = new List<Lead>();
        List<Lead> LeadToConvert = new List<Lead>();
        List<Lead> updateCMList = new List<Lead>();
        List<Lead> leadList = new List<Lead>();
        Map<Id,Schema.RecordTypeInfo> rtMap = Lead.sobjectType.getDescribe().getRecordTypeInfosById();
        Set<Id> userIdSet = new Set<Id>();
        Set<Id> lIdSet = new Set<Id>();
        Set<Id> lIdC4CSet = new Set<Id>();
        Set<Id> lIdCTISet = new Set<Id>();
        Set<Id> lIdBlockCTISet = new Set<Id>();
        Set<Id> lIdBHSSet = new Set<Id>();
        Set<ID> lIdBHSSET1 = new Set<ID>();
        Map<Id, Set<Id>> apexShareUserMap = new Map<Id, Set<Id>>();
        
        leadList = [Select Id, Name,BH_Store_Lead__c,IsConverted,ConvertedOpportunityId,ConvertedOpportunity.AccountId,ConvertedOpportunity.Account.PersonContactId, RecordTypeId, Owner.Profile.UserLicense.Name,External_Lead_ID__c, Owner.Profile.Name, Status, Campaign_Code__c, Integration_Source__c,Auto_Drop_Reason__c, 
                    Is_Serviced__c, Lead_In_Calling_Queue__c,FirstName,House__c, Floor__c,City, PostalCode, LastName,Street, AOD_Master__c, TL1__c, TL2__c, Email,Phone,Mobilephone,Last_Appointment_Start_Date_Time__c,	Address 
                    from Lead where Id IN: newLeadMap.keySet()];
        system.debug('leadList: '+leadList);
        
        if(!leadList.isEmpty()) {
            for(Lead l: leadList) {
                if(l.BH_Store_Lead__c != Null){
                    BhChildLeads.add(l);
                }
                for(Lead lead : leadList) {
                    Lead oldLead = oldLeadMap.get(lead.Id);
                    /* 
** Scenarios for dealer open lead, last assignment datetime, last 7 day count:
1] Lead moved lost stage.
2] Assigning / Reassigning owner (SA-CA, CA1-CA2).
*/
                    if(lead.IsConverted && lead.IsConverted != oldLead.IsConverted && lead.BH_Store_Lead__c !=null){
                        LeadToConvert.add(lead);
                    }
                    if(lead.Status != oldLead.Status && lead.Status == 'Lost' && rtMap.get(lead.RecordTypeId).getDeveloperName() == 'SPS') {
                        if(lead.Owner.Profile.Name == 'Customer Associate (CA)')
                            userIdSet.add(lead.OwnerId);
                    }
                    if(lead.OwnerId != oldLead.OwnerId && rtMap.get(lead.RecordTypeId).getDeveloperName() == 'SPS') {
                        if(lead.Owner.Profile.Name == 'Customer Associate (CA)')
                            userIdSet.add(lead.OwnerId);
                        if(oldLead.Owner.Profile.Name == 'Customer Associate (CA)')
                            userIdSet.add(oldLead.OwnerId);
                        //////////////////Sharing if Lead Owner Changed //////////////////////
                        if(lead.TL1__c != null) {
                            if(apexShareUserMap.containsKey(lead.Id)) {
                                apexShareUserMap.get(lead.Id).add(lead.TL1__c);
                            } else {
                                Set<Id> idSet = new Set<Id>();
                                idSet.add(lead.TL1__c);
                                apexShareUserMap.put(lead.Id, idSet);
                            }
                        }
                        if(lead.TL2__c != null) {
                            if(apexShareUserMap.containsKey(lead.Id)) {
                                apexShareUserMap.get(lead.Id).add(lead.TL2__c);
                            } else {
                                Set<Id> idSet = new Set<Id>();
                                idSet.add(lead.TL2__c);
                                apexShareUserMap.put(lead.Id, idSet);
                            }
                        }
                    }
                    // Used For Create Campaign Memeber //
                    if(lead.Campaign_Code__c != oldLead.Campaign_Code__c)
                        updateCMList.add(lead);
                    // Used For Calling External System SLEEK API //
                    if(lead.Status != oldLead.Status && lead.Status == 'Allocation Done' && rtMap.get(lead.RecordTypeId).getDeveloperName() == 'SLEEK')
                        lIdSet.add(lead.Id);
                    // Used For Calling External System BHS API //
                    if(lead.Status != oldLead.Status && lead.Status == 'Allocation Done' && (rtMap.get(lead.RecordTypeId).getDeveloperName() == 'BHS' || rtMap.get(lead.RecordTypeId).getDeveloperName() == 'BH_Store'))
                        lIdBHSSet.add(lead.Id);
                    // Used For Calling External System C4C API //
                    if(lead.Status != oldLead.Status && String.isNotBlank(lead.Integration_Source__c) && lead.Integration_Source__c.equalsIgnoreCase('C4C'))
                        lIdC4CSet.add(lead.Id);
                    // Call CTI API For Calling //
                    if(lead.Is_Serviced__c != oldLead.Is_Serviced__c && !lead.Is_Serviced__c && lead.Lead_In_Calling_Queue__c && lead.AOD_Master__c != null){
                        lIdCTISet.add(lead.Id);
                        System.debug('Call CTI API For Calling');   
                    }
                    System.debug('Next Call CTI API For Calling');   
                    
                    // Call CTI API For Block Calling // status=closed and dropped lead reason added by Saransh
                    if(lead.Status != oldLead.Status && (lead.Status == 'Allocation Done' || lead.Status == 'Lost' || lead.Status =='Closed') && lead.Lead_In_Calling_Queue__c && lead.AOD_Master__c != null &&( lead.Auto_Drop_Reason__c != 'Unsuccessful Disposition' || lead.Drop_Lead_Reason__c=='Cross Sell - Lead'))
                        lIdBlockCTISet.add(lead.Id);
                    // Create Apex Sharing With TL1 & TL2 //
                    if(lead.TL1__c != oldLead.TL1__c) {
                        if(apexShareUserMap.containsKey(lead.Id)) {
                            apexShareUserMap.get(lead.Id).add(lead.TL1__c);
                        } else {
                            Set<Id> idSet = new Set<Id>();
                            idSet.add(lead.TL1__c);
                            apexShareUserMap.put(lead.Id, idSet);
                        }
                    }
                    if(lead.TL2__c != oldLead.TL2__c) {
                        if(apexShareUserMap.containsKey(lead.Id)) {
                            apexShareUserMap.get(lead.Id).add(lead.TL2__c);
                        } else {
                            Set<Id> idSet = new Set<Id>();
                            idSet.add(lead.TL2__c);
                            apexShareUserMap.put(lead.Id, idSet);
                        }
                    }
                    If(rtMap.get(lead.RecordTypeId).getDeveloperName() == 'BHS'){
                        //  If(lead.Status =='Allocation Done' && (lead.Email != oldLead.Email || lead.Phone !=oldLead.Phone || lead.MobilePhone != oldLead.MobilePhone ||
                        // lead.Last_Appointment_Start_Date_Time__c != oldLead.Last_Appointment_Start_Date_Time__c || lead.Address != oldLead.Address || lead.Name != oldLead.Name ) ){
                        if(lead.Status == 'Allocation Done' && oldlead.Status == 'Allocation Done' && ( lead.Email != oldLead.Email || lead.Floor__c != oldlead.Floor__c || lead.Street != oldlead.Street || lead.City != oldlead.City 
                                                                                                       || lead.House__c != oldlead.House__c || lead.Phone !=oldLead.Phone || lead.MobilePhone != oldLead.MobilePhone || 
                                                                                                       lead.Last_Appointment_Start_Date_Time__c != oldLead.Last_Appointment_Start_Date_Time__c || lead.FirstName != oldLead.FirstName 
                                                                                                       || lead.LastName != oldLead.LastName || lead.PostalCode != oldlead.PostalCode )){              
                                                                                                           system.debug('*****************************Calling lead update api' + lead.Status );
                                                                                                           
                                                                                                           lIdBHSSET1.add(lead.Id);
                                                                                                       }
                    }
                }  
                
            }
            if(!userIdSet.isEmpty() && userIdSet != null)
                AP_LeadManagementService.calculateLeadOpporunityInfo(userIdSet);
            if(!updateCMList.isEmpty() && updateCMList != null) 
                AP_LeadManagementService.tagCampaignLead(updateCMList);
            if(!lIdSet.isEmpty() && lIdSet != null) {
                AP_ExternalSystemAPIManagementServices.addCustomerSleek(lIdSet);
                AP_ExternalSystemAPIManagementServices.addSiteSleek(lIdSet);
            }
            if(!lIdC4CSet.isEmpty() && lIdC4CSet != null)
                AP_ExternalSystemAPIManagementServices.sendC4CLeadDetails(lIdC4CSet);
            if(!lIdBHSSet.isEmpty() && lIdBHSSet != null)
                AP_ExternalSystemAPIManagementServices.createLeadInBHSExternalSystem(lIdBHSSet ,'Lead Push API');
            if(!lIdBHSSET1.isEmpty() && lIdBHSSET1 != null)
                AP_ExternalSystemAPIManagementServices.createLeadInBHSExternalSystem(lIdBHSSET1, 'Lead Update API');
            if(!lIdCTISet.isEmpty() && lIdCTISet != null) 
                AP_CTIManagementService.pushLeadtoCallingQueue(lIdCTISet);
            if(!lIdBlockCTISet.isEmpty() && lIdBlockCTISet != null)
                AP_CTIManagementService.blockLeadfromCallingQueue(lIdBlockCTISet);
            if(!apexShareUserMap.isEmpty() && apexShareUserMap != null)
                AP_ApexSharingService.leadApexShare(apexShareUserMap);
            
            if(!BhChildLeads.isEmpty()){
                AP_LeadManagementService.updateChildLeads(BhChildLeads);
            } 
            system.debug('LeadtoConvert '+LeadtoConvert);
            if(!LeadToConvert.isEmpty()){
                AP_BHStoreManagementService.convertParent(LeadToConvert);
            }    
        }
    }
}