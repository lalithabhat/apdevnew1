@isTest
public class TestCollateralController {
    @isTest
    private static void collateral_LEAD_Test() {
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId),c.Id);
        List<Collateral__c> collateralList = TestDataFactory.createCollateral();
        Test.startTest();
            string email = CollateralController.getRecordDetails(l.Id);
            system.assertEquals(email,'email@stetig.in');
            List<string> serviceList = CollateralController.getServiceValues();
            List<string> subServiceList = CollateralController.getSubServiceValues();
            List<string> categoryList = CollateralController.getCategoryValues();
            List<Collateral__c> colLost = CollateralController.getCollateralsList('SPS', 'Nilaya', 'A');
            system.assert(colLost.size() == 1);
            string msg = CollateralController.sendMail(colLost, email, 'ccMail@stetig.in');
            system.assertEquals(msg,'Success');
        Test.stopTest();
    }
    
    @isTest
    private static void collateral_ACCOUNT_Test() {
        campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Account a = TestDataFactory.createPersonAccount('1234567234','email@stetig.in');
        List<Collateral__c> collateralList = TestDataFactory.createCollateral();
        Test.startTest();
            string email = CollateralController.getRecordDetails(a.Id);
            system.assertEquals(email,'email@stetig.in');
            List<string> serviceList = CollateralController.getServiceValues();
            List<string> subServiceList = CollateralController.getSubServiceValues();
            List<string> categoryList = CollateralController.getCategoryValues();
            List<Collateral__c> colLost = CollateralController.getCollateralsList('SPS', 'Nilaya', 'A');
            system.assert(colLost.size() == 1);
            string msg = CollateralController.sendMail(colLost, email, 'ccMail@stetig.in');
            system.assertEquals(msg,'Success');
            List<sObject> res = Lookup.search(null, 'Product2', null);
            List<sObject> res2 = Lookup.search('ACC', 'Product2', null);
        Test.stopTest();
    }
}