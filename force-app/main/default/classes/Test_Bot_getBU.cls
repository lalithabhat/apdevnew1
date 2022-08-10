@isTest
public class Test_Bot_getBU {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        List<Bot_getBU.PrechatInput> ipList = New List<Bot_getBU.PrechatInput>();
        Bot_getBU.PrechatInput c = new Bot_getBU.PrechatInput();
        c.BU = 'SPS'; 
        
        ipList.add(c);
        List<Bot_getBU.PrechatOutput> Docs = Bot_getBU.getBU(ipList);
        Test.stopTest();
    }
}