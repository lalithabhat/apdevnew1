@isTest
public class Test_Bot_getSlot {
    Public static testMethod void doTest1() {
        
        Map<string,string> resultMap = TestDataFactory.createContact();
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
       
        Test.startTest();
        List<event> eventList = Get_SA_Available_Slot.isCalendarBlocked(l.Id);
        Lead lead = Get_SA_Available_Slot.getLead(l.Id);
        string st = Get_SA_Available_Slot.checkDateValidation(system.today());
        ScheduleAppointmentServices.UserWrapper uw = Get_SA_Available_Slot.getContactList(l.Id);
        List<ScheduleAppointmentServices.SlotWrapper> slots = Get_SA_Available_Slot.getSlots(uw.UserList[0].SA__c,'SA',system.today().addDays(1),l.Id);
        ScheduleAppointmentServices.SuccessWrapper sw = Get_SA_Available_Slot.bookSlot(l.Id, '10:00 AM - 11:00 AM', system.today().addDays(1), uw.UserList[0].SA__c, null, false, null);
        List<Event> event = [select id from event where whoId =: l.Id];
		ScheduleAppointmentServices.SuccessWrapper sw2 = Get_SA_Available_Slot.bookSlot(l.Id, '11:00 AM - 12:00 PM', system.today().addDays(1), uw.UserList[0].SA__c, null, true, event[0].Id);        
        List<ScheduleAppointmentServices.SlotWrapper> slots2 = Get_SA_Available_Slot.getSlots(uw.UserList[0].SA__c,'SA',system.today().addDays(1),l.Id);
        
        List<event> eventListAfter = Get_SA_Available_Slot.isCalendarBlocked(l.Id);
        system.assert(eventListAfter.size() >0);
        string msg = Get_SA_Available_Slot.deleteAppointment(eventListAfter[0].Id,l.Id);
        eventListAfter = Get_SA_Available_Slot.isCalendarBlocked(l.Id);
        system.assert(eventListAfter.size() == 0);
      
        List<Bot_getSlot.PrechatInput> ipList = New List<Bot_getSlot.PrechatInput>();
        Bot_getSlot.PrechatInput c1 = new Bot_getSlot.PrechatInput();
        c1.leadId = l.Id; 
        c1.contactId = uw.userList[0].SA__c; 
        c1.role = 'SA'; 
        c1.SelectedSlot = '01:00 PM - 04:00 PM on 1/8/2022'; 
        
        ipList.add(c1);
        List<Bot_getSlot.PrechatOutput> Docs = Bot_getSlot.getSlot(ipList);
        Test.stopTest();
    }
    Public static testMethod void doTest2() {
        
        Map<string,string> resultMap = TestDataFactory.createContact();
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123458',string.valueOf(devRecordTypeId),c.Id);
       
        Test.startTest();
        List<event> eventList = Get_SA_Available_Slot.isCalendarBlocked(l.Id);
        Lead lead = Get_SA_Available_Slot.getLead(l.Id);
        string st = Get_SA_Available_Slot.checkDateValidation(system.today());
        ScheduleAppointmentServices.UserWrapper uw = Get_SA_Available_Slot.getContactList(l.Id);
        List<ScheduleAppointmentServices.SlotWrapper> slots = Get_SA_Available_Slot.getSlots(uw.UserList[0].SA__c,'BHS',system.today().addDays(1),l.Id);
        ScheduleAppointmentServices.SuccessWrapper sw = Get_SA_Available_Slot.bookSlot(l.Id, '10:00 AM - 11:00 AM', system.today().addDays(1), uw.UserList[0].SA__c, null, false, null);
        List<Event> event = [select id from event where whoId =: l.Id];
		ScheduleAppointmentServices.SuccessWrapper sw2 = Get_SA_Available_Slot.bookSlot(l.Id, '11:00 AM - 12:00 PM', system.today().addDays(1), uw.UserList[0].SA__c, null, true, event[0].Id);        
        List<ScheduleAppointmentServices.SlotWrapper> slots2 = Get_SA_Available_Slot.getSlots(uw.UserList[0].SA__c,'BHS',system.today().addDays(1),l.Id);
        
        List<event> eventListAfter = Get_SA_Available_Slot.isCalendarBlocked(l.Id);
        system.assert(eventListAfter.size() >0);
        string msg = Get_SA_Available_Slot.deleteAppointment(eventListAfter[0].Id,l.Id);
        eventListAfter = Get_SA_Available_Slot.isCalendarBlocked(l.Id);
        system.assert(eventListAfter.size() == 0);
        List<User> us = ScheduleAppointmentServices.getUser_From_Id(l.Id);
      
        List<Bot_getSlot.PrechatInput> ipList = New List<Bot_getSlot.PrechatInput>();
        Bot_getSlot.PrechatInput c1 = new Bot_getSlot.PrechatInput();
        c1.leadId = l.Id; 
        c1.contactId = ''; 
        c1.role = 'SA'; 
        c1.SelectedSlot = '01:00 PM - 04:00 PM on 1/8/2022'; 
        
        ipList.add(c1);
        List<Bot_getSlot.PrechatOutput> Docs = Bot_getSlot.getSlot(ipList);
        Test.stopTest();
    }
}