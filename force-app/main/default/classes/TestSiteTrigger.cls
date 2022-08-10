//For disabling the standard site trigger in Project package
@isTest
public class TestSiteTrigger {

    @isTest
    static void test(){
         milestone1_project__c site = new milestone1_project__c(
                Name ='Test',
                Kickoff__c = Date.today(),
                Deadline__c = Date.today() +5,
                New_Service__c = 'SPS',
               	Reason__c = 'First Site',
               Status__c ='Active');
                
            insert site;
    }
}