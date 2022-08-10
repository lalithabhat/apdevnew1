@isTest
public class TestUserAttritionController {
    @isTest
    private static void userAttritionTest() {
        account firstDealer = TestDataFactory.createDealerAccount('firstDealer','1234567891','D12345','CI');
        account secondDealer = TestDataFactory.createDealerAccount('secondDealer','1234567892','D12346','CI');
        
        Contact CA = TestDataFactory.createPortalUser('CA', 'Contact', '1234567891', 'ca@stetig.in', firstDealer.Id, 'Customer Associate (CA)', 'PP9987009334', 'CA',true);
        Contact SA = TestDataFactory.createPortalUser('SA', 'Contact', '1234567892', 'sa@stetig.in', secondDealer.Id, 'Sales Associate (SA)', 'PP9987009335', 'SA',true);
        
        Contact NOT_VALID_CA = TestDataFactory.createPortalUser('First', 'Contact', '1234567893', 'first@stetig.in', firstDealer.Id, 'Customer Associate (CA)', 'PP9987009336', 'CES',true);
        Contact NOT_VALID_SA = TestDataFactory.createPortalUser('second', 'Contact', '1234567894', 'second@stetig.in', secondDealer.Id, 'Sales Associate (SA)', 'PP9987009337', 'CES',true);
        
        Contact deactive_User = TestDataFactory.createPortalUser('CA', 'Contact', '1234567895', 'deactive@stetig.in', firstDealer.Id, 'Customer Associate (CA)', 'PP9987009335', 'CA',false);
        
        Service_Master__c sm = new Service_Master__c();
        sm.Service__c = 'SPS';
        sm.Skills__c = 'Nilaya';
        sm.Slot_Duration_in_Hours__c = 1.00;
        insert sm;
        
        SA_Pincode_Mapping__c pm = new SA_Pincode_Mapping__c();
        pm.Pincode__c = '123456';
        pm.Role__c = 'SA';
        pm.Priority__c = 1;
        pm.SA__c = deactive_User.Id;
        pm.Service_Master__c = sm.Id;
        insert pm;
        
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        
        Test.startTest();
        List<Contact> Firstcontact = UserAttritionController.getContactRecords('PP9987009334');
        List<Contact> Secondcontact = UserAttritionController.getContacts();
        string str = UserAttritionController.checkValidationAPex(NOT_VALID_CA.Id, SA.Id);
        string str2 = UserAttritionController.checkValidationAPex(SA.Id,NOT_VALID_CA.Id);
        string str3 = UserAttritionController.checkValidationAPex(SA.Id,CA.Id);
        string str4 = UserAttritionController.checkValidationAPex(deactive_User.Id,deactive_User.Id);
        string str5 = UserAttritionController.checkValidationAPex(deactive_User.Id,SA.Id);
        SA_Pincode_Mapping__c newInt = new SA_Pincode_Mapping__c();
        newInt.Id = pm.Id;
        newInt.SA__c = null;
        newInt.TL1__c = deactive_User.Id;
        update newInt;
        string str6 = UserAttritionController.checkValidationAPex(deactive_User.Id,SA.Id);
        
        SA_Pincode_Mapping__c newInt2 = new SA_Pincode_Mapping__c();
        newInt2.Id = pm.Id;
        newInt2.SA__c = null;
        newInt2.TL1__c = null;
        newInt2.TL2__c = deactive_User.Id;
        update newInt2;
        string str7 = UserAttritionController.checkValidationAPex(deactive_User.Id,SA.Id);
        List<User> oldUser = [select id,name,mobilePhone from user where contactId=:deactive_User.Id and isActive = false];
        set<Id> oppIds = new Set<Id>();
        oppIds.add('00672000000gjYbAAI');
        UserAttritionController.getRecordList(oppIds,'Case', 'Opportunity__c', oldUser[0].Id,null);
        Test.stopTest();
    }
}