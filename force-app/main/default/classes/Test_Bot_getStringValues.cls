@isTest
public class Test_Bot_getStringValues {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        List<Bot_getStringValues.PrechatInput> ipList = New List<Bot_getStringValues.PrechatInput>();
        Bot_getStringValues.PrechatInput c = new Bot_getStringValues.PrechatInput();
        c.InputString = '1,2,3,4,5,6,7'; 
        
        ipList.add(c);
        List<Bot_getStringValues.PrechatOutput> Docs = Bot_getStringValues.getStringValues(ipList);
        Test.stopTest();
    }
}