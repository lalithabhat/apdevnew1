/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 13-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex trigger to handle all the trigger actions.
*********************************************************************************************************/
trigger AP_UserTrigger on User (before insert, after insert, after update) {
    if(Trigger.isBefore && Trigger.isInsert)
        AP_UserTriggerHandler.onBeforeInsert(Trigger.new);
    if(Trigger.isAfter && Trigger.isInsert)
        AP_UserTriggerHandler.onAfterInsert(Trigger.newMap);
   if(Trigger.isAfter && Trigger.isUpdate)
      AP_UserTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
}