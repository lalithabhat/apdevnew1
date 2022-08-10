@isTest
public class Test_EmailHandler {
    
    @isTest
    static void test(){
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
       // Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId),c.Id);
       
        Email_Parameters__c epara  = new Email_Parameters__c();
        epara.SetupOwnerId=UserInfo.getOrganizationId();
        epara.API_version__c = '1';
        epara.userName__c = 'userName';
        epara.password__c = 'password';
        epara.fromEmail__c = 'fromEMail@gmail.com';
        epara.fromName__c = 'fromName';
        epara.replyTo__c = 'replyTo@gmail.com';
        epara.Endpoint__c ='https://www.endpoint.com';
        insert epara;
        Contact con = new Contact(LastName = 'Test');
        insert con;
        Email_log__c el = new Email_log__c();
        el.email__c = 'abc@gmail.com';
        el.What_Id__c = con.Id;
        el.Email_Template__c ='Site_Health_Card';
        insert el;
          Email_log__c el1 = new Email_log__c();
        el1.email__c = 'abc@gmail.com';
        el1.What_Id__c = null;
        el1.Email_Template__c ='Site_Health_Card';
        insert el1;
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new Test_Email_Mock());
        Set<Id> emailSet = new Set<Id>{el.Id, el1.Id};
            
            EmailBatch myBatchObject = new EmailBatch(emailSet);
        EmailFuture.sendEmail(emailSet);
        Database.executeBatch(myBatchObject,2);
        
        Test.stopTest();
    }
}