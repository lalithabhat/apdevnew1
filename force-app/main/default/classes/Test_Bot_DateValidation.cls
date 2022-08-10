@isTest
public class Test_Bot_DateValidation {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        List<Bot_DateValidation.PrechatInput> ipList = New List<Bot_DateValidation.PrechatInput>();
        Bot_DateValidation.PrechatInput c = new Bot_DateValidation.PrechatInput();
        c.sDate = '02/02/2040'; 
        
        ipList.add(c);
        List<Bot_DateValidation.PrechatOutput> Docs = Bot_DateValidation.DateValidation(ipList);
        Test.stopTest();
    }
    Public static testMethod void doTest2() {
        Test.startTest();
        
        List<Bot_DateValidation.PrechatInput> ipList = New List<Bot_DateValidation.PrechatInput>();
        Bot_DateValidation.PrechatInput c = new Bot_DateValidation.PrechatInput();
        c.sDate = '02/02/2010'; 
        
        ipList.add(c);
        List<Bot_DateValidation.PrechatOutput> Docs = Bot_DateValidation.DateValidation(ipList);
        Test.stopTest();
    }
}