@isTest
global class TEST_BHSAppointment_Get_Details {
	@isTest
    global static void test1()
    {
        Test.startTest();
        BHSAppointment_Get_Details.REST_Request req = new BHSAppointment_Get_Details.REST_Request();
        List <BHSAppointment_Get_Details.REST_Request> request = new List <BHSAppointment_Get_Details.REST_Request>();
        req.crmleadId='';
        request.add(req);
        BHSAppointment_Get_Details.REST_result res = BHSAppointment_Get_Details.getApptDetails(request);
        System.assertEquals(res.returnCode, 201);
        System.assertEquals(res.message, 'crmLeadId should not be blank');
        System.assertEquals(res.Name, null);
        System.assertEquals(res.Appt_End_Time, null);
        System.assertEquals(res.Appt_Start_Time, null);
        System.assertEquals(res.eventId, null);
        System.assertEquals(res.crmLeadId, null);
        Test.stopTest();
    }
   
    
     @isTest  
    private static void test4() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
       
        Test.startTest();
            List<BHSAppointment_Get_Details.REST_Request> request = new List<BHSAppointment_Get_Details.REST_Request>();
        	BHSAppointment_Get_Details.REST_Request req = new BHSAppointment_Get_Details.REST_Request();
        	//req.crmLeadId=l.Id; 
			l.Skills__c='BHS';            
           	l.Last_Appointment_Start_Date_Time__c=	DateTime.newInstanceGmt(2022, 06, 02, 11, 30, 00);
        	l.Last_Appointment_End_Date_Time__c=DateTime.newInstanceGmt(2022, 06, 02, 13, 00, 00);
        	l.Bot_Journey__c='Appointment Scheduled-BHS';
        	
        	update l;
        	req.crmLeadId=l.Id; 
        	request.add(req);
            BHSAppointment_Get_Details.REST_result result = BHSAppointment_Get_Details.getApptDetails(request);
            
        	System.assertEquals(result.returnCode, 201);
        	System.assertEquals(result.message, 'Appointment Details not available');
        	//System.assertEquals(result.Name, l.Name);
        
        	System.assertEquals(result.Appt_End_Time, null);
        	System.assertEquals(result.Appt_Start_Time, null);
        	System.assertEquals(result.eventId, null);
       		System.assertEquals(result.crmLeadId, l.Id);
        Test.stopTest();
    }
}