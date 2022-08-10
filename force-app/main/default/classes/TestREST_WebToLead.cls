@isTest
public class TestREST_WebToLead {
    @isTest
    public static void successFreshLead1() {
        TestDataSetup.enableApplicationLog();
        Campaign c = TestDataSetup.createCampaign('SPS', 'SPS');
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Lead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        REST_WebToLead webReq = new REST_WebToLead();
        REST_WebToLead.REST_Request req1 = new REST_WebToLead.REST_Request();
        req1.C_FirstName = 'Fresh';
        req1.C_LastName = 'Lead';
        req1.C_Mobile = '1100220033';
        req1.C_Email = 'fresh@lead.in';
        req1.C_Pincode = '111111';
        req1.C_WhatsappNotification = 'No';
        req1.C_CampaignId = 'SPS';
        req1.C_Comments = 'Test Lead';
        req1.page_url = 'www.asianpaints.com';
        req1.C_IntegrationSource = 'Web';
        req1.utm_source = 'source';
        req1.utm_device = 'device';
        req1.utm_campaign = 'campaign';
        req1.utm_medium = 'medium';
        req1.C_House = '101';
        req1.C_Floor = '10';
        req1.C_Address1 = 'Test Address1';
        req1.C_Address2 = 'Test Address2';
        req1.C_City = 'Pune';
        req1.C_State = 'Maharashtra';
        req1.C_Country = 'India';
        req1.C_EstimatedValue = '1000000';
        req1.C_Service = 'SPS';
        req1.Priority = 'Hot';
        req1.Architect_BP = 'Architect_BP';
        req1.Architect_Name = 'Architect_Name';
        req1.Architect_Mobile = '1122332211';
        req1.External_Lead_Creator_Position_Code = '12345';
        req1.External_Lead_Creator_Employee_Id = '12345';
        req1.External_Lead_Creator_Name = 'Lead Name';
        req1.External_Lead_Creator_Mobile = '1233312333';
        req1.Firm_Name = 'Firm Name';
        req1.Firm_BP = 'Firm BP';
        req1.Firm_Mobile = '4433221100';
        req1.Dealer_Code = '444444';
        req1.BP_Code = 'BP Code';
        //req1.Original_Lead_Id = '9329237';
        req1.Referral_Type = 'Customer';
        req1.Referrer_Name = 'Referrer Name';
        req1.Referrer_Mobile = '1230012300';
        req1.Referrer_Email = 'ref@email.com';
        req1.Probable_Conversion_Date = '01/12/2022'; //format should be mm/dd/yyyy
        req1.Summary_of_Work = 'Work Summary';
        req1.Project_Type = 'Project Type';
        req1.visitor_id = '1122233';
        req1.External_System_Lead_Id = '1234567890';
        req1.organization_name = 'Org Name';
        req1.segment = 'Segment';
        req1.title = 'Mr.';
        req1.designation = 'SD';
        req1.process_type = 'SPS_SPS';
        req1.created_time = '11:00 AM';
        req1.camp_name = 'Test Campaign';
        req1.send_to_crm = 'Yes';
        req1.dummy1 = 'dummy 1';
        req1.dummy2 = 'dummy 2';
        req1.dummy3 = 'dummy 3';
        req1.bpno = '12345';
        req1.measureneed = 'need';
        req1.skuchosen = 'chosen';
        req1.dealer_name = 'Dealer';
        req1.answer = 'answer';
        req1.date_picker_data = 'date';
        req1.hybris_id = '1111';
        req1.appointment_time = '11:00 AM';
        req1.cc_sa_bp = '123';
        req1.hybris_updated = 'hybris updated';
        req1.interior_exterior = 'inex';
        req1.no_of_rooms = '1';
        req1.appointment_end_time = '2:00 PM';
        req1.sync_hybris_marketing = 'am';
        req1.custom_Field = 'Test';
        req1.address1 = 'Add 1';
        req1.address2 = 'Add 2';
        req1.phone = '1111222233';
        req1.C_whatsappnotification = 'true';
        REST_WebToLead.LeadDetails(req1);
        REST_WebToLead.LeadDetails(req1);
        
        Test.stopTest();
    }
    
