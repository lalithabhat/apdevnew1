@isTest
public class Test_AP_BotManagementServices {
    Public static testMethod void doTest1() {
        Test.startTest();
        Account a = TestDataSetup.createAccountTemplate('Test Account', 't.2401202201@stetig.in', '2401202201');
        Id createBotLeadID = AP_BotManagementServices.createBotLead('Test','2401202201','t.2401202201@stetig.in','441904','SPS','SPS');
        //Id CreateMessagingUserID = AP_BotManagementServices.CreateMessagingUser(createBotLeadID);
        //AP_BotManagementServices.InitiateJourney(createBotLeadID);
        Set<Id> s1 = new Set<Id>();
        s1.add(createBotLeadID);
        AP_BotManagementServices.InitiateJourney(s1);
        
        Id createBotLeadID2 = AP_BotManagementServices.createBotLead('Test','2401202201','t.2401202201@stetig.in','441904','SPS','SPS');
        //Id CreateMessagingUserID = AP_BotManagementServices.CreateMessagingUser(createBotLeadID);
        //AP_BotManagementServices.InitiateJourney(createBotLeadID);
        Set<Id> s2 = new Set<Id>();
        s2.add(createBotLeadID2);
        AP_BotManagementServices.InitiateJourney(s2);
        
        Id createBotLeadID3 = AP_BotManagementServices.createBotLead('Test','2401202201','t.2401202201@stetig.in','441904','BHS','BHS');
        //Id CreateMessagingUserID = AP_BotManagementServices.CreateMessagingUser(createBotLeadID);
        //AP_BotManagementServices.InitiateJourney(createBotLeadID);
        Set<Id> s3 = new Set<Id>();
        s3.add(createBotLeadID3);
        AP_BotManagementServices.InitiateJourney(s3);
        
        Test.stopTest();
        
    }
    Public static testMethod void doTest2() {
        Test.startTest();
        Id createBotLeadID = AP_BotManagementServices.createBotLead('Test','2401202201','t.2401202201@stetig.in','441904','SPS','SPS');
        Id createBotLeadID2 = AP_BotManagementServices.createBotLead('Test','2401202201','t.2401202201@stetig.in','441904','SPS','SPS');
        Set<Id> s1 = new Set<Id>();
        s1.add(createBotLeadID);
        s1.add(createBotLeadID2);
        AP_BotManagementServices.InitiateJourney(s1);

        Test.stopTest();
    }
Public static testMethod void doTest3() {
        Test.startTest();
        Id createBotLeadID = AP_BotManagementServices.createBotLead('Test','2401202201','t.2401202201@stetig.in','441904','General Enquiry','SPS');
        Id createBotLeadID2 = AP_BotManagementServices.createBotLead('Test','2401202201','t.2401202201@stetig.in','441904','General Enquiry','BHS');
        Set<Id> s1 = new Set<Id>();
        s1.add(createBotLeadID);
        s1.add(createBotLeadID2);
        AP_BotManagementServices.InitiateJourney(s1);

        Test.stopTest();
    }    
}