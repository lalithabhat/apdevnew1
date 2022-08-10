@isTest
public class Test_Bot_getDate {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        insert l;
        
        List<Bot_getDate.PrechatInput> ipList = New List<Bot_getDate.PrechatInput>();
        Bot_getDate.PrechatInput c = new Bot_getDate.PrechatInput();
        c.leadId = l.Id; 
        
        ipList.add(c);
        List<Bot_getDate.PrechatOutput> Docs = Bot_getDate.getDate(ipList);
        Test.stopTest();
    }
}