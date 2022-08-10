/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 03-12-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex trigger to handle all the trigger actions.
*********************************************************************************************************/
trigger AP_SiteTrigger on Milestone1_Project__c (before insert, after insert, before update, after update) {
    if(Trigger.isBefore && Trigger.isInsert) {
        /**** Added BY VIKAS for New Site Logic ***/     
        if(trigger.new.size() == 1) {
            Id accountId;
            Id pincode;
            for(Milestone1_Project__c site : trigger.new){
                if(site.Reason__c != 'New Address in Same Pincode'){
                    if(site.Account__c != null){
                        accountId = site.Account__c;
                    }
                    if(site.PincodeLookup__c != null){
                        pincode = site.PincodeLookup__c;
                    }
                }
            }
            
            if(accountId != null && pincode != null) {
                List<Milestone1_Project__c> existingSiteList = [select id,name,Deadline__c  from Milestone1_Project__c where 
                                                                Account__c =: accountId and PincodeLookup__c =: pincode
                                                                order by Deadline__c DESC];
                system.debug('existingSiteList::'+existingSiteList);
                Boolean newSite = false;
                if(existingSiteList != null && !existingSiteList.isEmpty()){
                    if(existingSiteList[0].Deadline__c != null && existingSiteList[0].Deadline__c.daysBetween(system.today()) > 180){
                        newSite = true;
                    }
                }else{
                    newSite = true;
                }
                for(Milestone1_Project__c site : trigger.new){
                    site.New_Site__c = newSite;
                }
                
            }
        }        
    }
    if(Trigger.isAfter && Trigger.isInsert)
        AP_SiteTriggerHandler.onAfterInsert(Trigger.newMap);
    if(Trigger.isBefore && Trigger.isUpdate) {
        /**** Added BY Harshal for Approved Logic ***/
        for(Milestone1_Project__c s : trigger.new){
            if(s.Status__c == 'Approved' && trigger.oldMap.get(s.Id).Status__c !='Approved' && !s.TA_Audit_Complete__c )
                s.addError('Please fill TA checklist before approving record');
        }
        AP_SiteTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
          /**** Added BY Harshal for Approved Logic ***/
        for(Milestone1_Project__c s : trigger.new){
            if(s.Status__c == 'TA Approved' && trigger.oldMap.get(s.Id).Status__c !='TA Approved'){
                String msg = s.Name+' has been approved by TA for Service Warranty. Please proceed for Site closure.';
                Set<String> recipient = new Set<String>{s.OwnerId}; 
                Notification_Utility.notifyUsers(recipient,s.Id,'Site Approval Alert',msg); 
            }
            else if(s.Status__c == 'TA Rejected' && trigger.oldMap.get(s.Id).Status__c !='TA Rejected'){
                String msg = s.Name+' has been rejected by TA for Service Warranty. Please recheck on the work at site & resend for approval.';
                Set<String> recipient = new Set<String>{s.OwnerId}; 
                Notification_Utility.notifyUsers(recipient,s.Id,'Site Rejection Alert',msg); 
           
            }
        }
            
        AP_SiteTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}