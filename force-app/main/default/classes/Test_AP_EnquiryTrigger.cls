@isTest
public class Test_AP_EnquiryTrigger {
    @isTest
    public static void TestAODDetail() {
        Campaign c = TestDataSetup.createCampaign('SPS', 'SPS');
        TestDataSetup.createAODSetup(c);
        TestDataSetup.createServiceabilitySetup();
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        TestDataSetup.enableApplicationLog();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Id recBHSId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
        Id recSLEEKId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SLEEK').getRecordTypeId();
        
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new TestMockHttpResponseGeneratorForCTI());
        
        convertlead.ResponseWrapper res3 = convertlead.convert(null);
        Lead leadA = new Lead(RecordTypeId = recId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa1@twgtest.com', 
                              MobilePhone = '1233211233', Pincode__c = '111111', CampaignName__c = c.Id, OwnerId = spsSetupMap.get('CA USER'));
        insert leadA;
        Enquiry__c en = New Enquiry__c();
        en.Name = 'Test';
        en.Lead__c = leadA.Id;
        en.Campaign__c = leadA.CampaignName__c;
        insert en;
        convertlead.ResponseWrapper res = convertlead.convert(leadA.Id);
        //leadA.MobilePhone = '1233211234';
        leadA.OTP_Verified__c = true;
        leadA.Street = 'Range Hills';
        leadA.City = 'Pune';
        leadA.State = 'Maharashtra';
        leadA.Country = 'India';
        leadA.PostalCode = '111111';
        update leadA;
        
        convertlead.ResponseWrapper res1 = convertlead.convert(leadA.Id);
        
        Lead leadB = new Lead(RecordTypeId = recBHSId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa2@twgtest.com', 
                              MobilePhone = '1233211235', Pincode__c = '333333', CampaignName__c = c.Id, Lead_In_Calling_Queue__c = true);
        insert leadB;
        leadB.Street = 'Range Hills';
        leadB.OwnerId = spsSetupMap.get('CES USER');
        leadB.Status = 'Allocation Done';
        update leadB;
        
        Lead_Service__c l = new Lead_Service__c(Name = 'SLEEK');
        insert l;
        Lead leadC = new Lead(RecordTypeId = recSLEEKId, FirstName = 'Test', LastName = 'Lead', Email = 'testpa3@twgtest.com', 
                              MobilePhone = '1233211231', Pincode__c = '333333', Skills__c = 'SLEEK');
        insert leadC;
        leadC.Pincode__c = '111111';
        update leadC;
        leadC.Dealer__c = spsSetupMap.get('DEALER');
        leadC.Status = 'Allocation Done';
        update leadC;
        Test.stopTest();
    }
    
    /*@isTest
    public static void Test1() {
        Test.startTest();
        
        Map<String, Id> spsSetupMap = TestDataSetup.createSPSLeadCreationSetup();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataSetup.createLeadTemplate(recId, 'Test', 'Lead A', 'testleada@twgtest.com', '9876544000', '111111');
        
        
        
Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
List<Campaign> c = [SELECT Id, Name FROM Campaign Where Name like '%SPS%' AND Taggable_Campaign__c = True AND IsActive = True];
System.debug('c : '+c);
Lead l = New Lead();
l.LastName = 'Test';
l.MobilePhone = '2203202212';
//l.CampaignName__c= c[0].Id;
l.Pincode__c = '999999';
l.LeadSource = 'Website';
l.Skills__c = 'SPS';
l.RecordTypeId = recId;
insert l;

        Enquiry__c en = New Enquiry__c();
        en.Name = 'Test';
        en.Lead__c = l.Id;
        insert en;
        Test.stopTest();    
    }
*/
}