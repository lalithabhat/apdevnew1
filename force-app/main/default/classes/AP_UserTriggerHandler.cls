/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 13-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and filter all the users based on the trigger actions.
*********************************************************************************************************/
public class AP_UserTriggerHandler {
    public static void onBeforeInsert(List<User> uList) {
        /*for(User u : uList) {
            if(u.Max_Limit_Weekly__c > 0) {
                u.Federation_Id__c = u.FederationIdentifier;
                u.FederationIdentifier = '';
            }
        }*/
    }
    
    public static void onAfterInsert(Map<Id, User> newUserMap) {
        Set<Id> uIdSet = new Set<Id>();
        Set<Id> userADIdSet = new Set<Id>();
        Map<Id, Profile> profileMap = AP_UserManagementService.getProfileMap();
        
        for(User u : newUserMap.values()) {
            if(!u.AD_User__c) {
        		//if(u.Max_Limit_Weekly__c > 0)
                	//userADIdSet.add(u.Id);
                if(profileMap.get(u.ProfileId).Name.contains('Customer Associate'))
                	uIdSet.add(u.Id);
            }
        }
        if(!uIdSet.isEmpty())
            AP_UserManagementService.updateContactDetails(uIdSet);
        //if(!userADIdSet.isEmpty())
            //AP_UserManagementService.userCreationfromActiveDirectory(userADIdSet);
    }
    
    public static void onAfterUpdate(Map<Id, User> oldUserMap, Map<Id, User> newUserMap) {
        Set<Id> uIdSet = new Set<Id>();
        // query contact related user - active - newUserMap - query vari - check for user and contact active cond
		// List<Contact> contactList = [SELECT Id, Active__c FROM Contact];
        List<User> userList = [SELECT Id, ContactId, IsActive, Max_Limit_Weekly__c, Contact.Id, Contact.Active__c FROM User WHERE Id =: newUserMap.keyset()];
        
        for(User user : userList) {
            User oldUser = oldUserMap.get(user.Id);
            /*
            System.debug('User ID: '+user.Id);
            // System.debug('User ContactId: '+ user.ContactId != null);
            System.debug('USer Active condition: '+ String.valueOf(user.IsActive) != String.valueOf(oldUser.IsActive));
            System.debug('user.Max_Limit_Weekly__c == null: '+ user.Max_Limit_Weekly__c != null);
            System.debug('String.valueOf(user.IsActive): '+ String.valueOf(user.IsActive));
            System.debug('Old User - Contact' + oldUser.Contact.Active__c);
            System.debug('user.IsActive == oldUser.Contact.Active__c: '+ String.valueOf(user.IsActive) == String.valueOf(user.Contact.Active__c));
            */
            if(user.ContactId != null && user.IsActive != oldUser.IsActive && user.Max_Limit_Weekly__c != null && user.IsActive == user.Contact.Active__c) 
                uIdSet.add(user.Id);
        }
        if(!uIdSet.isEmpty())
            AP_UserManagementService.updateContactDetails(uIdSet);
    }
}