@isTest
public class Test_Bot_updateBotJourney {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        insert l;
        
        List<Bot_updateBotJourney.PrechatInput> ipList = New List<Bot_updateBotJourney.PrechatInput>();
        Bot_updateBotJourney.PrechatInput c = new Bot_updateBotJourney.PrechatInput();
        c.leadId = l.Id; 
        c.BotJourneyValue = 'Initiate'; 
        
        ipList.add(c);
        List<Bot_updateBotJourney.PrechatOutput> Docs = Bot_updateBotJourney.updateLead(ipList);
        Test.stopTest();
    }
}