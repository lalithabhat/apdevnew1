@isTest
public class Test_Bot_BuinessHoursCheck {
    Public static testMethod void doTest1(){        
        Test.startTest();
        
        List<Bot_BuinessHoursCheck.PrechatInput> docC = New List<Bot_BuinessHoursCheck.PrechatInput>();
        Bot_BuinessHoursCheck.PrechatInput c = new Bot_BuinessHoursCheck.PrechatInput();
        c.sChatKey = 'abc';

        docC.add(c);
        
        List<Bot_BuinessHoursCheck.PrechatOutput> Docs = Bot_BuinessHoursCheck.BuinessHoursCheck(docC);
        Test.stopTest();
    }
}