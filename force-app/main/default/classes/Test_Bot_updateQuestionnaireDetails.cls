@isTest
public class Test_Bot_updateQuestionnaireDetails {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        insert l;
        
        List<Bot_updateQuestionnaireDetails.PrechatInput> ipList = New List<Bot_updateQuestionnaireDetails.PrechatInput>();
        Bot_updateQuestionnaireDetails.PrechatInput c = new Bot_updateQuestionnaireDetails.PrechatInput();
        c.leadId = l.Id; 
        c.Question1 = '1'; 
        c.Question2 = '1'; 
        c.Question3 = '1'; 
        c.Question4 = '1'; 
        
        ipList.add(c);
        List<Bot_updateQuestionnaireDetails.PrechatOutput> Docs = Bot_updateQuestionnaireDetails.updateQuestionnaireDetails(ipList);
        Test.stopTest();
    }
}