/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 25-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all Dealer Contractor Mapping services.
*********************************************************************************************************/
public class AP_DCMManagementService {
    public static void updateDealerTotalCapacity(List<Dealer_Contractor_Mapping__c> newDCMs) {
        Map<Id, Account> dealerMap = new Map<Id, Account>();
        Map<Id, List<Dealer_Contractor_Mapping__c>> dealerContractorMap = new Map<Id, List<Dealer_Contractor_Mapping__c>>();
        Map<Id, Integer> dealerTotalCapacityMap = new Map<Id, Integer>();
        List<Account> updateDealerList = new List<Account>();
        Set<Id> dealerIdSet = new Set<Id>();
        
        if(!newDCMs.isEmpty() && newDCMs != null) {
            for(Dealer_Contractor_Mapping__c d: newDCMs) {
                dealerIdSet.add(d.Dealer__c);
            }
        }
        if(!dealerIdSet.isEmpty() && dealerIdSet != null) {
            dealerMap = DealerManagementServices.getDealerMap(dealerIdSet);
            dealerContractorMap = DealerManagementServices.getDealerAllContractors(dealerIdSet);
            dealerTotalCapacityMap = DealerManagementServices.getTotalCapacity(dealerIdSet);
        }
        if(!dealerMap.isEmpty() && dealerMap != null) {
            for(Id dId: dealerMap.keySet()) {
                if(dealerTotalCapacityMap.containsKey(dId)) {
                    Account dealer = dealerMap.get(dId);
                    dealer.Total_Capacity__c = dealerTotalCapacityMap.get(dId);
                    if(dealerContractorMap.containsKey(dealer.Id))
                        dealer.Contractors__c = dealerContractorMap.get(dealer.Id).size();
                    updateDealerList.add(dealer);
                }
            }
        }
        if(!updateDealerList.isEmpty() && updateDealerList != null)
            update updateDealerList;
    }
}