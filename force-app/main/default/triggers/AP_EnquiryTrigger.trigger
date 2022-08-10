trigger AP_EnquiryTrigger on Enquiry__c (before insert,after insert) {
    if(Trigger.isBefore && Trigger.isInsert){
        //List<Lead> l = [Select Id From Lead where Id =: Trigger.new.];
        
        /**** Added By Sankalp to populate the AOD Master for every re enquiry if a lead is tagged to the enquiry***/     
        List<Lead> leadIds = new List<Lead>();
        String enqCampId;
        Lead l = New Lead();
        for(Enquiry__c en1 : trigger.new) {
            system.debug('Enquiry details-->'+trigger.new);
            if(en1.Lead__c != null) { //l.Pincode__c != null &&
                l = [Select Id, FirstName, LastName,Pincode__c,CampaignName__c,Process_Type__c,AOD_Master__c
                     From Lead where Id =: en1.Lead__c];
                leadIds.add(l);
                if(en1.Campaign__c != null){
                    enqCampId = en1.Campaign__c;
                    System.debug('enqCampId : '+enqCampId);
                    l.CampaignName__c = enqCampId;        
                }
            }
        }
        System.debug('leadIds : '+leadIds);
        update l;
        if(!leadIds.isEmpty()) {
            Map<Lead, AOD_Master__c> returnMap = LeadManagementServices.getServiceId(leadIds);
            if(returnMap != null && !returnMap.isEmpty()) {
                for(Enquiry__c en2 : trigger.new) {
                    if(en2.Lead__c != null) { //l.Pincode__c != null &&
                        Lead ll = [Select Id, FirstName, LastName,Pincode__c,CampaignName__c,Process_Type__c,AOD_Master__c
                                   From Lead where Id =: en2.Lead__c];
                        System.debug('lead at line 28 '+ll);
                        //if(returnMap.containsKey(l))
                        //    en2.AOD_Master__c = returnMap.get(l).Id;
                        
                        if(ll != null && returnMap.containsKey(ll)){
                            ll.AOD_Master__c = returnMap.get(ll).Id;
                            update ll;
                        }
                    }
                }
            }
        }
    }
    
    if(Trigger.isAfter && trigger.isInsert){
        AP_EnquiryTriggerHandler.onAfterInsert(trigger.new);
    }
}