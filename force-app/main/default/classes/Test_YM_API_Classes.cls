@isTest
public class Test_YM_API_Classes {
    @isTest  
    private static void YM_Lead_API_Class_Test() {
        API_Integration__c api_endURL = new API_Integration__c();
        api_endURL.Name = 'YM Push Lead API';
        api_endURL.URL__c = 'https://app.yellowmessenger.com/integrations/yellowmessenger/receive';
        api_endURL.App_Version__c = 'x1573449987921';
        insert api_endURL;
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Test.setMock(HttpCalloutMock.class, new YM_LeadAPI_Mock());
        Lead l = TestDataFactory.createLead_For_YM('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId), c.Id,true);
        
        Test.startTest();
            REST_FetchLeadDetails_YM.REST_result result = REST_FetchLeadDetails_YM.LeadDetails(l.Id);
            system.assertEquals(result.returnCode,200);
            REST_FetchLeadDetails_YM.REST_result result2 = REST_FetchLeadDetails_YM.LeadDetails('xyz');
            system.assertEquals(result2.returnCode,201);
        Test.stopTest(); 
    }
    
    @isTest  
    private static void REST_UpdateLead_YM_Test() {
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead_For_YM('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId), c.Id,false);
        Pincode__c pin = TestDataFactory.createPincodeRecord('123457');
        Test.startTest();
            REST_UpdateLead_YM2.REST_result result = REST_UpdateLead_YM2.updateLead(null,false,null,null);
            system.assertEquals(result.returnCode,201);
            
            REST_UpdateLead_YM2.REST_result result2 = REST_UpdateLead_YM2.updateLead('xyz',false,null,null);
            system.assertEquals(result2.returnCode,203);
        
            REST_UpdateLead_YM2.Address address = new REST_UpdateLead_YM2.Address();
            address.postalCode = '123457';
            address.street = 'ABC street';
            List<REST_UpdateLead_YM2.Questionnaire> questionnair = new List<REST_UpdateLead_YM2.Questionnaire>();
            for(Integer i=1;i<=4;i++){
                REST_UpdateLead_YM2.Questionnaire q = new REST_UpdateLead_YM2.Questionnaire();
                q.question = 'Q4';q.answer='A'+i;questionnair.add(q);
            }
            for(Integer i=1;i<=2;i++){
                REST_UpdateLead_YM2.Questionnaire q = new REST_UpdateLead_YM2.Questionnaire();
                q.question = 'Q5';q.answer='A'+i;questionnair.add(q);
            }
            REST_UpdateLead_YM2.REST_result result3 = REST_UpdateLead_YM2.updateLead(l.Id,true,address,questionnair);
          //  system.assertEquals(result3.returnCode,200);    
        
        Test.stopTest();
    }
    
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
           // system.assertEquals(result5.returnCode,205);
        
            REST_GetSlots_YM.REST_result result6 = REST_GetSlots_YM.getSlots('123456','SPS',l.Id,frmDate,endDate,0);
            system.assertEquals(result6.returnCode,200);
        Test.stopTest();
    }
    
    @isTest  
    private static void REST_Book_SA_Slot_YM_Test() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Lead l2 = TestDataFactory.createLead('1234567235','email2@stetig.in','123456',string.valueOf(devRecordTypeId),c.Id);
        
        Test.startTest();
            REST_BookSlot_YM.REST_result result = REST_BookSlot_YM.bookSlot(null,null,null,null,null,null,null,null,null);
            system.assertEquals(result.returnCode,201);
            REST_BookSlot_YM.REST_result result2 = REST_BookSlot_YM.bookSlot('xyz','abc',system.today(),'Cancel',null,null,null,'pqr',null);
            system.assertEquals(result2.returnCode,202);
            REST_BookSlot_YM.REST_result result3 = REST_BookSlot_YM.bookSlot('xyz','abc',system.today(),'Cancel','xyz',null,null,'pqr',null);
            system.assertEquals(result3.returnCode,205);
            REST_BookSlot_YM.REST_result result6 = REST_BookSlot_YM.bookSlot('xyz','abc',system.today(),'Book','',null,null,'pqr',null);
            system.assertEquals(result6.returnCode,207);
            REST_BookSlot_YM.REST_result result5 = REST_BookSlot_YM.bookSlot(l.Id,'10:00 AM - 11:00 AM',system.today().addDays(1),'Book','','ok',false,CAid,null);
            system.assertEquals(result5.returnCode,200);
            REST_BookSlot_YM.REST_result result4 = REST_BookSlot_YM.bookSlot(l2.Id,'10:00 AM - 11:00 AM',system.today().addDays(1),'Book','','ok',false,CAid,null);
            system.assertEquals(result4.returnCode,209);
            REST_BookSlot_YM.REST_result result7 = REST_BookSlot_YM.bookSlot(l.Id,'10:00 AM - 11:00 AM',system.today().addDays(1),'Book','','ok',false,CAid,null);
            system.assertEquals(result7.returnCode,203);
            REST_BookSlot_YM.REST_result result8 = REST_BookSlot_YM.bookSlot(l.Id,'10:00 AM - 11:00 AM',system.today().addDays(1),'Cancel',result5.CRMEventId,'ok',false,CAid,null);
            system.assertEquals(result8.returnCode,200);
            REST_BookSlot_YM.REST_result result9 = REST_BookSlot_YM.bookSlot(l.Id,'10:00 AM - 11:00 AM',system.today().addDays(1),'Book','','ok',false,'xyz',null);
            system.assertEquals(result9.returnCode,207);
            
        Test.stopTest();
    }
    
