@isTest
public class Test_LeadBatch {
    @isTest
    
    static void testLeadBatch(){
        Test.startTest();
         Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
      
        Lead l  = TestDataFactory.createLead('8000090000', 'email@email.com', '111111', Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SPS').getRecordTypeId(), null);
      	l.Inactive_Customer_Marked_On__c = Date.today()-1;
        l.Inactive_Customer__c =true;
        update l;
        Lead l2  = TestDataFactory.createLead('8000010000', 'email1@email.com', '111111', Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SPS').getRecordTypeId(), null);
      	l2.Appointment_Cancelled_On__c = Date.today();
        l2.Last_Appointment_Start_Date_Time__c = Date.today() -2;
        update l2;
         Lead l3  = TestDataFactory.createLead('8100090000', 'email2@email.com', '111111', Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SPS').getRecordTypeId(), null);
      	l3.Call_Later_marked_on__c = Date.today()-1;
        l3.Call_Later__c =true;
        update l3;
        
        LeadSchedulerOnceAWeek sh1 = new LeadSchedulerOnceAWeek();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Schedule', sch, sh1); 
       
        LeadSchedulerTwiceAWeek sh2 = new LeadSchedulerTwiceAWeek();
		system.schedule('Schedule1', sch, sh2); 
        Test.stopTest(); 
    }
    
    @isTest
    static void testCDPBatch(){
        Test.startTest();
         Lead l  = TestDataFactory.createLead('1234567890', 'email@email.com', '111111', Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SPS').getRecordTypeId(), null);
      	Account a =TestDataFactory.createPersonAccount('1244567890', 'email2@email.com');
        CDP_Customer_Data__c cdp = new CDP_Customer_Data__c(Lead_Score__c =34,Mobile_Number__c =1234567890);
        insert cdp;
        CDP_Customer_Data__c cdp2 = new CDP_Customer_Data__c(Lead_Score__c =34,Mobile_Number__c =1244567890);
        insert cdp2;
        CDPScheduler sh1 = new CDPScheduler();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Schedule', sch, sh1); 
        Test.stopTest();
    }

}