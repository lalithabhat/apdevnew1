@isTest
public class TestSMSClass {
    
    @isTest  
    private static void CallSMS1() {
        
        Vendor__c vend = new Vendor__c();
        vend.Name = 'Testsms';
        vend.Vendor_URL__c = 'http://perfectbulksms.co.in/Sendsmsapi.aspx';
        vend.Vendor_Status__c = true;
        
        vend.Param_1_Name__c = 'USERID';
        vend.Param_1_Status__c = true;
        vend.Param_1_Value__c = 'tatacrm';
        
        vend.Param_2_Name__c = 'PASSWORD';
        vend.Param_2_Status__c = true;
        vend.Param_2_Value__c = '63115155';
        
        vend.Param_3_Name__c = 'SENDERID';
        vend.Param_3_Status__c = true;
        vend.Param_3_Value__c = 'TEAMTH';
        
        //vend.Param_4_Name__c = 'dlr';
        vend.Param_4_Status__c = true;
        //vend.Param_4_Value__c = '1';
        
        //vend.Param_5_Name__c = 'destination';
        vend.Param_5_Status__c = true;
        
        vend.Param_6_Status__c = true;
        //vend.Param_6_Value__c = 'source';
        //vend.Param_6_Value__c = 'test';
        
        vend.Param_7_Name__c = 'TO';
        vend.Param_7_Status__c  = true;
        vend.Param_7_Value__c = '';
        
        
        vend.Param_8_Name__c = 'MESSAGE';
        vend.Param_8_Status__c = true;
        vend.Param_8_Value__c = '';
        insert vend;
        Test.startTest();
          Test.setMock(HttpCalloutMock.class, new Mock());
        
        SMS_Schedule_SMS_c__c s = new SMS_Schedule_SMS_c__c();
        s.Immediate__c = True;
        s.Sender_Mobile__c= '919823475883';
        s.SMS_Long_text__c= 'Message from test class';
        insert s;        
        Test.stopTest();
    }
    
     public class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            response.setBodyAsBlob(blob.valueOf('mock response'));
            return response;
        }
    }
}