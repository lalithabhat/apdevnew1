/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 25-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex trigger to handle all the trigger actions.
*********************************************************************************************************/
trigger AP_DCMTrigger on Dealer_Contractor_Mapping__c (after insert, after update) {
	if(Trigger.isAfter && Trigger.isInsert)
        AP_DCMTriggerHandler.onAfterInsert(Trigger.newMap);
    if(Trigger.isAfter && Trigger.isUpdate)
        AP_DCMTriggerHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
}