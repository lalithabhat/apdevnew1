@isTest
public class Test_Bot_storePreviousLeadId {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        insert l;
        
        List<Bot_storePreviousLeadId.PrechatInput> ipList = New List<Bot_storePreviousLeadId.PrechatInput>();
        Bot_storePreviousLeadId.PrechatInput c = new Bot_storePreviousLeadId.PrechatInput();
        c.previousLeadId = l.Id; 
        
        ipList.add(c);
        List<Bot_storePreviousLeadId.PrechatOutput> Docs = Bot_storePreviousLeadId.storePreviousLeadId(ipList);
        Test.stopTest();
    }
}