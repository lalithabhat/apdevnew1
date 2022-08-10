@isTest
public class Test_Bot_appointmentSchedule {
Public static testMethod void doTest1() {
        Test.startTest();
        
        List<Bot_appointmentSchedule.PrechatInput> ipList = New List<Bot_appointmentSchedule.PrechatInput>();
        Bot_appointmentSchedule.PrechatInput c = new Bot_appointmentSchedule.PrechatInput();
        c.LeadId = ''; 
        c.contactId = ''; 
        c.dealerId = ''; 
        c.onlySlot = '01:00 PM - 04:00 PM'; 
        c.SelectedDate = Date.today(); 
        
        ipList.add(c);
        List<Bot_appointmentSchedule.PrechatOutput> Docs = Bot_appointmentSchedule.appointmentSchedule(ipList);
        Test.stopTest();
    }
}