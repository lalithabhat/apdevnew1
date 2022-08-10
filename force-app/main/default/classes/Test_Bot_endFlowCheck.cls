@isTest
public class Test_Bot_endFlowCheck {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        List<Bot_endFlowCheck.PrechatInput> ipList = New List<Bot_endFlowCheck.PrechatInput>();
        Bot_endFlowCheck.PrechatInput c = new Bot_endFlowCheck.PrechatInput();
        c.Check = 'True'; 
        
        ipList.add(c);
        List<Bot_endFlowCheck.PrechatOutput> Docs = Bot_endFlowCheck.endFlowCheck(ipList);
        Test.stopTest();
    }
}