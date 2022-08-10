/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 13-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all user services.
*********************************************************************************************************/
public class AP_UserManagementService {
    public static Map<Id, Profile> getProfileMap() {
        Map<Id, Profile> profileMap = new Map<Id, Profile>();
        List<Profile> pList = [Select Id, Name from Profile];
        
        if(pList != null) {
            for(Profile p: pList) { 
                profileMap.put(p.Id, p);
            }
        }
        return profileMap;
    }
    
    /*@future
    public static void userCreationfromActiveDirectory(Set<Id> uIdSet) {
        Map<Id, Id> contactMap = new Map<Id, Id>();
        List<User> portalUserList = new List<User>();
        List<User> uList = [Select Id, FirstName, LastName, Alias, Email, UserName, MobilePhone, Phone, IsActive, Max_Limit_Weekly__c, 
                            Street, City, State, Country, PostalCode, TimeZoneSidKey, LocaleSidKey, LanguageLocaleKey, EmailEncodingKey,
                            FederationIdentifier, Federation_Id__c, PositionID__c from User where Id IN: uIdSet];
        
        if(uList != null) {
            contactMap = createContactforPortalUser(uList);
            system.debug('contactMap: '+contactMap);
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Customer Associate%' Limit 1];
            for(User u : uList) {
                User newUser = new User();
                if(portalProfile != null)
                	newUser.ProfileId = portalProfile.Id;
                if(contactMap != null && contactMap.containsKey(u.Id))
                	newUser.ContactId = contactMap.get(u.Id);
                if(u.FirstName != null && u.FirstName != '')
                    newUser.FirstName = u.FirstName;
                newUser.LastName = u.LastName;
                newUser.Alias = 'p'+u.LastName.left(4);
                newUser.Email = u.Email;
                if(u.Phone != null && u.Phone != '')
                    newUser.Phone = u.Phone;
                newUser.Username = u.Email+'.apldev';
                if(u.Street != null && u.Street != '')
                	newUser.Street = u.Street;
                if(u.City != null && u.City != '')	
                	newUser.City = u.City;
                if(u.State != null && u.State != '')
                	newUser.State = u.State;
                if(u.Country != null && u.Country != '')
                	newUser.Country = u.Country;
                if(u.PostalCode != null && u.PostalCode != '')
	                newUser.PostalCode = u.PostalCode;
                if(u.TimeZoneSidKey != null && u.TimeZoneSidKey != '')
	                newUser.TimeZoneSidKey = u.TimeZoneSidKey;
    			if(u.LocaleSidKey != null && u.LocaleSidKey != '')
	                newUser.LocaleSidKey = u.LocaleSidKey;
                if(u.LanguageLocaleKey != null && u.LanguageLocaleKey != '')
                	newUser.LanguageLocaleKey = u.LanguageLocaleKey;
                if(u.EmailEncodingKey != null && u.EmailEncodingKey != '')
                	newUser.EmailEncodingKey = u.EmailEncodingKey;
                if(u.Federation_Id__c != null && u.Federation_Id__c != '')
                    newUser.FederationIdentifier = u.Federation_Id__c;
                if(u.PositionID__c != null && u.PositionID__c != '')
                    newUser.PositionID__c = u.PositionID__c;
                newUser.AD_User__c = true;
                portalUserList.add(newUser);
            }
        }
        if(!portalUserList.isEmpty())
            insert portalUserList;
    }
    
    public static Map<Id, Id> createContactforPortalUser(List<User> uList) {
        Map<Id, Id> contactMap = new Map<Id, Id>();
        Id recId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        List<Account> aList = [Select Id, Name from Account where Name Like '%Untagged%' AND RecordTypeId =: recId];
        
        for(User u: uList) {
            Contact c = new Contact();
            if(aList != null)
            	c.AccountId = aList[0].Id;
            if(u.FirstName != null && u.FirstName != '')
                c.FirstName = u.FirstName;
            if(u.LastName != null && u.LastName != '')
                c.LastName = u.LastName;
            if(u.Email != null && u.Email != '')
                c.Email = u.Email;
            if(u.Phone != null && u.Phone != '')
                c.MobilePhone = u.Phone;
            if(u.Federation_Id__c != null && u.Federation_Id__c != '')
                c.Federation_Id__c = u.Federation_Id__c;
            c.Persona__c = 'CA';
            if(u.PositionID__c != null && u.PositionID__c != '')
                c.PositionID__c = u.PositionID__c;
            //c.Employee_Code__c = '';
            //c.LOB__c = 'SPS';
            insert c;
            contactMap.put(u.Id, c.Id);
        }
        return contactMap;
    }*/
    
    @future
    public static void updateContactDetails(Set<Id> uIdSet) {
        Map<Id, User> uMap = new Map<Id, User>();
        List<Contact> updateContactList = new List<Contact>();
		Map<Id, Contact> CAContactMap = new Map<Id, Contact>();
        
        if(uIdSet != null) {
        	List<User> uList = [Select Id, Name, IsActive, ContactId from User where Id IN: uIdSet];
            
            if(uList != null) {
                for(User u: uList) {
                    uMap.put(u.Id, u);
                }
            }
        }
        if(uMap != null) {
            CAContactMap = DealerManagementServices.getCAContact(uMap.values());
            
            for(User u: uMap.values()) {
                if(!CAContactMap.IsEmpty() && CAContactMap.containsKey(u.Id)) {
                    Contact c = CAContactMap.get(u.Id);
                    c.Active__c = uMap.get(u.Id).IsActive;
                    updateContactList.add(c);
                } 
            }
        }
        if(!updateContactList.isEmpty())
            update updateContactList;
    }
}