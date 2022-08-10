/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 26-10-2021
*Created By - Sankalp Tiwari
*---------------------------------------------------------------------------------------------------------
*Description - Apex trigger to handle all the MessagingEndUser trigger actions.
*********************************************************************************************************/
trigger AP_MessagingEndUserTrigger on MessagingEndUser (after insert) {
    if(Trigger.isAfter && Trigger.isInsert)
        AP_MessagingEndUserTriggerHandler.onAfterInsert(Trigger.new);
}