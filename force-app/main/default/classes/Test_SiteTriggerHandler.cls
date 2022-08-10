@isTest
public class Test_SiteTriggerHandler {

    @isTest
    static void test(){
        Milestone1_Project__c site = new Milestone1_Project__c(status__c ='Active', Tier__c ='Platinum', New_Service__c ='San Assure');
        Insert site;
        SiteTriggerHandler.getSite(site.Id);
        SiteTriggerHandler.getURL(site.Id, 'Warranty');
        SiteTriggerHandler.getURL(site.Id, 'Certificate');
        List<Id> idList = new List<Id>{site.Id};
            SIteTriggerHandler.createCert(idList);
        
         ApexPages.currentPage().getParameters().put('id', site.Id);
		SanAssureController qc1 = new SanAssureController();
        WarrantyCardController w = new WarrantyCardController();
        
    }
}