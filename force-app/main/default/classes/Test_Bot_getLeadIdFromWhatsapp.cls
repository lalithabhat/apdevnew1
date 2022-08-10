@isTest
public class Test_Bot_getLeadIdFromWhatsapp {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        insert l;
        
        List<Bot_getLeadIdFromWhatsapp.PrechatInput> ipList = New List<Bot_getLeadIdFromWhatsapp.PrechatInput>();
        Bot_getLeadIdFromWhatsapp.PrechatInput c = new Bot_getLeadIdFromWhatsapp.PrechatInput();
        c.whatsappNumberWithoutCode = '1234567890'; 
        
        ipList.add(c);
        List<Bot_getLeadIdFromWhatsapp.PrechatOutput> Docs = Bot_getLeadIdFromWhatsapp.getLeadId(ipList);
        Test.stopTest();
    }
}