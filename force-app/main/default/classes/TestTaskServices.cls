@isTest
public class TestTaskServices {
    @isTest
    public static void callLogService() {
        TestDataSetup.enableApplicationLog();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead leadA = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CallUpdate/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        	// Set mock callout class 
            Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGeneratorForCTI());
            
            Task t = new Task();
            t.Subject = 'Call';
            t.ActivityDate = system.today();
            t.CallType = 'Outbound';
            t.Mobile__c = leadA.MobilePhone;
            t.OwnerId = UserInfo.getUserId();
            t.Priority = 'Normal';
            t.Service__c = 'SPS';
            t.Status = 'Completed';
            t.Type = 'Call';
            t.WhoId = leadA.Id;
            t.Disposition__c = 'SPS - Call Back';
            t.Sub_Disposition__c = '1377';
            t.Description = 'Test Call';
            insert t;
            
        	Task t1 = new Task();
            t1.Subject = 'Call';
            t1.ActivityDate = system.today();
            t1.CallType = 'Outbound';
            //t1.Mobile__c = leadA.MobilePhone;
            t1.OwnerId = UserInfo.getUserId();
            t1.Priority = 'Normal';
            t1.Service__c = 'SPS';
            t1.Status = 'Completed';
            t1.Type = 'Call';
            t1.WhoId = leadA.Id;
            //t1.Disposition__c = 'SPS - Call Back';
            //t1.Sub_Disposition__c = '1377';
            t1.Follow_Up_DateTime__c = system.now().addDays(1);
            t1.Description = 'Test Call';
        	t1.Self_Callback__c = true;
            insert t1;
        
            //Success Scenario
            REST_CallUpdate callReq = new REST_CallUpdate();
            REST_CallUpdate.REST_Request req1 = new REST_CallUpdate.REST_Request();
            req1.SFDC_LEAD_ID = leadA.Id;
            req1.SFDC_TASK_ID = t.Id;
            req1.CALL_RECORDING = 'www.call.com/123';
            req1.CALL_DURATION = '120';
            req1.CALL_START_TIME = '11:00 AM';
            req1.CALL_END_TIME = '11:02 AM';
            req1.REQUEST_NO = '123';
            req1.CALL_TYPE = 'Outbound';
            req1.AGENT_ID = '123';
            REST_CallUpdate.callUpdate(req1);
            
            //Error Scenario
            REST_CallUpdate.REST_Request req2 = new REST_CallUpdate.REST_Request();
            req1.SFDC_LEAD_ID = '';
            req1.SFDC_TASK_ID = t.Id;
            req1.CALL_RECORDING = 'www.call.com/123';
            req1.CALL_DURATION = '120';
            req1.CALL_START_TIME = '11:00 AM';
            req1.CALL_END_TIME = '11:02 AM';
            req1.REQUEST_NO = '123';
            req1.CALL_TYPE = 'Outbound';
            req1.AGENT_ID = '123';
            REST_CallUpdate.callUpdate(req2);
            
            //Error Scenario
            REST_CallUpdate.REST_Request req3 = new REST_CallUpdate.REST_Request();
            req3.SFDC_LEAD_ID = leadA.Id;
            req3.SFDC_TASK_ID = '12233';
            req3.CALL_RECORDING = 'www.call.com/123';
            req3.CALL_DURATION = '120';
            req3.CALL_START_TIME = '11:00 AM';
            req3.CALL_END_TIME = '11:02 AM';
            req3.REQUEST_NO = '123';
            req3.CALL_TYPE = 'Outbound';
            req3.AGENT_ID = '123';
            REST_CallUpdate.callUpdate(req3);
        Test.stopTest();
    }
    
    @isTest
    public static void NCTCallService() {
        TestDataSetup.enableApplicationLog();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead leadA = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
        Account acc = TestDataSetup.createAccountTemplate('TestPA', 'testlead@twgtest.com', '9876544441');
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/CallBackNCT/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
            List<REST_CallBackNCT.REST_Request> req1List = new List<REST_CallBackNCT.REST_Request>();
            REST_CallBackNCT.createCall(req1List);
            REST_CallBackNCT.REST_Request req1 = new REST_CallBackNCT.REST_Request();
            req1.SFDC_LEAD_ID = leadA.Id;
            req1.SERVICE_ID = '1234';
            req1.MOBILE_NO = leadA.MobilePhone;
            req1.CALL_TIME = '11:00 AM';
            req1.DISPOSITION = 'NCT';
            req1List.add(req1);
            REST_CallBackNCT.createCall(req1List);
        
            List<REST_CallBackNCT.REST_Request> reqList2 = new List<REST_CallBackNCT.REST_Request>();
            REST_CallBackNCT.REST_Request req2 = new REST_CallBackNCT.REST_Request();
            req2.SFDC_LEAD_ID = '';
            req2.SERVICE_ID = '1234';
            req2.MOBILE_NO = leadA.MobilePhone;
            req2.CALL_TIME = '11:00 AM';
            req2.DISPOSITION = 'NCT';
            reqList2.add(req2);
            REST_CallBackNCT.createCall(reqList2);
        
            List<REST_CallBackNCT.REST_Request> reqList3 = new List<REST_CallBackNCT.REST_Request>();
            REST_CallBackNCT.REST_Request req3 = new REST_CallBackNCT.REST_Request();
            req3.SFDC_LEAD_ID = acc.Id;
            req3.SERVICE_ID = '1234';
            req3.MOBILE_NO = leadA.MobilePhone;
            req3.CALL_TIME = '11:00 AM';
            req3.DISPOSITION = 'NCT';
            reqList3.add(req3);
            REST_CallBackNCT.createCall(reqList3);
        Test.stopTest();
    }
}