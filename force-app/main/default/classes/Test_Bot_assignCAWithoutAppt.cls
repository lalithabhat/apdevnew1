@isTest
public class Test_Bot_assignCAWithoutAppt {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        insert l;
        
        List<Bot_assignCAWithoutAppointmentApex.PrechatInput> ipList = New List<Bot_assignCAWithoutAppointmentApex.PrechatInput>();
        Bot_assignCAWithoutAppointmentApex.PrechatInput c = new Bot_assignCAWithoutAppointmentApex.PrechatInput();
        c.leadId = l.Id; 
        
        ipList.add(c);
        List<Bot_assignCAWithoutAppointmentApex.PrechatOutput> Docs = Bot_assignCAWithoutAppointmentApex.assignCAWithoutAppointmentApex(ipList);
        Test.stopTest();
    }
}