@isTest
public class TestREST_UpdateLead_YM2 {
    @isTest  
    public static void REST_UpdateLead_YM_Test() {
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
       		System.debug(result3.returnCode);
            system.assertEquals(result3.returnCode,202);    
        
        Test.stopTest();
    }
    
}