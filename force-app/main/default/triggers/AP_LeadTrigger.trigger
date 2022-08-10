/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 26-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex trigger to handle all the trigger actions.
*********************************************************************************************************/
trigger AP_LeadTrigger on Lead (before insert, before update, after insert, after update,after delete) {
    if(Trigger.isBefore && Trigger.isInsert){
          Id bhStoreRecId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BH Store').getRecordTypeId();//new addition 
         AP_LeadTriggerHandler.onBeforeInsert(Trigger.new);
        
        /**** Added BY VIKAS for get service ID ***/     
        List<Lead> leadIds = new List<Lead>();
        for(Lead l : trigger.new) {
            if(l.CampaignName__c != null && !l.Legacy_Upload__c) { //l.Pincode__c != null &&
                leadIds.add(l);
            }
        }
        if(!leadIds.isEmpty()) {
            Map<Lead, AOD_Master__c> returnMap = LeadManagementServices.getServiceId(leadIds);
            if(returnMap != null && !returnMap.isEmpty()) {
                for(Lead l : trigger.new) {
                    //new additions l.Click_To_Action__c!='Visit' && l.RecordTypeId!=bhStoreRecId by Saransh
                    if(returnMap.containsKey(l) && l.Click_To_Action__c!='Visit' && l.RecordTypeId!=bhStoreRecId)
                        l.AOD_Master__c = returnMap.get(l).Id;
                }
            }
        }
    }
    if(Trigger.isAfter && Trigger.isInsert){
        AP_LeadTriggerHandler.onAfterInsert(Trigger.newMap);
        Set<Id> leadIds = new set<Id>();
        
       
         for(Lead l : [Select Id, Whatsapp_Notification__c,Legacy_Upload__c, RecordType.developerName, campaignName__r.Disable_Whatsapp__c from Lead Where Id IN: Trigger.newMap.keySet()]){
          if(l.Whatsapp_Notification__c && !l.Legacy_Upload__c && l.RecordType.developerName!='BH_Store' &&  !l.campaignName__r.Disable_Whatsapp__c){
                leadIds.add(l.Id);
            }
         }
      /*  for(Lead l : trigger.new){
            if(l.Whatsapp_Notification__c && !l.Legacy_Upload__c){ //Consent_for_Whatsapp__c
                leadIds.add(l.Id);
            }
        }*/
        if(!leadIds.isEmpty()){
            YM_Lead_API.call_YM_LeadAPI(leadIds);
        }
    }
    if(Trigger.isBefore && Trigger.isUpdate){
      //  AP_LeadTriggerHandler.updateChildLeads(Trigger.new);
       AP_LeadTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate)
        AP_LeadTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
    if(Trigger.isAfter && Trigger.isDelete){                    //after deletion added by raghu
        AP_LeadTriggerHandler.onAfterDelete(Trigger.old);
    }
}