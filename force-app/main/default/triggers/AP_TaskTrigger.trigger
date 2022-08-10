/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 20-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex trigger to handle all the trigger actions.
*********************************************************************************************************/
trigger AP_TaskTrigger on Task (after insert) {
	if(Trigger.isAfter && Trigger.isInsert)
        AP_TaskTriggerHandler.onAfterInsert(Trigger.new);
}