@isTest
public class Test_Bot_LoopIncrement {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        List<Bot_LoopIncrement.PrechatInput> ipList = New List<Bot_LoopIncrement.PrechatInput>();
        Bot_LoopIncrement.PrechatInput c = new Bot_LoopIncrement.PrechatInput();
        c.LoopCounterValueInput = 1; 
        
        ipList.add(c);
        List<Bot_LoopIncrement.PrechatOutput> Docs = Bot_LoopIncrement.LoopIncrement(ipList);
        Test.stopTest();
    }
}