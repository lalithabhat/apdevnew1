@isTest
public class Test_LeadAutoDropBatch {

     @isTest
    static void testCDPBatch(){
        

        
        Lead l  = TestDataFactory.createLead('1234567890', 'email@email.com', '111111', Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SPS').getRecordTypeId(), null);
      	Task t = new Task();
        t.WhoId = l.Id;
        t.Service__c ='SPS';
        t.Disposition__c ='SPS - Unsuccesful / Lead drop reasons';
        t.Sub_Disposition__c ='Not_Interested';
        insert t;
        testDataSetup.enableApplicationLog();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGeneratorForCTI());
          
        LeadAutoDrop_Scheduler sh1 = new LeadAutoDrop_Scheduler();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Schedule', sch, sh1); 
        Test.stopTest();
    }
   
}