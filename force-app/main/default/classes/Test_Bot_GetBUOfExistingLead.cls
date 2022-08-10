@isTest
public class Test_Bot_GetBUOfExistingLead {
    Public static testMethod void doTest1() {
        Test.startTest();
        Id createBotLeadID = AP_BotManagementServices.createBotLead('Test','2401202201','t.2401202201@stetig.in','441904','SPS');
        
        List<Bot_GetBUOfExistingLead.PrechatInput> ipList = New List<Bot_GetBUOfExistingLead.PrechatInput>();
        Bot_GetBUOfExistingLead.PrechatInput c = new Bot_GetBUOfExistingLead.PrechatInput();
        c.leadId = createBotLeadID;
        
        ipList.add(c);
        List<Bot_GetBUOfExistingLead.PrechatOutput> Docs = Bot_GetBUOfExistingLead.GetBUOfExistingLead(ipList);
        Test.stopTest();
    }
}