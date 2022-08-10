/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 25-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and filter all the contacts based on the trigger actions.
*********************************************************************************************************/
public class AP_ContactTriggerHandler {
    public static void onAfterInsert(Map<Id, Contact> newContactMap) {
        AP_ContactManagementService.updateDealerWeeklyLimit(newContactMap.values());
    }
    
    public static void onAfterUpdate(Map<Id, Contact> oldContactMap, Map<Id, Contact> newContactMap) {
        List<Contact> contactList = new List<Contact>();
        Set<String> fedIdSet = new Set<String>();    
        
        List<User> userList = new List<User>();
        List<ID> uid = new List<ID>();
        boolean active;
        System.debug('--- DEBUG ---');
        
        for(Contact contact : newContactMap.values()) {
            Contact oldContact = oldContactMap.get(contact.Id);
            if(contact.Active__c != oldContact.Active__c || contact.Weekly_Limit_Max__c != oldContact.Weekly_Limit_Max__c)
                contactList.add(contact);
            
            if(!contactList.isEmpty() && contactList != null)
                AP_ContactManagementService.updateDealerWeeklyLimit(contactList);
            /*if(!String.isBlank(contact.Federation_Id__c) && contact.AccountId != oldContact.AccountId) {
contactList.add(contact);
fedIdSet.add(contact.Federation_Id__c);
}*/          
            
            System.debug('Debug ::::::::: ');
            System.debug('--- Person Contact ---' + contact.IsPersonAccount);
            if(boolean.valueOf(contact.IsPersonAccount) == false && contact.Persona__c == 'CA'){
                // User u = new User(ContactId = con.Id);
                if(contact.id != null){
                    User u = [SELECT Id, ContactId, IsPortalEnabled FROM User WHERE ContactId =: contact.Id AND (IsPortalEnabled =: true AND Profile.Name ='Customer Associate (CA)')];
                    System.debug('User Detail -- '+ u);
                    if(u.IsPortalEnabled == true && u.ContactId != null){
                        u.FirstName = contact.FirstName;
                        u.LastName = contact.LastName;            
                        u.Email = contact.Email;
                        u.Phone = contact.Phone;
                        u.MobilePhone = contact.MobilePhone;
                        u.Phone = contact.MobilePhone;
                        u.FederationIdentifier = contact.Employee_Code__c;
                        u.Employee_Number__c = contact.Employee_Code__c;
                        uid.add(u.Id); // User - Contact
                        active = contact.Active__c;
                        userList.add(u); 
                        // contact.Active__c = true;
                        System.debug('UserList -- '+userList);
                    }
                }
            }
        } 
        update userList;
        userActivate(uid, active);
    }
    
    // if(System.IsBatch() == false && System.isFuture() == false){
    @future
    public static void userActivate(List<ID> uid, boolean enable){
        System.debug('uid -- ' + uid + 'enabled -- ' + enable);
        List<User> uList = new List<User>();
        for(ID i : uid){
            User us = [SELECT Id, IsPortalEnabled FROM User WHERE Id =: uid];
            if(us.IsPortalEnabled == true){
                system.debug('ID --> '+us.Id);
                System.debug('Active ---> '+enable);
                us.IsActive = boolean.valueOf(enable);
                System.debug('Active ++ ' + us.IsActive);
                uList.add(us);
            }
        }
        update uList;
        System.debug('uList --' + uList); 
    }   
    // }
    
    
    //if(!fedIdSet.isEmpty() && fedIdSet != null)
    //AP_ContactManagementService.inactiveActiveDirectoryUser(fedIdSet);
    
    // For activating/deactivating USer on contact Update
    // added by Arti Bhoyar        
    
    /* for(Map<Id, Contact> con : newContactMap.values()){
System.debug('Debug ::::::::: ');
System.debug('--- Person Contact ---' + con.IsPersonAccount);
if(con.IsPersonAccount == false){
// User u = new User(ContactId = con.Id);
User u = [SELECT Id, ContactId, IsPortalEnabled FROM User WHERE ContactId =: con.Id AND IsPortalEnabled =: true];
System.debug('User Detail -- '+ u);
if(u.IsPortalEnabled == true && u.ContactId != null){
u.FirstName = con.FirstName;
u.LastName = con.LastName;            
u.Email = con.Email;
u.Phone = con.Phone;
u.MobilePhone = con.MobilePhone;
u.Federation_Id__c = con.Employee_Code__c;
uid.add(u.Id);
active = con.Active__c;
userList.add(u); 
System.debug('UserList -- '+userList);
}
}
}

update userList;
userActivate(uid, active);*/    
    
    
}