@isTest
public class Test_Bot_storeOriginalBU {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        List<Bot_storeOriginalBU.PrechatInput> ipList = New List<Bot_storeOriginalBU.PrechatInput>();
        Bot_storeOriginalBU.PrechatInput c = new Bot_storeOriginalBU.PrechatInput();
        c.originalBU = 'SPS'; 
        
        ipList.add(c);
        List<Bot_storeOriginalBU.PrechatOutput> Docs = Bot_storeOriginalBU.storeOriginalBU(ipList);
        Test.stopTest();
    }
}