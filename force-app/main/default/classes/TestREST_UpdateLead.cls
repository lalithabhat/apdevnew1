@isTest
public class TestREST_UpdateLead {
    @isTest
    public static void successLeadUpdate() {
        TestDataSetup.enableApplicationLog();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead leadA = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
        Contact c = [Select Id, Name, MobilePhone, Email, Employee_Code__c, PositionID__c from Contact where Id =: spsSetupMap.get('CA CONTACT')];
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UpdateLead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            REST_UpdateLead.LeadDetails(leadA.Id, 'Follow Up', c.PositionID__c, c.Name, c.Email, c.Employee_Code__c, c.MobilePhone, '', '', '', 'Test Comment','45326.09');
            REST_UpdateLead.LeadDetails(leadA.Id, 'Converted', c.PositionID__c, c.Name, c.Email, c.Employee_Code__c, c.MobilePhone, '', '', '', 'Test Comment','51626');
        Test.stopTest();
    }
    
    @isTest
    public static void errorLeadUpdate() {
        TestDataSetup.enableApplicationLog();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead leadA = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
        Contact c = [Select Id, Name, MobilePhone, Email, Employee_Code__c, PositionID__c from Contact where Id =: spsSetupMap.get('CA CONTACT')];
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UpdateLead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            REST_UpdateLead.LeadDetails('', '', '', '', '', '', '', '', '', '', '','');
            REST_UpdateLead.LeadDetails(leadA.Id, '', '', '', '', '', '', '', '', '', '','');
            REST_UpdateLead.LeadDetails(leadA.Id, 'Follow Up', '', '', '', '', '', '', '', '', '','');
            REST_UpdateLead.LeadDetails(leadA.Id, 'Follow Up', C.PositionID__c, c.Name, c.Email, '', '', '', '', '', '','');
            REST_UpdateLead.LeadDetails(leadA.Id, 'Dropped', c.PositionID__c, c.Name, c.Email, c.Employee_Code__c, c.MobilePhone, '', '', '', 'Test Comment','76587');
            
        Test.stopTest();
    }
}