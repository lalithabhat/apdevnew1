@isTest
public class TestREST_UpdateCase {
    @isTest
    public static void successCaseUpdate() {
        TestDataSetup.enableApplicationLog();
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Id recCaseId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '1233211233', Pincode__c = '333333', OwnerId = spsSetupMap.get('CES USER'), OTP_Verified__c = true);
        insert leadA;
        Case c = new Case(RecordTypeId = recCaseId, Subject = 'Test Case', Status = 'New', Origin = 'Email', Priority = 'Low',
                          Responsibility_of_Complaint__c = 'BHS', L1_Category__c = 'Predesign Complaint', L2_Category__c = 'Service Related',
                          L3_Category__c = 'CSO behavior related');
        insert c;
        
        List<Case> caseList = [Select Id, CaseNumber from Case where Id =: c.Id];
        
        List<Case_Management_Code__c> codeList = new List<Case_Management_Code__c>();
        codeList.add(new Case_Management_Code__c(Name = 'BHS', Type__c = 'complaintDivision', Value__c = 'BHS', Code__c = '01'));
        codeList.add(new Case_Management_Code__c(Name = 'Email', Type__c = 'complaintSource', Value__c = 'Email', Code__c = '13'));
        codeList.add(new Case_Management_Code__c(Name = 'Assign to CSO', Type__c = 'complaintStatus', Value__c = 'Assign to CSO', Code__c = 'E0001'));
        codeList.add(new Case_Management_Code__c(Name = 'CAC Completed', Type__c = 'complaintStatus', Value__c = 'CAC Completed', Code__c = 'E0004'));
        codeList.add(new Case_Management_Code__c(Name = 'Predesign Complaint', Type__c = 'complaintType', Value__c = 'Predesign Complaint', Code__c = '01'));
        insert codeList;
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UpdateCase/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            REST_UpdateCase.CaseDetails('', 'E0002', '12345', 'Test Comment');
            REST_UpdateCase.CaseDetails(caseList[0].CaseNumber, '', '12345', 'Test Comment');
            REST_UpdateCase.CaseDetails(caseList[0].CaseNumber, 'E0002', '', 'Test Comment');
            REST_UpdateCase.CaseDetails(caseList[0].CaseNumber, 'E0002', '12345', 'Test Comment');
        Test.stopTest();
    }
}