/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 26-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex trigger to handle all the trigger actions.
*********************************************************************************************************/
trigger AP_OpportunityTrigger on Opportunity (before insert, before update, after insert, after update,after delete) {
    if(Trigger.isBefore && Trigger.isInsert)
        AP_OpportunityTriggerHandler.onBeforeInsert(Trigger.new);
    if(Trigger.isAfter && Trigger.isInsert)
        AP_OpportunityTriggerHandler.onAfterInsert(Trigger.newMap);
    if(Trigger.isBefore && Trigger.isUpdate)
        AP_OpportunityTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    if(Trigger.isAfter && Trigger.isUpdate)
        AP_OpportunityTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
    if(Trigger.isAfter && Trigger.isDelete)
        AP_OpportunityTriggerHandler.onAfterDelete(Trigger.old);  // After Delete Event added by raghu
}