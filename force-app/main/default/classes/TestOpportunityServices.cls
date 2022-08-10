@isTest
public class TestOpportunityServices {
    @isTest
    public static void oppAssignment() {
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Account accA = TestDataSetup.createAccountTemplate('TestPAa' , 'testpa1@twgtest.com', '9876544444');
        Id recSPSId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity opSPS = TestDataSetup.createSPSOpportunityTemplate(accA.Id, recSPSId, '111111', spsSetupMap.get('CA USER'), 'SPS');
        system.assert(opSPS.Service_Territory__c == null);
        
        Id recBHSId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Opportunity opBHS = TestDataSetup.createBHSOpportunityTemplate(accA.Id, recBHSId, '333333', spsSetupMap.get('CES USER'), 'BHS');
        system.assert(opBHS.Service_Territory__c == null);
        
        Opportunity opSPSNew = TestDataSetup.createSPSOpportunityTemplate(accA.Id, recSPSId, '111111', UserInfo.getUserId(), 'SPS');
        opSPSNew.OwnerId = spsSetupMap.get('CA USER');
        update opSPSNew;
    }
}