    @isTest  
    private static void REST_Get_CA_Slot_YM_Test() {
        Map<string,string> resultMap = TestDataFactory.createContact();
        string CAid = resultMap.get('CA');
        string dealerId = resultMap.get('DEALER');
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId), c.Id);
        l.Skills__c = 'Nilaya';
        update l;
        
        Test.startTest();                   
            REST_GetSlots_YM.REST_result result6 = REST_GetSlots_YM.getSlots('123457','SPS',l.Id,null,null,0);
            system.assertEquals(result6.returnCode,200);
        Test.stopTest();
    }
    
    @isTest  
    private static void YM_Cross_Sell_LeadAPI_Test() {
        API_Integration__c api_endURL = new API_Integration__c();
        api_endURL.Name = 'YM Push Lead API';
        api_endURL.URL__c = 'https://app.yellowmessenger.com/integrations/yellowmessenger/receive';
        api_endURL.App_Version__c = 'x1573449987921';
        insert api_endURL;
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead_For_YM('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId), c.Id,false);
        
        Test.startTest();
            REST_CrossLead_YM.REST_result result = REST_CrossLead_YM.checkLead(null,null,null,null,null);
            system.assertEquals(result.returnCode,201);
            REST_CrossLead_YM.REST_result result2 = REST_CrossLead_YM.checkLead('00Q72000009QfrBEAS','BHS',null,null,null);
            system.assertEquals(result2.returnCode,202);
            REST_CrossLead_YM.REST_result result3 = REST_CrossLead_YM.checkLead(l.Id,'BHS',null,null,null);
            system.assertEquals(result3.returnCode,204);
            Service_Master__c sm2 = new Service_Master__c();
            sm2.Service__c = 'BHS';
            sm2.Skills__c = 'BHS';
            sm2.Slot_Duration_in_Hours__c = 1.00;
            insert sm2;
            
            SA_Pincode_Mapping__c pm = new SA_Pincode_Mapping__c();
            pm.Pincode__c = '123457';
            pm.Role__c = 'CES';
            pm.Priority__c = 1;
            pm.SA__c = null;
            pm.Service_Master__c = sm2.Id;
            insert pm;
            REST_CrossLead_YM.REST_result result4 = REST_CrossLead_YM.checkLead(l.Id,'BHS',null,null,null);
         //   system.assertEquals(result4.returnCode,205);
        Test.stopTest();
    }
    
}