    @isTest
    public static void successFreshLead2() {
        TestDataSetup.enableApplicationLog();
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Campaign c1 = TestDataSetup.createCampaign('SPS', 'SPS');
        Campaign c2 = TestDataSetup.createCampaign('BHS', 'BHS');
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Lead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        REST_WebToLead webReq = new REST_WebToLead();
        REST_WebToLead.REST_Request req1 = new REST_WebToLead.REST_Request();
        req1.C_FirstName = 'Fresh';
        req1.C_LastName = 'Lead';
        req1.C_Mobile = '1100220033';
        req1.C_Email = 'fresh@lead.in';
        req1.C_Pincode = '111111';
        req1.C_WhatsappNotification = 'No';
        req1.C_CampaignId = c1.Digital_Marketing_Campaign_Code__c;
        req1.page_url = 'www.asianpaints.com';
        req1.C_IntegrationSource = 'Web';
        REST_WebToLead.LeadDetails(req1);
        
        REST_WebToLead.REST_Request req2 = new REST_WebToLead.REST_Request();
        req2.C_FirstName = 'Fresh';
        req2.C_LastName = 'Lead';
        req2.C_Mobile = '1100220033';
        req2.C_Email = 'fresh@lead.in';
        req2.C_Pincode = '111111';
        req2.C_WhatsappNotification = 'No';
        req2.C_CampaignId = c1.Digital_Marketing_Campaign_Code__c;
        req2.page_url = 'www.asianpaints.com';
        req2.C_IntegrationSource = 'Web';
        REST_WebToLead.LeadDetails(req2);
        
        REST_WebToLead.REST_Request req3 = new REST_WebToLead.REST_Request();
        req3.C_FirstName = 'Fresh';
        req3.C_LastName = 'Lead';
        req3.C_Mobile = '1100220033';
        req3.C_Email = 'fresh@lead.in';
        req3.C_Pincode = '333333';
        req3.C_WhatsappNotification = 'No';
        req3.C_CampaignId = c2.Digital_Marketing_Campaign_Code__c;
        req3.page_url = 'www.asianpaints.com';
        req3.C_IntegrationSource = 'Web';
        REST_WebToLead.LeadDetails(req3);
        
        Test.stopTest();
    }
    
    @isTest
    public static void successFreshLead3() {
        TestDataSetup.enableApplicationLog();
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Campaign c1 = TestDataSetup.createCampaign('SPS', 'SPS');
        Campaign c2 = TestDataSetup.createCampaign('BHS', 'BHS');
        Account acc = TestDataSetup.createAccountTemplate('TestPA', 'fresh@lead.in', '1100220033');
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Lead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        REST_WebToLead webReq = new REST_WebToLead();
        REST_WebToLead.REST_Request req1 = new REST_WebToLead.REST_Request();
        req1.C_FirstName = 'Fresh';
        req1.C_LastName = 'Lead';
        req1.C_Mobile = '1100220033';
        req1.C_Email = 'fresh@lead.in';
        req1.C_Pincode = '111111';
        req1.C_WhatsappNotification = 'No';
        req1.C_CampaignId = c1.Digital_Marketing_Campaign_Code__c;
        req1.page_url = 'www.asianpaints.com';
        req1.C_IntegrationSource = 'Web';
        REST_WebToLead.LeadDetails(req1);
        
        REST_WebToLead.REST_Request req2 = new REST_WebToLead.REST_Request();
        req2.C_FirstName = 'Fresh';
        req2.C_LastName = 'Lead';
        req2.C_Mobile = '1100220033';
        req2.C_Email = 'fresh@lead.in';
        req2.C_Pincode = '111111';
        req2.C_WhatsappNotification = 'No';
        req2.C_CampaignId = c1.Digital_Marketing_Campaign_Code__c;
        req2.page_url = 'www.asianpaints.com';
        req2.C_IntegrationSource = 'Web';
        REST_WebToLead.LeadDetails(req2);
        
        REST_WebToLead.REST_Request req3 = new REST_WebToLead.REST_Request();
        req3.C_FirstName = 'Fresh';
        req3.C_LastName = 'Lead';
        req3.C_Mobile = '1100220033';
        req3.C_Email = 'fresh@lead.in';
        req3.C_Pincode = '333333';
        req3.C_WhatsappNotification = 'No';
        req3.C_CampaignId = c2.Digital_Marketing_Campaign_Code__c;
        req3.page_url = 'www.asianpaints.com';
        req3.C_IntegrationSource = 'Web';
        REST_WebToLead.LeadDetails(req3);
        
        Test.stopTest();
    }
    
    @isTest
    public static void successFreshLead4() {
        TestDataSetup.enableApplicationLog();
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Lead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        REST_WebToLead webReq = new REST_WebToLead();
        REST_WebToLead.REST_Request req1 = new REST_WebToLead.REST_Request();
        req1.C_FirstName = 'Fresh';
        req1.C_LastName = 'Lead';
        req1.C_Mobile = '1100220033';
        req1.C_Email = 'fresh@lead.in';
        req1.C_Pincode = '111111';
        req1.C_WhatsappNotification = 'No';
        req1.C_CampaignId = 'SPS';
        req1.page_url = 'www.asianpaints.com';
        req1.C_IntegrationSource = 'BHS';
        req1.C_SoA = 'Referral';
        REST_WebToLead.LeadDetails(req1);
        
        Test.stopTest();
    }
    
