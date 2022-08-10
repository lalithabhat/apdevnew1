@isTest
public class Test_Bot_AgentOrBotChat {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        List<Bot_AgentOrBotChat.PrechatInput> ipList = New List<Bot_AgentOrBotChat.PrechatInput>();
        Bot_AgentOrBotChat.PrechatInput c = new Bot_AgentOrBotChat.PrechatInput();
        c.ChatSource = 'Agent'; 
        
        ipList.add(c);
        List<Bot_AgentOrBotChat.PrechatOutput> Docs = Bot_AgentOrBotChat.AgentOrBotChat(ipList);
        Test.stopTest();
    }
}