/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 16-09-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and filter all the Social Lead based on the trigger actions.
*********************************************************************************************************/
public class AP_SocialLeadTriggerHandler {
	public static void onAfterInsert(List<Social_Lead__c> socialLeadList) {
        Set<Id> slId = new Set<Id>();
        for(Social_Lead__c sl: socialLeadList) {
            if(!sl.Processed__c)
            	slId.add(sl.Id);
        }
        if(!slId.isEmpty())
            AP_SocialLeadManagementService.processSocialLead(slId);
    }
    
    public static void onAfterUpdate(Map<Id, Social_Lead__c> oldSocialLeadMap, Map<Id, Social_Lead__c> newSocialLeadMap) {
        Set<Id> slId = new Set<Id>();
        for(Social_Lead__c sl: newSocialLeadMap.values()) {
            Social_Lead__c oldsl = oldSocialLeadMap.get(sl.Id);
            if(sl.Processed__c != oldsl.Processed__c && sl.Processed__c == false)
            	slId.add(sl.Id);
        }
        if(!slId.isEmpty())
            AP_SocialLeadManagementService.processSocialLead(slId);
    }
}