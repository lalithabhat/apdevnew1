/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 25-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all contact services.
*********************************************************************************************************/
public class AP_ContactManagementService {
	public static void updateDealerWeeklyLimit(List<Contact> newContacts) {
        Map<Id, Account> dealerMap = new Map<Id, Account>();
        Map<Id, List<User>> dealerCAMap = new Map<Id, List<User>>();
        Map<Id, Integer> dealerWeeklyLimitMap = new Map<Id, Integer>();
        List<Account> updateDealerList = new List<Account>();
        Set<Id> dealerIdSet = new Set<Id>();
		
        if(!newContacts.isEmpty() && newContacts != null) {        
            for(Contact c: newContacts) {
                dealerIdSet.add(c.AccountId);
            }
        }
        if(!dealerIdSet.isEmpty() && dealerIdSet != null) {
            dealerMap = DealerManagementServices.getDealerMap(dealerIdSet);
            dealerCAMap = DealerManagementServices.getDealerAllCAs(dealerIdSet);
            dealerWeeklyLimitMap = DealerManagementServices.getWeeklyLimit(dealerIdSet);
        }
        
        if(!dealerMap.isEmpty() && dealerMap != null) {
            for(Id dId: dealerMap.keySet()) {
                if(dealerWeeklyLimitMap.containsKey(dId)) {
                    Account dealer = dealerMap.get(dId);
                    dealer.Weekly_Limit_Max__c = dealerWeeklyLimitMap.get(dId);
                    if(dealerCAMap.containsKey(dealer.Id))
                        dealer.Number_of_CAs__c = dealerCAMap.get(dealer.Id).size();
                    updateDealerList.add(dealer);
                } else {
                    Account dealer = dealerMap.get(dId);
                    dealer.Weekly_Limit_Max__c = 0;
                    dealer.Number_of_CAs__c = 0;
                    updateDealerList.add(dealer);
                }
            }
        }
        if(!updateDealerList.isEmpty() && updateDealerList != null)
            update updateDealerList;
    }
    
    /*@future
    public static void inactiveActiveDirectoryUser(Set<String> fedIdSet) {
        List<User> updateUserList = new List<User>();
        List<User> uList = [Select Id, IsActive, Federation_Id__c from User where Federation_Id__c IN: fedIdSet AND AD_User__c = false AND IsActive = true];
        
        if(uList != null) {
            for(User u: uList) {
                u.IsActive = false;
                updateUserList.add(u);
            }
        }
        if(!updateUserList.isEmpty())
            update updateUserList;
    }*/
}