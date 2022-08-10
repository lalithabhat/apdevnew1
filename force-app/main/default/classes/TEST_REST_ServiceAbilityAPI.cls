@isTest
public class TEST_REST_ServiceAbilityAPI {
    //pincode missing
	@isTest
    public static void test1()
    {
                
       Test.startTest();
        REST_ServiceAbilityAPI.REST_Request rsa = new REST_ServiceAbilityAPI.REST_Request();    
        
        rsa.pincode='';
        REST_ServiceAbilityAPI.REST_Result result = REST_ServiceAbilityAPI.getDetails(rsa);
        
        System.assertEquals(result.message, 'Required parameters are missing');
        System.assertEquals(result.returnCode, '400');
        System.assertEquals(result.BHS_CES_flag, false);
        System.assertEquals(result.BHS_DA_flag, false);
        System.assertEquals(result.SPS_SA_flag, false);
        System.assertEquals(result.SPS_CA_flag, false);
        Test.stopTest();
    }
    
    
    //bhs pincode
    @isTest
    public static void test3()
    {
        
        Test.startTest();
        REST_ServiceAbilityAPI.REST_Request rsa = new REST_ServiceAbilityAPI.REST_Request();
        Pincode__c pin = new Pincode__c();
        pin.Name = '543216';
        pin.City__c = 'AHMEDABAD';
        pin.Country__c = 'India';
        pin.Country_Code__c = 'IN';
        pin.State__c = 'Maharashtra';
        pin.Pincode_Ext__c = '543216';
        insert pin;
        
        Service_Master__c sm = new Service_Master__c();
        sm.Service__c='BHS';
        sm.Skills__c='BHS';
        sm.Slot_Duration_in_Hours__c = 1.00;
        insert sm;
        
        SA_Pincode_Mapping__c pm = new SA_Pincode_Mapping__c();
        pm.Pincode__c=pin.Name;
        pm.Pincode_lookup__c=pin.Id;
        pm.Role__c='DA';
        pm.Service_Master__c=sm.Id;
        insert pm;
        
        rsa.pincode=pm.Pincode__c;
        REST_ServiceAbilityAPI.REST_Result result = REST_ServiceAbilityAPI.getDetails(rsa);
        
        
        System.assertEquals(result.message, 'No Records Retrieved. Please re-check your pincode and LOB and Check whether the user is active');
        System.assertEquals(result.returnCode, '400');
        System.assertEquals(result.BHS_CES_flag, false);
        System.assertEquals(result.BHS_DA_flag, false);
        System.assertEquals(result.SPS_SA_flag, false);
        System.assertEquals(result.SPS_CA_flag, false);
        Test.stopTest();
    }
    
