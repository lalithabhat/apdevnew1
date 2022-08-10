@isTest
public class Test_Bot_updateCheckpoint {
    Public static testMethod void doTest1() {
        Test.startTest();
  
        List<Bot_updateCheckpoint.PrechatInput> ipList = New List<Bot_updateCheckpoint.PrechatInput>();
        Bot_updateCheckpoint.PrechatInput c = new Bot_updateCheckpoint.PrechatInput();
        c.InputCheckpoint = 'Initiate'; 
        
        ipList.add(c);
        List<Bot_updateCheckpoint.PrechatOutput> Docs = Bot_updateCheckpoint.updateCheckpoint(ipList);
        Test.stopTest();
    }
}