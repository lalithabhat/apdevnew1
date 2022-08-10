@isTest
public class TEST_BHSAppointment_Get_Slots {
	@isTest
    private static void test1() {
	    Map<string,string> resultMap = TestDataFactory.createContact();
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
        	BHSAppointment_Get_Slot_Details.REST_Request req = new BHSAppointment_Get_Slot_Details.REST_Request();
        	List<BHSAppointment_Get_Slot_Details.REST_Request> request = new List<BHSAppointment_Get_Slot_Details.REST_Request>();
        
        	req.crmLeadId=null;
        	req.fromDate=null;
        	req.pincode=null;
        	req.priority=null;
        	req.serviceGroup=null;
        	req.toDate=null;
        
        	request.add(req);
        	
        
        	BHSAppointment_Get_Slot_Details.REST_result res = BHSAppointment_Get_Slot_Details.getSlots(request);
        	System.assertEquals(res.returnCode, 201);
        Test.stopTest();
    }
    
    
    @isTest
    private static void test2() {
	    Map<string,string> resultMap = TestDataFactory.createContact();
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
        	BHSAppointment_Get_Slot_Details.REST_Request req = new BHSAppointment_Get_Slot_Details.REST_Request();
        	List<BHSAppointment_Get_Slot_Details.REST_Request> request = new List<BHSAppointment_Get_Slot_Details.REST_Request>();
        	req.fromDate = system.today().Year() + '-' + system.today().month() + '-' + system.today().Day();
            req.toDate = system.today().addDays(-1).Year() + '-' + system.today().addDays(-1).month() + '-' + system.today().addDays(-1).Day();
        	req.crmLeadId=l.Id;	
        	req.pincode='123456';
        	req.priority=0;
        	req.serviceGroup='BHS';
        	
        
        	request.add(req);
        	
        
        	BHSAppointment_Get_Slot_Details.REST_result res = BHSAppointment_Get_Slot_Details.getSlots(request);
        	System.assertEquals(res.returnCode, 208);
        Test.stopTest();
    }
    
    
    
    @isTest
    private static void test3() {
	    Map<string,string> resultMap = TestDataFactory.createContact();
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
        	BHSAppointment_Get_Slot_Details.REST_Request req = new BHSAppointment_Get_Slot_Details.REST_Request();
        	List<BHSAppointment_Get_Slot_Details.REST_Request> request = new List<BHSAppointment_Get_Slot_Details.REST_Request>();
        	req.fromDate = system.today().Year() + '-' + system.today().month() + '-' + system.today().Day();
            req.toDate = system.today().addDays(1).Year() + '-' + system.today().addDays(1).month() + '-' + system.today().addDays(1).Day();
        	req.crmLeadId=l.Id;	
        	req.pincode='123456';
        	req.priority=0;
        	req.serviceGroup='SPS';
        	
        
        	request.add(req);
        	
        
        	BHSAppointment_Get_Slot_Details.REST_result res = BHSAppointment_Get_Slot_Details.getSlots(request);
        	System.assertEquals(res.returnCode, 200);
        Test.stopTest();
    }
    
