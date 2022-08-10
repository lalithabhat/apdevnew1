@isTest
public class Test_Bot_updateAOD {
    Public static testMethod void doTest1() {
        Campaign c = TestDataSetup.createCampaign('SPS', 'SPS');
        TestDataSetup.createAODSetup(c);
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        TestDataSetup.enableApplicationLog();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Id recBHSId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Id recSLEEKId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SLEEK').getRecordTypeId();
        
        Test.startTest();
        convertlead.ResponseWrapper res3 = convertlead.convert(null);
        Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                              MobilePhone = '1233211233', Pincode__c = '111111', CampaignName__c = c.Id, OwnerId = spsSetupMap.get('CA USER'));
        insert leadA;
        List<Bot_updateAOD.PrechatInput> ipList = New List<Bot_updateAOD.PrechatInput>();
        Bot_updateAOD.PrechatInput cc = new Bot_updateAOD.PrechatInput();
        //Lead leadA = TestDataSetup.createLeadTemplate(recId, 'Test', 'Coverage', 't.1905202201@twgtest.com', '1905202201', '111111');
        cc.leadId = leadA.Id;  
        
        ipList.add(cc);
        List<Bot_updateAOD.PrechatOutput> Docs = Bot_updateAOD.updateAOD(ipList);
        Test.stopTest();
    }
}