@isTest
public class Test_Bot_isQualified {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        insert l;
        
        List<Bot_isQualified.PrechatInput> ipList = New List<Bot_isQualified.PrechatInput>();
        Bot_isQualified.PrechatInput c = new Bot_isQualified.PrechatInput();
        c.leadId = l.Id; 
        
        ipList.add(c);
        List<Bot_isQualified.PrechatOutput> Docs = Bot_isQualified.isQualified(ipList);
        Test.stopTest();
    }
}