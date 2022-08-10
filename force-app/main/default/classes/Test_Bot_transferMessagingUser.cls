@isTest
public class Test_Bot_transferMessagingUser {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l1 = new Lead();
        l1.LastName = 'Test Lead A';
        l1.Email = 'testLead.1@gmail.com';
        l1.MobilePhone = '1234567890';
        insert l1;
        
        Lead l2 = new Lead();
        l2.LastName = 'Test Lead B';
        l2.Email = 'testLead.2@gmail.com';
        l2.MobilePhone = '2234567890';
        insert l2;
        
        List<Bot_transferMessagingUser.PrechatInput> ipList = New List<Bot_transferMessagingUser.PrechatInput>();
        Bot_transferMessagingUser.PrechatInput c = new Bot_transferMessagingUser.PrechatInput();
        c.previousLeadId = l1.Id; 
        c.currentLeadId = l2.Id; 
        
        ipList.add(c);
        List<Bot_transferMessagingUser.PrechatOutput> Docs = Bot_transferMessagingUser.transferMessagingUser(ipList);
        Test.stopTest();
    }
}