@isTest
public class Test_Bot_CreateMessagingUser {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        insert l;
        
        List<Bot_CreateMessagingUser.PrechatInput> ipList = New List<Bot_CreateMessagingUser.PrechatInput>();
        Bot_CreateMessagingUser.PrechatInput c = new Bot_CreateMessagingUser.PrechatInput();
        c.leadId = l.Id; 
        
        ipList.add(c);
        List<Bot_CreateMessagingUser.PrechatOutput> Docs = Bot_CreateMessagingUser.CreateMessagingUser(ipList);
        Test.stopTest();
    }
}