    @isTest
    public static void test4()
    {
        Test.startTest();
        Map<string,string> resultMap = new Map<string,string>();
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = 'testAccount';
        
        a.Phone = '1234567123';
        a.Dealer_Code__c = 'D12345';
        a.RecordTypeId = devRecordTypeId;
        a.OwnerId = u.Id;
        insert a;
        
        contact c1 = new Contact();
        c1.FirstName = 'First';
        c1.LastName = 'test contact';
        c1.mobilePhone = '1234567123';
        c1.email = 'test@contact.in';
        c1.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c1.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c1.Active__c = true;
        c1.AccountId = a.Id;
        insert c1;
        resultMap.put('CA',c1.Id);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;       
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerAutoResponseEmail = false;       
        dmo.optAllOrNone = false;
        
       
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Associate (SA)' Limit 1];
        string nick = c1.email!=null?c1.email.substring(0, c1.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        User newUser1 = new User(alias=c1.firstName, email = c1.email, emailencodingkey = 'UTF-8', 
                                 firstname = c1.firstName, lastname = c1.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c1.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = c1.email,CommunityNickname = nick,ProfileId =portalProfile.Id, IsActive = true);
        newUser1.setOptions(dmo);
        insert newUser1;
        
       
        
        
        
        Service_Master__c sm = new Service_Master__c();
        sm.Service__c = 'BHS';
        sm.Skills__c = 'BHS';
        sm.Slot_Duration_in_Hours__c = 1.00;
        insert sm;
        
        Pincode__c pin = new Pincode__c();
        pin.Name = '123456';
        pin.City__c = 'AHMEDABAD';
        pin.Country__c = 'India';
        pin.Country_Code__c = 'IN';
        pin.Pincode_Ext__c = '123456';
        insert pin;
        
        SA_Pincode_Mapping__c pm = new SA_Pincode_Mapping__c();
        pm.Pincode__c = '123456';
        pm.Role__c = 'CES';
        pm.Priority__c = 1;
        pm.SA__c = c1.Id;
        pm.Service_Master__c = sm.Id;
        insert pm;
        
        REST_ServiceAbilityAPI.REST_Request rsa = new REST_ServiceAbilityAPI.REST_Request();
        rsa.pincode=pin.Name;
        REST_ServiceAbilityAPI.REST_Result result = REST_ServiceAbilityAPI.getDetails(rsa);
        
        
        System.assertEquals(result.message, 'Success');
        System.assertEquals(result.returnCode, '201');
        System.assertEquals(result.BHS_CES_flag, true);
        System.assertEquals(result.BHS_DA_flag, false);
        System.assertEquals(result.SPS_SA_flag, false);
        System.assertEquals(result.SPS_CA_flag, false);
        Test.stopTest();
    }
    //SPS
    @isTest
    public static void test2()
    {
        Test.startTest();
        Map<string,string> resultMap = new Map<string,string>();
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = 'testAccount';
        
        a.Phone = '1234567123';
        a.Dealer_Code__c = 'D12345';
        a.RecordTypeId = devRecordTypeId;
        a.OwnerId = u.Id;
        insert a;
        
        contact c1 = new Contact();
        c1.FirstName = 'First';
        c1.LastName = 'test contact';
        c1.mobilePhone = '1234567123';
        c1.email = 'test@contact.in';
        c1.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c1.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c1.Active__c = true;
        c1.AccountId = a.Id;
        insert c1;
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;       
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerAutoResponseEmail = false;       
        dmo.optAllOrNone = false;
        
       
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Associate (SA)' Limit 1];
        string nick = c1.email!=null?c1.email.substring(0, c1.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        User newUser1 = new User(alias=c1.firstName, email = c1.email, emailencodingkey = 'UTF-8', 
                                 firstname = c1.firstName, lastname = c1.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c1.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = c1.email,CommunityNickname = nick,ProfileId =portalProfile.Id, IsActive = true);
        newUser1.setOptions(dmo);
        insert newUser1;
        
       
        
        
        
        Service_Master__c sm = new Service_Master__c();
        sm.Service__c = 'SPS';
        sm.Skills__c = 'SPS';
        sm.Slot_Duration_in_Hours__c = 1.00;
        insert sm;
        
        Pincode__c pin = new Pincode__c();
        pin.Name = '123456';
        pin.City__c = 'AHMEDABAD';
        pin.Country__c = 'India';
        pin.Country_Code__c = 'IN';
        pin.Pincode_Ext__c = '123456';
        insert pin;
        
        SA_Pincode_Mapping__c pm = new SA_Pincode_Mapping__c();
        pm.Pincode__c = '123456';
        pm.Role__c = 'SA';
        pm.Priority__c = 1;
        pm.SA__c = c1.Id;
        pm.Service_Master__c = sm.Id;
        insert pm;
        
        REST_ServiceAbilityAPI.REST_Request rsa = new REST_ServiceAbilityAPI.REST_Request();
        rsa.pincode=pin.Name;
        REST_ServiceAbilityAPI.REST_Result result = REST_ServiceAbilityAPI.getDetails(rsa);
        
        
        System.assertEquals(result.message, 'Success');
        System.assertEquals(result.returnCode, '201');
        System.assertEquals(result.BHS_CES_flag, false);
        System.assertEquals(result.BHS_DA_flag, false);
        System.assertEquals(result.SPS_SA_flag, true);
        System.assertEquals(result.SPS_CA_flag, false);
        Test.stopTest();
    }

}