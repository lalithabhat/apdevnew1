@isTest
public class TEST_BHSAppointment_Book_Slot {
    
            
    @isTest  
    private static void test1() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId=''; 
            req.selectedSlot=''; 
            req.selectedDate=null;
            req.action=''; 
            req.eventId=''; 
            req.description=''; 
            req.WtsSendFlag=false;
            req.crmUserId=''; 
            req.dealerId='';
        	request.add(req);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
            system.assertEquals(result.returnCode,201);
            System.assertEquals(result.CRMEventId, null);
        	System.assertEquals(result.CRMleadId, null);
            System.assertEquals(result.message, 'crmLeadId, selectedDate, selectedSlot,crmUserId and action Parameters should not be blank');
        Test.stopTest();
    }
    
    
    @isTest  
    private static void test2() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId='xyz'; 
            req.selectedSlot='abc'; 
            req.selectedDate=System.today();
            req.action='Cancel'; 
            req.eventId=null; 
            req.description=null; 
            req.WtsSendFlag=null;
            req.crmUserId='pqr'; 
            req.dealerId=null;
        	request.add(req);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
            system.assertEquals(result.returnCode,202);
            System.assertEquals(result.CRMEventId, null);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            System.assertEquals(result.message, 'EventId mandatory to cancel or reschedule the appointment');
        Test.stopTest();
    }
    
    
    @isTest  
    private static void test3() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId='xyz'; 
            req.selectedSlot='10:00 AM - 11:00 AM'; 
            req.selectedDate=System.today();
            req.action='Cancel'; 
            req.eventId='xyz'; 
            req.description=null; 
            req.WtsSendFlag=null;
            req.crmUserId='pqr'; 
            req.dealerId=null;
        	request.add(req);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
            system.assertEquals(result.returnCode,205);
            System.assertEquals(result.CRMEventId, req.eventId);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            System.assertEquals(result.message, 'EventId not exists in CRM');
        Test.stopTest();
    }
    
    
    @isTest  
    private static void test4() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId='xyz'; 
            req.selectedSlot='abc'; 
            req.selectedDate=System.today();
            req.action='Book'; 
            req.eventId='xyz'; 
            req.description=null; 
            req.WtsSendFlag=null;
            req.crmUserId='pqr'; 
            req.dealerId=null;
        	request.add(req);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
            system.assertEquals(result.returnCode,207);
            System.assertEquals(result.CRMEventId, null);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            System.assertEquals(result.message, 'Failed: No slots available');
        Test.stopTest();
    }

    
    @isTest  
    private static void test5() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        l.Bot_Journey__c='Appointment Scheduled-BHS';
        l.Skills__c='BHS';
        update l;
        Test.startTest();
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId=l.Id; 
            req.selectedSlot='10:00 AM - 11:00 AM'; 
            req.selectedDate=system.today().addDays(2);
            req.action='Book'; 
            req.eventId='xyz'; 
            req.description='ok'; 
            req.WtsSendFlag=False;
            req.crmUserId=CAid; 
            req.dealerId=null;
        	request.add(req);
        	//l.Id,'10:00 AM - 11:00 AM',system.today().addDays(1),'Book','','ok',false,CAid,null);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
            system.assertEquals(result.returnCode,210);
            System.assertEquals(result.CRMEventId, null);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            //System.assertEquals(result.message, 'Success: Appointment booked successfully');
        Test.stopTest();
        
        
             
    }
    
    
     
     @isTest  
    private static void test7() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId='#'; 
            req.selectedSlot='10:00 AM - 11:00 AM'; 
            req.selectedDate=system.today().addDays(6);
            req.action='Book'; 
            req.eventId=''; 
            req.description='ok'; 
            req.WtsSendFlag=false;
            req.crmUserId='xyz'; 
            req.dealerId=null;
        	request.add(req);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
            system.assertEquals(result.returnCode,207);
            System.assertEquals(result.CRMEventId, null);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            System.assertEquals(result.message, 'Failed: No slots available');
        Test.stopTest();
    }
    
	
    @isTest  
    private static void test8() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('BHS', 'BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        l.Bot_Journey__c='Appointment Scheduled-BHS';
        l.Skills__c='BHS';
        update l;
        
        Test.startTest();
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId='xyz'; 
            req.selectedSlot='10:00 AM - 11:00 AM'; 
            req.selectedDate=System.today().addDays(10);
            req.action='Book'; 
            req.eventId='mnop'; 
            req.description=null; 
            req.WtsSendFlag=null;
            req.crmUserId='.'; 
            req.dealerId=null;
        	request.add(req);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
        	//BHSAppointment_Book_Slot.REST_result result1 = BHSAppointment_Book_Slot.bookSlot(request);
        	
        	 
        	
        	
            
        Test.stopTest();
    }
    
    
    @isTest  
    private static void test6() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        l.Bot_Journey__c='Initiated';
        l.Skills__c='BHS';
       update l;
        Test.startTest();
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId=l.Id; 
            req.selectedSlot='00:00 AM - 11:00 AM'; 
            req.selectedDate=Date.newInstance(2022, 05, 31);
            req.action='Book'; 
            req.eventId=''; 
            req.description='ok'; 
            req.WtsSendFlag=False;
            req.crmUserId=CAid; 
            req.dealerId=null;
        	request.add(req);
        	//l.Id,'10:00 AM - 11:00 AM',system.today().addDays(1),'Book','','ok',false,CAid,null
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
        	List<Event> eventList = [select id,whoId,subject,StartDateTime,owner.lastName,EndDateTime,owner.Name,ownerId from event where whoId =: l.Id and 
                                   StartDateTime >=Today and type = 'Appointment' order by createdDate DESC];
            system.assertEquals(result.returnCode,209);
            System.assertEquals(result.CRMEventId, null);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            System.assertEquals(result.message, 'Failed: Selected slot already booked');
        Test.stopTest();
        
        
             
    }
    
    @isTest  
    private static void test9() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        l.Bot_Journey__c='Initiated';
        l.Skills__c='BHS';
       update l;
        Test.startTest();
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId=l.Id; 
            req.selectedSlot='00:00 AM -   01:00 AM '; 
            req.selectedDate=Date.newInstance(2022, 01, 06);
            req.action='Book'; 
            req.eventId=''; 
            req.description='ok'; 
            req.WtsSendFlag=False;
            req.crmUserId=CAid; 
            req.dealerId=null;
        	request.add(req);
        	//l.Id,'10:00 AM - 11:00 AM',system.today().addDays(1),'Book','','ok',false,CAid,null
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
        	List<Event> eventList = [select id,whoId,subject,StartDateTime,owner.lastName,EndDateTime,owner.Name,ownerId from event where whoId =: l.Id and 
                                   StartDateTime >=Today and type = 'Appointment' order by createdDate DESC];
            system.assertEquals(result.returnCode,209);
            System.assertEquals(result.CRMEventId, null);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            //System.assertEquals(result.message, 'Failed: Selected slot already booked');
        Test.stopTest();
        
        
             
    }
    
    @isTest  
    private static void test10() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        //l.Bot_Journey__c='Initiated';
        //l.Skills__c='SPS';
       //update l;
        Test.startTest();
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId=l2.Id; 
            req.selectedSlot='01:00 AM -   02:30 AM '; 
            req.selectedDate=System.today().addDays(5);
            req.action='Book'; 
            req.eventId='xyz'; 
            req.description='ok'; 
            req.WtsSendFlag=False;
            req.crmUserId=CAid; 
            req.dealerId=null;
        	request.add(req);
        	//l.Id,'10:00 AM - 11:00 AM',system.today().addDays(1),'Book','','ok',false,CAid,null
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
        	List<Event> eventList = [select id,whoId,subject,StartDateTime,owner.lastName,EndDateTime,owner.Name,ownerId from event where whoId =: l2.Id and 
                                   StartDateTime >=Today and type = 'Appointment' order by createdDate DESC];
            system.assertEquals(result.returnCode,207);
            System.assertEquals(result.CRMEventId, null);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            System.assertEquals(result.message, 'Failed: No slots available');
        Test.stopTest();
        
        
             
    }
    
    
    
        
        
    
    @isTest  
    private static void test19() {
        Test.startTest();
        
        
        Map<string,string> resultMap = new Map<string,string>();
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = 'testAccount';
        
        a.Phone = '1234567123';
        a.Dealer_Code__c = 'D12345';
        a.RecordTypeId = devRecordTypeId;
        a.OwnerId = u.Id;
        insert a;
        
        contact c1 = new Contact();
        c1.FirstName = 'First';
        c1.LastName = 'test contact';
        c1.mobilePhone = '1234567123';
        c1.email = 'test@contact.in';
        c1.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c1.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c1.Active__c = true;
        c1.AccountId = a.Id;
        insert c1;
        resultMap.put('CA',c1.Id);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;       
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerAutoResponseEmail = false;       
        dmo.optAllOrNone = false;
        
       
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Associate (SA)' Limit 1];
        string nick = c1.email!=null?c1.email.substring(0, c1.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        User newUser1 = new User(alias=c1.firstName, email = c1.email, emailencodingkey = 'UTF-8', 
                                 firstname = c1.firstName, lastname = c1.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c1.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = c1.email,CommunityNickname = nick,ProfileId =portalProfile.Id, IsActive = true);
        newUser1.setOptions(dmo);
        insert newUser1;
        
        campaign c = new Campaign();
        c.Name = 'test campaign';
        c.IsActive = true;
        c.StartDate = system.today();
        c.EndDate = system.today().addDays(60);
        c.BU__c = 'BHS';
        c.Source__c = 'Advertisement';
        c.Sub_Service__c = 'BHS';
        c.Status = 'In Progress';   
        c.Taggable_Campaign__c =true;
        C.Digital_Marketing_Campaign_Code__c ='123';
        insert c;
        
        
        
        Service_Master__c sm = new Service_Master__c();
        sm.Service__c = 'BHS';
        sm.Skills__c = 'BHS';
        sm.Slot_Duration_in_Hours__c = 1.00;
        insert sm;
        
        Pincode__c pin = new Pincode__c();
        pin.Name = '123456';
        pin.City__c = 'AHMEDABAD';
        pin.Country__c = 'India';
        pin.Country_Code__c = 'IN';
        pin.Pincode_Ext__c = '123456';
        insert pin;
        
        SA_Pincode_Mapping__c pm = new SA_Pincode_Mapping__c();
        pm.Pincode__c = '123456';
        pm.Role__c = 'CA';
        pm.Priority__c = 1;
        pm.SA__c = c1.Id;
        pm.Service_Master__c = sm.Id;
        insert pm;
        
        
        Service_Territory__c st = new Service_Territory__c();
        st.Name = 'Test Territory';
        st.Type__c = 'Region';
        st.Business_Hour_start__c = Time.newInstance(01, 00, 00, 00);
        st.Business_Hour_End__c = Time.newInstance(23, 00, 00, 00);
        st.Service__c = 'BHS';
        st.Valid_From__c = system.today();
        st.Valid_Till__c = system.today().addDays(30);
        insert st;
        
        Id devRecordTypeId1 = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        
     	Lead l = new Lead();
        l.LastName = 'Last Name';
        l.Pincode__c = pin.Name;
        l.MobilePhone = '1234567890';
        l.Email = 'testbhs@ap.com';
        l.RecordTypeId = devRecordTypeId1;
        l.CampaignName__c = c.Id;
        //l.Skills__c = 'San Assure;';
        l.Status = 'New';
        l.Service_Territory__c = st.Id;
        insert l;
        
        Event e = new Event();
                //e.ownerId = owner;
                e.whoId = l.Id;
                e.StartDateTime = System.now().addHours(1);
                e.EndDateTime = System.now().addHours(2);
                e.Subject = 'Appointment with ' + lead.Name;
                e.Owner_Mobile_No__c = c1.MobilePhone;
                e.Type='Appointment';
                e.Customer_Mobile__c = l.MobilePhone;
                e.Customer_Name__c = l.Name;
                insert e;
                Id eventId = e.Id;
        
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId=l.Id; 
            req.selectedSlot=System.now().addHours(1)+ ' - '+System.now().addHours(2);
            req.selectedDate=system.today();
            req.action='Cancel'; 
            req.eventId=eventId; 
            req.description='ok'; 
            req.WtsSendFlag=true;
            req.crmUserId=c1.Id; 
            req.dealerId=null;
        	request.add(req);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
            system.assertEquals(result.returnCode,200);
            System.assertEquals(result.CRMEventId, null);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            System.assertEquals(result.message, 'Appointment successfully cancelled');
        Test.stopTest();
    }
    
    
    @isTest  
    private static void test11() {
        Test.startTest();
        
        
        Map<string,string> resultMap = new Map<string,string>();
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = 'testAccount';
        
        a.Phone = '1234567123';
        a.Dealer_Code__c = 'D12345';
        a.RecordTypeId = devRecordTypeId;
        a.OwnerId = u.Id;
        insert a;
        
        contact c1 = new Contact();
        c1.FirstName = 'First';
        c1.LastName = 'test contact';
        c1.mobilePhone = '1234567123';
        c1.email = 'test@contact.in';
        c1.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c1.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c1.Active__c = true;
        c1.AccountId = a.Id;
        insert c1;
        resultMap.put('CA',c1.Id);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;       
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerAutoResponseEmail = false;       
        dmo.optAllOrNone = false;
        
       
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Associate (SA)' Limit 1];
        string nick = c1.email!=null?c1.email.substring(0, c1.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        User newUser1 = new User(alias=c1.firstName, email = c1.email, emailencodingkey = 'UTF-8', 
                                 firstname = c1.firstName, lastname = c1.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c1.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = c1.email,CommunityNickname = nick,ProfileId =portalProfile.Id, IsActive = true);
        newUser1.setOptions(dmo);
        insert newUser1;
        
        campaign c = new Campaign();
        c.Name = 'test campaign';
        c.IsActive = true;
        c.StartDate = system.today();
        c.EndDate = system.today().addDays(60);
        c.BU__c = 'BHS';
        c.Source__c = 'Advertisement';
        c.Sub_Service__c = 'BHS';
        c.Status = 'In Progress';   
        c.Taggable_Campaign__c =true;
        C.Digital_Marketing_Campaign_Code__c ='123';
        insert c;
        
        
        
        Service_Master__c sm = new Service_Master__c();
        sm.Service__c = 'BHS';
        sm.Skills__c = 'BHS';
        sm.Slot_Duration_in_Hours__c = 1.00;
        insert sm;
        
        Pincode__c pin = new Pincode__c();
        pin.Name = '123456';
        pin.City__c = 'AHMEDABAD';
        pin.Country__c = 'India';
        pin.Country_Code__c = 'IN';
        pin.Pincode_Ext__c = '123456';
        insert pin;
        
        SA_Pincode_Mapping__c pm = new SA_Pincode_Mapping__c();
        pm.Pincode__c = '123456';
        pm.Role__c = 'CA';
        pm.Priority__c = 1;
        pm.SA__c = c1.Id;
        pm.Service_Master__c = sm.Id;
        insert pm;
        
        
        Service_Territory__c st = new Service_Territory__c();
        st.Name = 'Test Territory';
        st.Type__c = 'Region';
        st.Business_Hour_start__c = Time.newInstance(01, 00, 00, 00);
        st.Business_Hour_End__c = Time.newInstance(23, 00, 00, 00);
        st.Service__c = 'BHS';
        st.Valid_From__c = system.today();
        st.Valid_Till__c = system.today().addDays(30);
        insert st;
        
        Id devRecordTypeId1 = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        
     	Lead l = new Lead();
        l.LastName = 'Last Name';
        l.Pincode__c = pin.Name;
        l.MobilePhone = '1234567890';
        l.Email = 'testbhs@ap.com';
        l.RecordTypeId = devRecordTypeId1;
        l.CampaignName__c = c.Id;
        //l.Skills__c = 'San Assure;';
        l.Status = 'New';
        l.Service_Territory__c = st.Id;
        insert l;
        
        Event e = new Event();
                //e.ownerId = owner;
                e.whoId = l.Id;
                e.StartDateTime = System.now().addHours(1);
                e.EndDateTime = System.now().addHours(2);
                e.Subject = 'Appointment with ' + lead.Name;
                e.Owner_Mobile_No__c = c1.MobilePhone;
                e.Type='Appointment';
                e.Customer_Mobile__c = l.MobilePhone;
                e.Customer_Name__c = l.Name;
                insert e;
                Id eventId = e.Id;
        
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId=l.Id; 
            req.selectedSlot=System.now().addHours(1)+ ' - '+System.now().addHours(2);
            req.selectedDate=system.today();
            req.action='Book'; 
            req.eventId=eventId; 
            req.description='ok'; 
            req.WtsSendFlag=true;
            req.crmUserId=c1.Id; 
            req.dealerId=null;
        	request.add(req);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
            system.assertEquals(result.returnCode,203);
            System.assertEquals(result.CRMEventId, eventId);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            System.assertEquals(result.message, 'Appointment already booked');
        Test.stopTest();
    }
    
    
    @isTest  
    private static void test16() {
        Test.startTest();
        
        
        Map<string,string> resultMap = new Map<string,string>();
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = 'testAccount';
        
        a.Phone = '1234567123';
        a.Dealer_Code__c = 'D12345';
        a.RecordTypeId = devRecordTypeId;
        a.OwnerId = u.Id;
        insert a;
        
        contact c1 = new Contact();
        c1.FirstName = 'First';
        c1.LastName = 'test contact';
        c1.mobilePhone = '1234567123';
        c1.email = 'test@contact.in';
        c1.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c1.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c1.Active__c = true;
        c1.AccountId = a.Id;
        insert c1;
        resultMap.put('CA',c1.Id);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;       
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerAutoResponseEmail = false;       
        dmo.optAllOrNone = false;
        
       
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Associate (SA)' Limit 1];
        string nick = c1.email!=null?c1.email.substring(0, c1.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        User newUser1 = new User(alias=c1.firstName, email = c1.email, emailencodingkey = 'UTF-8', 
                                 firstname = c1.firstName, lastname = c1.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c1.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = c1.email,CommunityNickname = nick,ProfileId =portalProfile.Id, IsActive = true);
        newUser1.setOptions(dmo);
        insert newUser1;
        
        campaign c = new Campaign();
        c.Name = 'test campaign';
        c.IsActive = true;
        c.StartDate = system.today();
        c.EndDate = system.today().addDays(60);
        c.BU__c = 'BHS';
        c.Source__c = 'Advertisement';
        c.Sub_Service__c = 'BHS';
        c.Status = 'In Progress';   
        c.Taggable_Campaign__c =true;
        C.Digital_Marketing_Campaign_Code__c ='123';
        insert c;
        
        
        
        Service_Master__c sm = new Service_Master__c();
        sm.Service__c = 'BHS';
        sm.Skills__c = 'BHS';
        sm.Slot_Duration_in_Hours__c = 1.00;
        insert sm;
        
        Pincode__c pin = new Pincode__c();
        pin.Name = '123456';
        pin.City__c = 'AHMEDABAD';
        pin.Country__c = 'India';
        pin.Country_Code__c = 'IN';
        pin.Pincode_Ext__c = '123456';
        insert pin;
        
        SA_Pincode_Mapping__c pm = new SA_Pincode_Mapping__c();
        pm.Pincode__c = '123456';
        pm.Role__c = 'CA';
        pm.Priority__c = 1;
        pm.SA__c = c1.Id;
        pm.Service_Master__c = sm.Id;
        insert pm;
        
        
        Service_Territory__c st = new Service_Territory__c();
        st.Name = 'Test Territory';
        st.Type__c = 'Region';
        st.Business_Hour_start__c = Time.newInstance(01, 00, 00, 00);
        st.Business_Hour_End__c = Time.newInstance(23, 00, 00, 00);
        st.Service__c = 'BHS';
        st.Valid_From__c = system.today();
        st.Valid_Till__c = system.today().addDays(30);
        insert st;
        
        Id devRecordTypeId1 = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        
     	Lead l = new Lead();
        l.LastName = 'Last Name';
        l.Pincode__c = pin.Name;
        l.MobilePhone = '1234567890';
        l.Email = 'testbhs@ap.com';
        l.RecordTypeId = devRecordTypeId1;
        l.CampaignName__c = c.Id;
        //l.Skills__c = 'San Assure;';
        l.Status = 'New';
        l.Service_Territory__c = st.Id;
        insert l;
        
        Event e = new Event();
                //e.ownerId = owner;
                e.whoId = l.Id;
                e.StartDateTime = System.now().addHours(1);
                e.EndDateTime = System.now().addHours(2);
                e.Subject = 'Appointment with ' + lead.Name;
                e.Owner_Mobile_No__c = c1.MobilePhone;
                e.Type='Appointment';
                e.Customer_Mobile__c = l.MobilePhone;
                e.Customer_Name__c = l.Name;
                insert e;
                Id eventId = e.Id;
        
            List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId=st.Id; 
            req.selectedSlot=System.now().addHours(1)+ ' - '+System.now().addHours(2);
            req.selectedDate=system.today();
            req.action='Cancel'; 
            req.eventId=eventId; 
            req.description='ok'; 
            req.WtsSendFlag=false;
            req.crmUserId=c1.Id; 
            req.dealerId=null;
        	request.add(req);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
            system.assertEquals(result.returnCode,204);
            System.assertEquals(result.CRMEventId, eventId);
        	System.assertEquals(result.CRMleadId, req.crmLeadId);
            System.assertEquals(result.message, 'Error in Appointment cancelled');
        Test.stopTest();
    }
    
    
    /*
    @isTest  
    private static void test16() {
        Map<string,string> resultMap = new Map<string,string>();
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = 'testAccount';
        a.Type__c = 'CI';
        a.Phone = '1234567123';
        a.Dealer_Code__c = 'D12345';
        a.RecordTypeId = devRecordTypeId;
        a.OwnerId = u.Id;
        insert a;
        resultMap.put('DEALER',a.Id);
        
        Id contractorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contractors').getRecordTypeId();
        Account con1 = new Account();
        con1.RecordTypeId = contractorRecordTypeId;
        con1.Name = 'Contractor 1 Dealer 1';
        con1.Phone = '1100885544';
        con1.Capacity__c = 10;
        con1.OwnerId = u.Id;
        insert con1;
        
        Dealer_Contractor_Mapping__c dCon1 = new Dealer_Contractor_Mapping__c();
        dCon1.Dealer__c = a.Id;
        dCon1.Contractor__c = con1.Id;
        dCon1.Relation_Status__c = 'Active';
        dCon1.Relationship_type__c = 'Dealer_Contractor';
        dCon1.Sub_Type__c = 'Primary';
        insert dCon1;
        
        
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Service_Territory__c st = new Service_Territory__c();
        st.Name = 'Test Territory';
        st.Type__c = 'Region';
        st.Business_Hour_start__c = Time.newInstance(10, 00, 00, 00);
        st.Business_Hour_End__c = Time.newInstance(18, 00, 00, 00);
        st.Service__c = 'SPS';
        st.Valid_From__c = system.today();
        st.Valid_Till__c = system.today().addDays(30);
        insert st;
        
     	Lead l = new Lead();
        l.LastName = 'Last Name';
        l.Pincode__c = '123456';
        l.MobilePhone = '1234567890';
        l.Email = 'test@gmail.com';
        l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        l.CampaignName__c = c.Id;
        l.Skills__c = 'SPS';
        l.Status = 'New';
        l.Service_Territory__c = st.Id;
        insert l;
        
        
        Event e = new Event();
        e.ownerId = u.Id;
        e.whoId = l.Id;
        e.StartDateTime = DateTime.newInstanceGmt(2022, 06, 03, 11, 30, 00);
        e.EndDateTime = DateTime.newInstanceGmt(2022, 06, 03, 12, 30, 00);
       	e.Subject = 'Appointment with ' + lead.Name;
        e.Owner_Mobile_No__c = '1234567890';
        e.Type='Appointment';
        e.Customer_Mobile__c = '1234567890';
        e.Customer_Name__c = 'name';
        insert e;
        //eventId = e.Id;
        
        Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'test contact';
        con.mobilePhone = '1234567123';
        con.email = 'test@contact.in';
        con.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        con.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        con.Active__c = true;
        con.AccountId = a.Id;
        insert con1;
        resultMap.put('CA',con.Id);
        
        List<BHSAppointment_Book_Slot.REST_Request> request = new List<BHSAppointment_Book_Slot.REST_Request>();
        	BHSAppointment_Book_Slot.REST_Request req = new BHSAppointment_Book_Slot.REST_Request();
        	req.crmLeadId=l.Id; 
            req.selectedSlot='02:00 PM - 03:00 PM'; 
            req.selectedDate=system.today().addDays(2);
            req.action='Reschedule'; 
            req.eventId=e.Id; 
            req.description='ok'; 
            req.WtsSendFlag=False;
            req.crmUserId=con.Id; 
            req.dealerId=null;
        	request.add(req);
        	//l.Id,'10:00 AM - 11:00 AM',system.today().addDays(1),'Book','','ok',false,CAid,null);
            BHSAppointment_Book_Slot.REST_result result = BHSAppointment_Book_Slot.bookSlot(request);
        	
        system.assertEquals(result.returnCode,200);
        
        Test.stopTest();
        
    }
   
   
	*/
}