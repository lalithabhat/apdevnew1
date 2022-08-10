/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 08-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex trigger to handle all the trigger actions.
*********************************************************************************************************/
trigger AP_CaseTrigger on Case (after insert, before update, after update) {
    if(Trigger.isAfter && Trigger.isInsert)
        AP_CaseTriggerHandler.onAfterInsert(Trigger.newMap);
    if(Trigger.isBefore && Trigger.isUpdate)
        AP_CaseTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    if(Trigger.isAfter && Trigger.isUpdate)
        AP_CaseTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
}