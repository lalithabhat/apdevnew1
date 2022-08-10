@isTest
public class TestSocialLeadServices {
    @isTest
    public static void successLead() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Campaign c = TestDataSetup.createCampaign('SPS', 'SPS');
        
        Test.startTest();
            Social_Lead__c s1 = new Social_Lead__c(Name = 'John Cena', Social_Mobile__c = '1122334455', Social_Email__c = 'john@cena.com', Social_Pincode__c = '111111', Lead_Id__c = '1', Social_Campaign_Id__c = 'SPS');
            insert s1;
            Social_Lead__c s2 = new Social_Lead__c(Name = 'John Cena', Social_Mobile__c = '1122334455', Social_Email__c = 'john@cena.com', Social_Pincode__c = '111111', Lead_Id__c = '2', Social_Campaign_Id__c = 'SPS');
            insert s2;
        Test.stopTest();
    }
    
    @isTest
    public static void errorLead() {
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Campaign c = TestDataSetup.createCampaign('SPS', 'SPS');
        
        Test.startTest();
            Social_Lead__c s1 = new Social_Lead__c(Name = 'John Cena1', Social_Mobile__c = '1122334455', Social_Email__c = 'john@cena.com', Social_Pincode__c = '111111', Lead_Id__c = '1', Social_Campaign_Id__c = 'SPS');
            insert s1;
            AP_SocialLeadManagementService.dummy();
        Test.stopTest();
    }
}