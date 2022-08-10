/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 03-12-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex trigger to handle all the trigger actions.
*********************************************************************************************************/
trigger AP_ChecklistHeaderTrigger on Checklist_Header__c (after insert, before update, after update) {
	if(Trigger.isAfter && Trigger.isInsert)
        AP_ChecklistHeaderTriggerHandler.onAfterInsert(Trigger.newMap);
	if(Trigger.isBefore && Trigger.isUpdate)
        AP_ChecklistHeaderTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    if(Trigger.isAfter && Trigger.isUpdate)
        AP_ChecklistHeaderTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
}