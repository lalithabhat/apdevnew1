/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 25-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and filter all the Dealer Contractor Mapping based on the trigger actions.
*********************************************************************************************************/
public class AP_DCMTriggerHandler {
    public static void onAfterInsert(Map<Id, Dealer_Contractor_Mapping__c> newDCMMap) {
        AP_DCMManagementService.updateDealerTotalCapacity(newDCMMap.values()); 
    }
    
    public static void onAfterUpdate(Map<Id, Dealer_Contractor_Mapping__c> oldDCMMap, Map<Id, Dealer_Contractor_Mapping__c> newDCMMap) {
        List<Dealer_Contractor_Mapping__c> dcmList = new List<Dealer_Contractor_Mapping__c>();
        for(Dealer_Contractor_Mapping__c dcm : newDCMMap.values()) {
            Dealer_Contractor_Mapping__c oldDCM = oldDCMMap.get(dcm.Id);
            if(dcm.Relation_Status__c != oldDCM.Relation_Status__c || dcm.Dealer__c != oldDCM.Dealer__c) {
                dcmList.add(dcm);
            }
        }
        if(!dcmList.isEmpty() && dcmList != null)
            AP_DCMManagementService.updateDealerTotalCapacity(dcmList);
    }
}