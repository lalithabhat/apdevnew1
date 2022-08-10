@isTest
public class TestCaseServices {
    @isTest
    public static void leadSPSRelatedCase() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
         
        Map<String, Set<String>> servicePincodeMap = new Map<String, Set<String>>();
        Set<String> pincodeSet = new Set<String>();
        pincodeSet.add('111111');
        servicePincodeMap.put('SPS', pincodeSet);
        List<Service_Territory__c> serviceTerritoryList = [Select Id, Name, Type__c, Pincode__c, Pincode__r.Name, Parent__r.Id, Parent__r.Name,
                                                           Parent__c, Parent__r.HOD__c, Parent__r.HOD__r.PositionID__c, Parent__r.Type__c, 
                                                           Parent__r.Parent__c, Parent__r.Parent__r.HOD__c, Parent__r.Parent__r.HOD__r.PositionID__c, Parent__r.Parent__r.Type__c,
                                                           Parent__r.Parent__r.Parent__c, Parent__r.Parent__r.Parent__r.HOD__c, Parent__r.Parent__r.Parent__r.HOD__r.PositionID__c, Parent__r.Parent__r.Parent__r.Type__c,
                                                           Parent__r.Parent__r.Parent__r.Parent__c, Parent__r.Parent__r.Parent__r.Parent__r.HOD__c, Parent__r.Parent__r.Parent__r.Parent__r.HOD__r.PositionID__c, Parent__r.Parent__r.Parent__r.Parent__r.Type__c
                                                           from Service_Territory__c
                                                           where Pincode__r.Name IN: pincodeSet AND Type__c = 'Pincode' AND Active__c = true AND
                                                           Parent__r.Parent__r.Parent__r.Parent__r.Name = 'SPS' AND Parent__r.Parent__r.Parent__r.Parent__r.Type__c = 'Service'];
        
      system.debug('service territory : '+ serviceTerritoryList);
        system.debug('######################### in test class hods '+ AP_ServiceTerritoryManagementService.getHODForSPS(servicePincodeMap.get('SPS')));
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Id recCaseId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        Test.startTest();
            Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '1233211233', Pincode__c = '111111', OwnerId = spsSetupMap.get('CA USER'), OTP_Verified__c = true);
            insert leadA;
            system.assert(leadA.TL1__c == null);
        
            Case c = new Case(RecordTypeId = recCaseId, Subject = 'Test Case', Status = 'New', Origin = 'Email', Priority = 'Low',
                             L1_Category__c = 'Presales', L2_Category__c = 'Helpline Related');
            insert c;
            c.Lead__c = leadA.Id;
            c.OwnerId = spsSetupMap.get('CA USER');
        	c.Pincode__c = '111111';
            update c;
            system.assert(c.Team_Lead_1_TL1__c == null);
        Test.stopTest();
    }
    
    @isTest
    public static void oppSPSRelatedCase() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Id recCaseId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        Test.startTest();
            Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '1233211233', Pincode__c = '111111', OwnerId = spsSetupMap.get('CA USER'), OTP_Verified__c = true);
            insert leadA;
            system.assert(leadA.TL1__c == null);
            convertlead.ResponseWrapper res1 = convertlead.convert(leadA.Id);
            List<Opportunity> op = APIMangementServices.getOpportunityRecord(leadA.Id);
        
            Case c = new Case(RecordTypeId = recCaseId, Subject = 'Test Case', Status = 'New', Origin = 'Email', Priority = 'Low',
                             L1_Category__c = 'Presales', L2_Category__c = 'Helpline Related', AccountId = op[0].AccountId,
                             Opportunity__c = op[0].Id);
            insert c;
            c.OwnerId = spsSetupMap.get('CA USER');
            update c;
            system.assert(c.Team_Lead_1_TL1__c == null);
        Test.stopTest();
    }
    
    @isTest
    public static void oppSPSRelatedCase2() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Id recCaseId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        Test.startTest();
            Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '1233211233', Pincode__c = '111111', OwnerId = spsSetupMap.get('CA USER'), OTP_Verified__c = true);
            insert leadA;
            system.assert(leadA.TL1__c == null);
            convertlead.ResponseWrapper res1 = convertlead.convert(leadA.Id);
            List<Opportunity> op = APIMangementServices.getOpportunityRecord(leadA.Id);
        
            Case c = new Case(RecordTypeId = recCaseId, Subject = 'Test Case', Status = 'New', Origin = 'Email', Priority = 'Low',
                             L1_Category__c = 'Presales', L2_Category__c = 'Helpline Related', AccountId = op[0].AccountId,
                             Opportunity__c = op[0].Id);
            insert c;
            c.OwnerId = spsSetupMap.get('CA USER');
            update c;
            system.assert(c.Team_Lead_1_TL1__c == null);
        Test.stopTest();
    }
    
    @isTest
    public static void leadBHSRelatedCase() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        TestDataSetup.enableApplicationLog();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Id recCaseId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        List<Case_Management_Code__c> codeList = new List<Case_Management_Code__c>();
		codeList.add(new Case_Management_Code__c(Name = 'BHS', Type__c = 'complaintDivision', Value__c = 'BHS', Code__c = '01'));
        codeList.add(new Case_Management_Code__c(Name = 'Email', Type__c = 'complaintSource', Value__c = 'Email', Code__c = '13'));
		codeList.add(new Case_Management_Code__c(Name = 'Assign to CSO', Type__c = 'complaintStatus', Value__c = 'Assign to CSO', Code__c = 'E0001'));
		codeList.add(new Case_Management_Code__c(Name = 'CAC Completed', Type__c = 'complaintStatus', Value__c = 'CAC Completed', Code__c = 'E0004'));
        codeList.add(new Case_Management_Code__c(Name = 'Predesign Complaint', Type__c = 'complaintType', Value__c = 'Predesign Complaint', Code__c = '01'));
		insert codeList;
		        
        Test.startTest();
        	// Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGeneratorForBHS());
        	
            Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com',Status = 'Allocation Done', Street ='Test',
                                MobilePhone = '1233211233', Pincode__c = '333333', OwnerId = spsSetupMap.get('CES USER'), OTP_Verified__c = true);
            insert leadA;
        
            Case c = new Case(RecordTypeId = recCaseId, Subject = 'Test Case', Status = 'New', Origin = 'Email', Priority = 'Low',
                             Responsibility_of_Complaint__c = 'BHS', L1_Category__c = 'Predesign Complaint', L2_Category__c = 'Service Related',
                             L3_Category__c = 'CSO behavior related');
            insert c;
            c.Lead__c = leadA.Id;
            update c;
            c.Status = 'Assign to CSO';
            update c;
            c.Status = 'CAC Completed';
            update c;
        Test.stopTest();
    }
}