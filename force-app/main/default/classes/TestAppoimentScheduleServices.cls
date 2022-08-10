@isTest
public class TestAppoimentScheduleServices {
	@isTest
    private static void updateLeadApexTest(){
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
         Map<string,string> resultMap = TestDataFactory.createContact();
       Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
         Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId), c.Id);
       Get_SA_Available_Slot.updateLeadApex('bookSlot', resultMap.get('CA'), Datetime.now(), Datetime.now()+1, l.Id, resultMap.get('CA'), 'NA', null);
    }
    @isTest  
    private static void appointmentSchedule_BY_CA_Test() {
       // TestDataFactory.createUser();
        //Map<string,Id> recordMap = TestDataFactory.createMap('123456');
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        string dealerId = resultMap.get('DEALER');
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
       
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId), c.Id);
        l.Skills__c = 'Nilaya';
        update l;
        
        Test.startTest();
        List<event> eventList = Get_SA_Available_Slot.isCalendarBlocked(l.Id);
        Lead lead = Get_SA_Available_Slot.getLead(l.Id);
        string st = Get_SA_Available_Slot.checkDateValidation(system.today());
        ScheduleAppointmentServices.CADetailsWrapper uw = Get_SA_Available_Slot.getCAList(l.Id,null);
        ScheduleAppointmentServices.SuccessWrapper msg = Get_SA_Available_Slot.assignCAWithoutAppointmentApex(l.Id, CAid);
        ScheduleAppointmentServices.SuccessWrapper msg2 = Get_SA_Available_Slot.assignCAWithoutAppointmentApex(l.Id, null);
        string msg3 = Get_SA_Available_Slot.Bot_assignCAWithoutAppointmentApex(l.Id, CAid,dealerId);
        system.assertEquals(msg.message,'Success');
        system.assertEquals(msg2.message,'Fail');
        List<ScheduleAppointmentServices.SlotWrapper> slots = Get_SA_Available_Slot.getSlots(CAid,'CA',system.today().addDays(1),l.Id);
        system.debug('slots::'+slots);
        ScheduleAppointmentServices.SuccessWrapper sw = ScheduleAppointmentServices.Bot_bookSlot(l.Id, '10:00 AM - 11:00 AM', system.today().addDays(1), CAid, null, false, null,dealerId);
        List<Event> event = [select id from event where whoId =: l.Id];
		ScheduleAppointmentServices.SuccessWrapper sw2 = ScheduleAppointmentServices.Bot_bookSlot(l.Id, '11:00 AM - 12:00 PM', system.today().addDays(1), CAid, null, true, event[0].Id,dealerId);        
        List<ScheduleAppointmentServices.SlotWrapper> slots2 = Get_SA_Available_Slot.getSlots(CAid,'CA',system.today().addDays(1),l.Id);
        
        List<event> eventListAfter = Get_SA_Available_Slot.isCalendarBlocked(l.Id);
        system.assert(eventListAfter.size() >0);
        
        PageReference pRef = Page.DealerCalculation;
        Test.setCurrentPage(pRef);
        DealerManagementServices qController = new DealerManagementServices();
        
        qController.selectedSkill1 = 'Nilaya';
        qController.pincode = '123457';
        qController.getDealer();
        Test.stopTest();
    }
    
    @isTest  
    private static void appointmentSchedule_BY_SA_Test() {
       // TestDataFactory.createUser();
        //Map<string,Id> recordMap = TestDataFactory.createMap('123456');
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
        Test.stopTest();
    }
    
    @isTest  
    private static void appointmentSchedule_BY_BHS_Test() {
       
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
        
        Test.stopTest();
    }
    
    @isTest  
    private static void createEventOn_UNIT_Test() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        Test.startTest();
        	ScheduleAppointmentServices.FlowRequest req = new ScheduleAppointmentServices.FlowRequest();
        	req.uId = resultMap.get('UNIT');
        	req.reason = 'Holiday';
        	req.startTime = system.now();
        	req.endTime = system.Now().addDays(2);
        	List<ScheduleAppointmentServices.FlowRequest> reqlist = new List<ScheduleAppointmentServices.FlowRequest>();
        	reqlist.add(req);
         	List<string> returnMsg = ScheduleAppointmentServices.createEvent(reqlist);
        	system.assert(returnMsg.size()>0);
        	system.assertEquals(returnMsg[0],'Event has been successfully created');
        	list<Events__c> events = [select id,name,Start_Date_Time__c from Events__c];
        	system.assert(events.size() > 0);
        	update events;
        Test.stopTest();
    }
}