@isTest
public class Test_Bot_isSAorCA {
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
    
        List<Bot_isSAorCA.PrechatInput> ipList = New List<Bot_isSAorCA.PrechatInput>();
        Bot_isSAorCA.PrechatInput c1 = new Bot_isSAorCA.PrechatInput();
        c1.leadId = l.Id; 
        
        ipList.add(c1);
        System.debug('######ipList'+ipList);
        List<Bot_isSAorCA.PrechatOutput> Docs = Bot_isSAorCA.isSAorCA(ipList);
        Test.stopTest();
    }
    Public static testMethod void doTest2() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        string dealerId = resultMap.get('DEALER');
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId), c.Id);
        l.Skills__c = 'Nilaya';
        update l;
        Test.startTest();
        List<Bot_isSAorCA.PrechatInput> ipList = New List<Bot_isSAorCA.PrechatInput>();
        Bot_isSAorCA.PrechatInput c1 = new Bot_isSAorCA.PrechatInput();
        c1.leadId = l.Id; 
        
        ipList.add(c1);
        System.debug('######ipList'+ipList);
        List<Bot_isSAorCA.PrechatOutput> Docs = Bot_isSAorCA.isSAorCA(ipList);
        Test.stopTest();
    }
    Public static testMethod void doTest3() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123458',string.valueOf(devRecordTypeId),c.Id);
       
        Test.startTest();
        List<Bot_isSAorCA.PrechatInput> ipList = New List<Bot_isSAorCA.PrechatInput>();
        Bot_isSAorCA.PrechatInput c1 = new Bot_isSAorCA.PrechatInput();
        c1.leadId = l.Id; 
        
        ipList.add(c1);
        System.debug('######ipList'+ipList);
        List<Bot_isSAorCA.PrechatOutput> Docs = Bot_isSAorCA.isSAorCA(ipList);
        Test.stopTest();
    }
}