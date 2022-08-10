@isTest
public class TestLeadServices {
    @isTest 
    public static void TestLeadDuplicateEmail() {
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead leadA = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
        
        Test.startTest();
            List<Lead> leadList = new List<Lead>();
            Lead lead1 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead A Duplicate', Email = 'testleada@twgtest.com', 
                                MobilePhone = '9876544044', Pincode__c = '111111');
            leadList.add(lead1);
            List<DupResultsDTO> d = LeadManagementServices.leadPreProcessing(leadList, 'WEB');
            Map<Boolean, String> resultMap = EnquiryManagementServices.leadProcessing(d, leadList, 'Lead');
        Test.stopTest();
    }
    
    @isTest 
    public static void TestLeadDuplicateMobile() {
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead leadA = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
        
        Test.startTest();
            List<Lead> leadList = new List<Lead>();
            Lead lead1 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead A Duplicate', Email = 'testlead@twgtest.com', 
                                MobilePhone = '9876544000', Pincode__c = '111111');
            leadList.add(lead1);
            List<DupResultsDTO> d = LeadManagementServices.leadPreProcessing(leadList, 'WEB');
            Map<Boolean, String> resultMap = EnquiryManagementServices.leadProcessing(d, leadList, 'Lead');
        Test.stopTest();
    }
    
    @isTest 
    public static void TestAccountDuplicateMobile() {
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Account acc = TestDataSetup.createAccountTemplate('TestPA', 'testleada@twgtest.com', '9876544441');
        
        Test.startTest();
            List<Lead> leadList = new List<Lead>();
            Lead lead1 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead A Duplicate', Email = 'testlead@twgtest.com', 
                                MobilePhone = '9876544441', Pincode__c = '111111');
            leadList.add(lead1);
            
            List<DupResultsDTO> d = LeadManagementServices.leadPreProcessing(leadList, 'WEB');
            Map<Boolean, String> resultMap = EnquiryManagementServices.leadProcessing(d, leadList, 'Lead');
            Map<Boolean, String> resultMapBot = EnquiryManagementServices.leadProcessingBot(d, leadList);
        Test.stopTest();
    }
    
    @isTest 
    public static void TestAccountDuplicateEmail() {
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Account acc = TestDataSetup.createAccountTemplate('TestPA', 'testleada@twgtest.com', '9876544441');
        
        Test.startTest();
            List<Lead> leadList = new List<Lead>();
            Lead lead1 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead A Duplicate', Email = 'testleada@twgtest.com', 
                                MobilePhone = '9876544400', Pincode__c = '111111');
            leadList.add(lead1);
            
            List<DupResultsDTO> d = LeadManagementServices.leadPreProcessing(leadList, 'WEB');
            Map<Boolean, String> resultMap = EnquiryManagementServices.leadProcessing(d, leadList, 'Lead');
        Test.stopTest();
    }
    
    @isTest 
    public static void TestLeadDuplicateMultiple() {
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead leadA = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
        Lead leadB = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead B', 'testleadb@twgtest.com', '9876544001', '111111');
        
        Test.startTest();
            List<Lead> leadList = new List<Lead>();
            Lead lead1 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead A Duplicate', Email = 'testleada@twgtest.com', 
                                MobilePhone = '9876544001', Pincode__c = '111111');
            leadList.add(lead1);
            List<DupResultsDTO> d = new List<DupResultsDTO>();
            Map<Boolean, String> resultMap = new Map<Boolean, String>();
            try {
                d = LeadManagementServices.leadPreProcessing(leadList, 'WEB');
                resultMap = EnquiryManagementServices.leadProcessing(d, leadList, 'Lead');
            } catch (GlobalException ex) {
                System.debug('Global exception:' + ex.getMessage());
            }
        Test.stopTest();
    }
    
    @isTest 
    public static void TestAccountDuplicateMultiple() {
        Campaign c = TestDataSetup.createCampaign('SPS', 'SPS');
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Account accA = TestDataSetup.createAccountTemplate('TestPAa' , 'testpa1@twgtest.com', '9876544444');
        Account accB = TestDataSetup.createAccountTemplate('TestPAb' , 'testpa2@twgtest.com', '9876544443');
        
        Test.startTest();
            List<Lead> leadList = new List<Lead>();
            Lead lead1 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead A Duplicate', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '9876544443', Pincode__c = '111111');
            leadList.add(lead1);
            
            List<DupResultsDTO> d = LeadManagementServices.leadPreProcessing(leadList, 'WEB');
            Map<Boolean, String> resultMap = EnquiryManagementServices.leadProcessing(d, leadList, 'Lead');
        Test.stopTest();
    }
    
    @isTest
    public static void TestLeadDuplicateBulk() {
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead leadA = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testpa1@twgtest.com', '9876544443', '111111');
        Test.startTest();
            List<Lead> leadList = new List<Lead>();
            Lead lead1 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead A', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '9876544443', Pincode__c = '111111');
            leadList.add(lead1);
            Lead lead2 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead B', Email = 'testpa2@twgtest.com', 
                                MobilePhone = '9876544444', Pincode__c = '111111');
            leadList.add(lead2);
            List<DupResultsDTO> d = LeadManagementServices.leadPreProcessing(leadList, 'BULKLOAD');
        
            GlobalException obj = new GlobalException(); 
            obj.getErrorMsg();
            obj.getErrorCode();
            obj.getClassDetails();
            List<String> sList = new List<String>();
            GlobalException obj1 = new GlobalException(sList, '', '');
            Map<String,Set<Id>> duplicatesMap = new Map<String,Set<Id>>();
            DupResultsDTO obj2 = new DupResultsDTO(lead2, null, null, duplicatesMap);
            ServiceabilityManagement.createCrossLead(lead2, 'BHS', '', '', false);
        Test.stopTest();
    }
    
    @isTest
    public static void validationErrorLead() {
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Test.startTest();
            List<Lead> leadList = new List<Lead>();
            Lead lead1 = new Lead(RecordTypeId = recId, FirstName = 'Test1', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '9876544443', Pincode__c = '111111');
            leadList.add(lead1);
            Lead lead2 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = '', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '9876544443', Pincode__c = '111111');
            leadList.add(lead2);
            Lead lead3 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead2', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '9876544443', Pincode__c = '111111');
            leadList.add(lead3);
            Lead lead4 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '', Pincode__c = '111111');
            leadList.add(lead4);
            Lead lead5 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = 'aaaa', Pincode__c = '111111');
            leadList.add(lead5);
            Lead lead6 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '6677', Pincode__c = '111111');
            leadList.add(lead6);
            Lead lead7 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1twgtest.com', 
                                MobilePhone = '9876544443', Pincode__c = '111111');
            leadList.add(lead7);
            Lead lead8 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '9876544443', Pincode__c = '111111', Referral_Type__c = 'Customer');
            leadList.add(lead8);
            Lead lead9 = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '9876544443', Pincode__c = '1111111');
            leadList.add(lead9);
            Map<Id, String> leadValidationMap = LeadManagementServices.validateLeadDetails(leadList);
        Test.stopTest();
    } 
    
    @isTest 
    public static void TestLeadServiceability() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recBHSId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Id recSleekId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SLEEK').getRecordTypeId();
        Test.startTest(); 
            Lead leadA = TestDataSetup.createLeadTemplate(recBHSId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
            Lead leadB = TestDataSetup.createLeadTemplate(recBHSId, 'Test', 'Lead B', 'testleada@twgtest.com', '9876544000', '222222');
            Lead leadC = TestDataSetup.createLeadTemplate(recBHSId, 'Test', 'Lead C', 'testleadc@twgtest.com', '9876544022', '333333');
            Lead leadD = TestDataSetup.createLeadTemplate(recSleekId, 'Test', 'Lead D', 'testleadd@twgtest.com', '9876544011', '222222');
            Boolean b1 = ServiceabilityManagement.getLeadServiceableFromBot('111111', 'SPS');
            Boolean b2 = ServiceabilityManagement.getLeadServiceableFromBot('111112', 'SPS');
            Boolean b3 = ServiceabilityManagement.IsExistingLeadAvailable('111111', 'SPS', '9876544000');
            Boolean b4 = ServiceabilityManagement.IsExistingLeadAvailable('111112', 'SPS', '9876544000');
        Test.stopTest();
    }
    
    @isTest
    public static void TestAODDetail() {
        Campaign c = TestDataSetup.createCampaign('SPS', 'SPS');
        TestDataSetup.createAODSetup(c);
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        TestDataSetup.enableApplicationLog();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Id recBHSId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Id recSLEEKId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SLEEK').getRecordTypeId();
        Lead leadAa = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
        Test.startTest();
        	// Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGeneratorForCTI());
        	
            convertlead.ResponseWrapper res3 = convertlead.convert(null);
            Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com',Inter_Related_BU_1__c=leadAa.id,
                                MobilePhone = '1233211233', Pincode__c = '111111', CampaignName__c = c.Id, OwnerId = spsSetupMap.get('CA USER'));
            insert leadA;
            convertlead.ResponseWrapper res = convertlead.convert(leadA.Id);
            //leadA.MobilePhone = '1233211234';
            leadA.OTP_Verified__c = true;
            leadA.Street = 'Range Hills';
            leadA.City = 'Pune';
            leadA.State = 'Maharashtra';
            leadA.Country = 'India';
            leadA.PostalCode = '111111';
            update leadA;
            convertlead.ResponseWrapper res1 = convertlead.convert(leadA.Id);
        
            Lead leadB = new Lead(RecordTypeId = recBHSId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa2@twgtest.com', 
                                MobilePhone = '1233211235', Pincode__c = '333333', CampaignName__c = c.Id, Lead_In_Calling_Queue__c = true);
            insert leadB;
        	leadB.Street = 'Range Hills';
            leadB.OwnerId = spsSetupMap.get('CES USER');
            leadB.Status = 'Allocation Done';
            update leadB;
            
            Lead_Service__c l = new Lead_Service__c(Name = 'SLEEK');
            insert l;
            Lead leadC = new Lead(RecordTypeId = recSLEEKId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa3@twgtest.com', 
                                MobilePhone = '1233211231', Pincode__c = '333333', Skills__c = 'SLEEK');
            insert leadC;
            leadC.Pincode__c = '111111';
            update leadC;
            leadC.Dealer__c = spsSetupMap.get('DEALER');
            leadC.Status = 'Allocation Done';
            update leadC;
        Test.stopTest();
    }
    
    @isTest
    public static void TestAODDetailFail() {
        Campaign c = TestDataSetup.createCampaign('SPS', 'SPS');
        TestDataSetup.createAODSetup(c);
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        TestDataSetup.enableApplicationLog();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Id recBHSId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Id recSLEEKId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SLEEK').getRecordTypeId();
        Lead leadAa = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
        Test.startTest();
        	// Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGeneratorForCTIIssue());
        	
            convertlead.ResponseWrapper res3 = convertlead.convert(null);
            Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com',Inter_Related_BU_1__c=leadAa.id, 
                                MobilePhone = '1233211233', Pincode__c = '111111', CampaignName__c = c.Id, OwnerId = spsSetupMap.get('CA USER'), Whatsapp_Notification__c = true);
            insert leadA;
            convertlead.ResponseWrapper res = convertlead.convert(leadA.Id);
            //leadA.MobilePhone = '1233211234';
            leadA.OTP_Verified__c = true;
            leadA.Street = 'Range Hills';
            leadA.City = 'Pune';
            leadA.State = 'Maharashtra';
            leadA.Country = 'India';
            leadA.PostalCode = '111111';
            update leadA;
            convertlead.ResponseWrapper res1 = convertlead.convert(leadA.Id);
        
            Lead leadB = new Lead(RecordTypeId = recBHSId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa2@twgtest.com', 
                                MobilePhone = '1233211235', Pincode__c = '333333', CampaignName__c = c.Id, Lead_In_Calling_Queue__c = true) ;
            insert leadB;
        	leadB.Street = 'Range Hills';
            leadB.OwnerId = spsSetupMap.get('CES USER');
            leadB.Status = 'Allocation Done';
            update leadB;
            
            Lead_Service__c l = new Lead_Service__c(Name = 'SLEEK');
            insert l;
            Lead leadC = new Lead(RecordTypeId = recSLEEKId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa3@twgtest.com', 
                                MobilePhone = '1233211231', Pincode__c = '333333', Skills__c = 'SLEEK');
            insert leadC;
            leadC.Pincode__c = '111111';
            update leadC;
            leadC.Dealer__c = spsSetupMap.get('DEALER');
            leadC.Status = 'Allocation Done';
            update leadC;
        Test.stopTest();
    }
    
    @isTest
    public static void sleekAppIntegration() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        TestDataSetup.enableApplicationLog();
        Id recSLEEKId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SLEEK').getRecordTypeId();
        
        Test.startTest();
        	Lead_Service__c l = new Lead_Service__c(Name = 'SLEEK');
            insert l;
        	// Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGeneratorForSleek());
        
        	Lead leadC = new Lead(RecordTypeId = recSLEEKId, FirstName = 'Test', LastName = 'Lead', Email = 'testlead@twgtest.com', 
                                 MobilePhone = '1233211231', Pincode__c = '333333', Street = 'Oscar Street', City = 'Pune', State = 'Maharashtra',
                                 Country = 'India', Referral_Type__c = 'Customer', Referrer_Name__c = 'Customer New', Referrer_Mobile__c = '1221122112');
            insert leadC;
        	leadC.Dealer__c = spsSetupMap.get('DEALER');
            leadC.Status = 'Allocation Done';
            update leadC;
        Test.stopTest();
    }
    
    @isTest
    public static void bhsAppIntegration() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        TestDataSetup.enableApplicationLog();
        Id recBHSId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        
        Test.startTest();
        	// Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGeneratorForBHS());
        	
        	Lead leadB = new Lead(RecordTypeId = recBHSId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa2@twgtest.com', 
                                MobilePhone = '1233211235', Pincode__c = '333333');
            insert leadB;
        	leadB.Street = 'Range Hills';
            leadB.OwnerId = spsSetupMap.get('CES USER');
            leadB.Status = 'Allocation Done';
            update leadB;
        Test.stopTest();
    }
    
    @isTest
    public static void C4CAppIntegration() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        TestDataSetup.enableApplicationLog();
        Id recSPSId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        Test.startTest();
        	Lead leadA = new Lead(RecordTypeId = recSPSId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '1233211233', Pincode__c = '111111', Integration_Source__c = 'C4C');
            insert leadA;
        	leadA.Status = 'Allocation Done';
        	leadA.OwnerId = spsSetupMap.get('CA USER');
        	leadA.Dealer__c = spsSetupMap.get('DEALER');
        	update leadA;
        Test.stopTest();
    }
    
    @future
    public static void insertUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='Manager'];
        User futureUser = new User(firstname = 'Future', lastname = 'User',
            alias = 'future', defaultgroupnotificationfrequency = 'N',
            digestfrequency = 'N', email = 'test@test.org',
            emailencodingkey = 'UTF-8', languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, 
            timezonesidkey = 'America/Los_Angeles',
            username = 'userfuture1@test.org',
            userpermissionsmarketinguser = false,
            userpermissionsofflineuser = false, userroleid = r.Id);
        insert(futureUser);
    }
    
    @isTest
    public static void userManagement() {
        insertUser();
        User u = [Select Id, Name, IsActive from User ORDER BY CreatedDate DESC LIMIT 1];
        u.IsActive = false;
        update u;
    }
}