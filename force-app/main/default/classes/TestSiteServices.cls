@isTest
public class TestSiteServices {
    @isTest
    public static void siteCreationAgainstOpp() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        Test.startTest();
            Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '1233211233', Pincode__c = '111111', OwnerId = spsSetupMap.get('CA USER'), OTP_Verified__c = true);
            insert leadA;
            system.assert(leadA.TL1__c == null);
            convertlead.ResponseWrapper res1 = convertlead.convert(leadA.Id);
            List<Opportunity> op = APIMangementServices.getOpportunityRecord(leadA.Id);
            
            milestone1_project__c site = new milestone1_project__c(
                Account__c = op[0].AccountId,
                Kickoff__c = Date.today(),
                Deadline__c = Date.today() +5,
                New_Service__c = 'SPS',
                PincodeLookup__c = op[0].Pincode_lookup__c,
                Reason__c = 'First Site',
                SSO__c = op[0].SSO__c,
                Service_Territory_Name__c = op[0].Service_Territory_Name__c,
                Service_Territory__c = op[0].Service_Territory__c,
                Status__c ='Active',
                Team_Lead_1_TL1__c = op[0].Team_Lead_1_TL1__c,
                Team_Lead_2_TL2__c = op[0].Team_Lead_2_TL2__c,
                Tier__c = 'Classic',
                Unit_Head_UH__c = op[0].Unit_Head_UH__c,
                Opportunity__c = op[0].Id);
            insert site;
            site.OwnerId = spsSetupMap.get('CA USER');
            update site;
            op[0].Site__c = site.Id;
            update op[0];

        Test.stopTest();
    }
    
    @isTest
    public static void siteCreationAgainstOppWithoutTeamLead() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        Test.startTest();
            Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                                MobilePhone = '1233211233', Pincode__c = '111111', OwnerId = spsSetupMap.get('CA USER'), OTP_Verified__c = true);
            insert leadA;
            system.assert(leadA.TL1__c == null);
            convertlead.ResponseWrapper res1 = convertlead.convert(leadA.Id);
            List<Opportunity> op = APIMangementServices.getOpportunityRecord(leadA.Id);
            
            milestone1_project__c site = new milestone1_project__c(
                Account__c = op[0].AccountId,
                Kickoff__c = Date.today(),
                Deadline__c = Date.today() +5,
                New_Service__c = 'SPS',
                PincodeLookup__c = op[0].Pincode_lookup__c,
                Reason__c = 'First Site',
                SSO__c = op[0].SSO__c,
                Service_Territory_Name__c = op[0].Service_Territory_Name__c,
                Service_Territory__c = op[0].Service_Territory__c,
                Status__c ='Active',
                Tier__c = 'Classic',
                Unit_Head_UH__c = op[0].Unit_Head_UH__c,
                Opportunity__c = op[0].Id);
            insert site;
            site.OwnerId = spsSetupMap.get('CA USER');
            site.Team_Lead_1_TL1__c = op[0].Team_Lead_1_TL1__c;
            site.Team_Lead_2_TL2__c = op[0].Team_Lead_2_TL2__c;
            update site;

        Test.stopTest();
    }
}