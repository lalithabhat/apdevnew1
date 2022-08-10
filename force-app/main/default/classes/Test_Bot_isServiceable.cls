@isTest
public class Test_Bot_isServiceable {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        List<Bot_isServiceable.PrechatInput> ipList = New List<Bot_isServiceable.PrechatInput>();
        Bot_isServiceable.PrechatInput c = new Bot_isServiceable.PrechatInput();
        c.Pincode = '333333'; 
        c.BU = 'BHS';
        
        ipList.add(c);
        List<Bot_isServiceable.PrechatOutput> Docs = Bot_isServiceable.isServiceable(ipList);
        Test.stopTest();
    }
}