    @isTest
    public static void validationCheck1() {
        TestDataSetup.enableApplicationLog();
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Lead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        REST_WebToLead webReq = new REST_WebToLead();
        REST_WebToLead.REST_Request req1 = new REST_WebToLead.REST_Request();
        req1.C_FirstName = 'Fresh';
        req1.C_LastName = 'Lead';
        req1.C_Mobile = '1100220033';
        req1.C_Email = 'fresh@lead.in';
        req1.C_Pincode = '111111';
        req1.C_WhatsappNotification = 'No';
        req1.C_CampaignId = 'SPS';
        req1.page_url = 'www.asianpaints.com';
        req1.C_IntegrationSource = 'Web';
        req1.Lead_Status = 'Allocation Done';
        REST_WebToLead.LeadDetails(req1);
        
        Test.stopTest();
    }
    
    @isTest
    public static void validationCheck2() {
        TestDataSetup.enableApplicationLog();
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Lead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        REST_WebToLead webReq = new REST_WebToLead();
        REST_WebToLead.REST_Request req1 = new REST_WebToLead.REST_Request();
        req1.C_FirstName = 'Fresh 1';
        req1.C_LastName = 'Lead';
        req1.C_Mobile = '1100220033';
        req1.C_Email = 'fresh@lead.in';
        req1.C_Pincode = '111111';
        req1.C_WhatsappNotification = 'No';
        req1.C_CampaignId = 'SPS';
        req1.page_url = 'www.asianpaints.com';
        req1.C_IntegrationSource = 'Web';
        REST_WebToLead.LeadDetails(req1);
        
        Test.stopTest();
    }
    
    @isTest
    public static void validationCheck3() {
        TestDataSetup.enableApplicationLog();
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Lead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        REST_WebToLead webReq = new REST_WebToLead();
        REST_WebToLead.REST_Request req1 = new REST_WebToLead.REST_Request();
        req1.C_FirstName = 'Fresh 1';
        req1.C_LastName = 'Lead';
        req1.C_Mobile = '1100220033';
        req1.C_Email = 'fresh@lead.in';
        req1.C_Pincode = '111111';
        req1.C_WhatsappNotification = 'No';
        req1.C_CampaignId = 'SPS';
        req1.page_url = 'www.asianpaints.com';
        req1.C_IntegrationSource = 'BHS';
        REST_WebToLead.LeadDetails(req1);
        
        Test.stopTest();
    }
    
    @isTest
    public static void validationCheck4() {
        TestDataSetup.enableApplicationLog();
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Lead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        REST_WebToLead webReq = new REST_WebToLead();
        REST_WebToLead.REST_Request req1 = new REST_WebToLead.REST_Request();
        req1.C_FirstName = 'Fresh';
        req1.C_LastName = 'Lead';
        req1.C_Mobile = '1100220033';
        req1.C_Email = 'fresh@lead.in';
        req1.C_Pincode = '111111';
        req1.C_WhatsappNotification = 'No';
        req1.C_CampaignId = 'SPS';
        req1.page_url = 'www.asianpaints.com';
        req1.C_IntegrationSource = 'BHS';
        req1.Lead_Status = 'Lost';
        req1.Skip_Calling = 'Y';
        REST_WebToLead.LeadDetails(req1);
        
        Test.stopTest();
    }
    
    @isTest
    public static void validationCheck5() {
        TestDataSetup.enableApplicationLog();
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/Lead/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        
        REST_WebToLead webReq = new REST_WebToLead();
        REST_WebToLead.REST_Request req1 = new REST_WebToLead.REST_Request();
        req1.C_FirstName = 'Fresh';
        req1.C_LastName = 'Lead';
        req1.C_Mobile = '1100220033';
        req1.C_Email = 'fresh@lead.in';
        req1.C_Pincode = '111111';
        req1.C_WhatsappNotification = 'No';
        req1.C_CampaignId = 'SPS';
        req1.page_url = 'www.asianpaints.com';
        req1.C_IntegrationSource = 'Web';
        req1.Lead_Status = 'Lost';
        req1.Skip_Calling = 'Y';
        REST_WebToLead.LeadDetails(req1);
        
        Test.stopTest();
    }
}