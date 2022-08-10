@isTest
public class TestLeadReAssign {
@isTest  
    private static void Test() {
       campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
         Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId),c.Id);
        
       	test.startTest();
        List<Id> LeadId = new List<Id>();
        LeadId.add(l.Id);
        LeadReAssign.getUsers(LeadId);
        
        test.stopTest();
     
    }
}