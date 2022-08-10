public class AP_EnquiryTriggerHandler {
	public static void onAfterInsert(List<Enquiry__c> enquiryList) {
        Set<Id> leadIds = new Set<Id>();
        Set<Id> whatsappLeads = new Set<Id>();
       // List<String> testMobiles = new List<String>();
        //for(YM_Test_mobile__c mcs : YM_Test_mobile__c.getall().values()){
        //   testMobiles.add(mcs.mobile__c);
       // }
       // system.debug('mobiles '+ testMobiles);
        
        for(Enquiry__c e : enquiryList){
            if(e.Whatsapp_Notification__c || Test.isRunningTest())
            leadIds.add(e.Lead__c);
        }
        for(Lead l : [Select Id, mobilephone,RecordType.developerName, campaignName__r.Disable_Whatsapp__c from Lead Where Id IN: leadIds AND Legacy_Upload__c = False]){
        
           // if(testMobiles.contains(l.mobilephone))	
               
            if(l.RecordType.developerName!='BH_Store' &&  !l.campaignName__r.Disable_Whatsapp__c){
                 whatsappLeads.add(l.Id);
            }
        }
        
        if(!whatsappLeads.isEmpty()){
            system.debug('calling YM');
            YM_Lead_API.call_YM_LeadAPI(whatsappLeads);
        }
    }
}