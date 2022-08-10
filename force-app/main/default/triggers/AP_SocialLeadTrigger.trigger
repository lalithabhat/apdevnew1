/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 16-09-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex trigger to handle all the trigger actions.
*********************************************************************************************************/
trigger AP_SocialLeadTrigger on Social_Lead__c (after insert, after update) {
	if(Trigger.isAfter && Trigger.isInsert)
        AP_SocialLeadTriggerHandler.onAfterInsert(Trigger.new);
    if(Trigger.isAfter && Trigger.isUpdate)
        AP_SocialLeadTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
}