    @isTest
    private static void test4() {
	    Map<string,string> resultMap = TestDataFactory.createContact();
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
        	BHSAppointment_Get_Slot_Details.REST_Request req = new BHSAppointment_Get_Slot_Details.REST_Request();
        	List<BHSAppointment_Get_Slot_Details.REST_Request> request = new List<BHSAppointment_Get_Slot_Details.REST_Request>();
        	req.fromDate = system.today().Year() + '-' + system.today().month() + '-' + system.today().Day();
            req.toDate = system.today().addDays(1).Year() + '-' + system.today().addDays(1).month() + '-' + system.today().addDays(1).Day();
        	req.crmLeadId=l.Id;	
        	req.pincode='123457';
        	req.priority=0;
        	req.serviceGroup='BHS';
        	
        
        	request.add(req);
        	
        
        	BHSAppointment_Get_Slot_Details.REST_result res = BHSAppointment_Get_Slot_Details.getSlots(request);
        	System.assertEquals(res.returnCode, 204);
        Test.stopTest();
    }
    
    
    @isTest
    private static void test5() {
	    Map<string,string> resultMap = TestDataFactory.createContact();
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
        	BHSAppointment_Get_Slot_Details.REST_Request req = new BHSAppointment_Get_Slot_Details.REST_Request();
        	List<BHSAppointment_Get_Slot_Details.REST_Request> request = new List<BHSAppointment_Get_Slot_Details.REST_Request>();
        	req.fromDate = system.today().Year() + '-' + system.today().month() + '-' + system.today().Day();
            req.toDate = system.today().addDays(1).Year() + '-' + system.today().addDays(1).month() + '-' + system.today().addDays(1).Day();
        	req.crmLeadId=l.Id;	
        	req.pincode='123456';
        	req.priority=0;
        	req.serviceGroup='SPS';
        	
        
        	request.add(req);
        	
        
        	BHSAppointment_Get_Slot_Details.REST_result res = BHSAppointment_Get_Slot_Details.getSlots(request);
        	System.assertEquals(res.returnCode, 205);
        Test.stopTest();
    }
    
    
    @isTest
    private static void test6() {
	    Map<string,string> resultMap = TestDataFactory.createContact();
        campaign c = TestDataFactory.createCampaign('BHS','BHS');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        l.Skills__c='BHS';
        
        update l;
        Test.startTest();
        	BHSAppointment_Get_Slot_Details.REST_Request req = new BHSAppointment_Get_Slot_Details.REST_Request();
        	List<BHSAppointment_Get_Slot_Details.REST_Request> request = new List<BHSAppointment_Get_Slot_Details.REST_Request>();
        	req.fromDate = system.today().Year() + '-' + system.today().month() + '-' + system.today().Day();
            req.toDate = system.today().addDays(1).Year() + '-' + system.today().addDays(1).month() + '-' + system.today().addDays(1).Day();
        	req.crmLeadId=l.Id;	
        	req.pincode='123456';
        	req.priority=0;
        	req.serviceGroup='BHS';
        	
        
        	request.add(req);
        	
        
        	BHSAppointment_Get_Slot_Details.REST_result res = BHSAppointment_Get_Slot_Details.getSlots(request);
        	System.assertEquals(res.returnCode, 206);
        Test.stopTest();
    }
    /*
      
      
     @isTest  
    private static void REST_Get_SA_Slot_YM_Test() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
            REST_GetSlots_YM.REST_result result = REST_GetSlots_YM.getSlots(null,null,null,null,null,null);
            system.assertEquals(result.returnCode,201);
            
            string frmDate = system.today().Year() + '-' + system.today().month() + '-' + system.today().Day();
            string endDate = system.today().addDays(-1).Year() + '-' + system.today().addDays(-1).month() + '-' + system.today().addDays(-1).Day();
            REST_GetSlots_YM.REST_result result2 = REST_GetSlots_YM.getSlots('123456','SPS',l.Id,frmDate,endDate,0);
            system.assertEquals(result2.returnCode,208);
        
            endDate = system.today().addDays(1).Year() + '-' + system.today().addDays(1).month() + '-' + system.today().addDays(1).Day();
            REST_GetSlots_YM.REST_result result3 = REST_GetSlots_YM.getSlots('123456','SPS','xyz',frmDate,endDate,0);
            system.assertEquals(result3.returnCode,202);
        
            REST_GetSlots_YM.REST_result result4 = REST_GetSlots_YM.getSlots('123457','SPS',l.Id,frmDate,endDate,0);
            system.assertEquals(result4.returnCode,204);
        
            REST_GetSlots_YM.REST_result result5 = REST_GetSlots_YM.getSlots('123456','BHS',l.Id,frmDate,endDate,0);
            system.assertEquals(result5.returnCode,205);
        
            REST_GetSlots_YM.REST_result result6 = REST_GetSlots_YM.getSlots('123456','SPS',l.Id,frmDate,endDate,0);
            system.assertEquals(result6.returnCode,200);
        Test.stopTest();
    }
       
  */
    
    
}