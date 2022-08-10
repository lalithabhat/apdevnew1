@isTest
public class Shade_Controller_Test {
    
    @isTest
    static void test(){
        Account cust=new Account();
        cust.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        cust.LastName='Customer';
        cust.PersonMobilePhone='1234567890';
        cust.PersonMailingCity='Nagpur';
        cust.PersonMailingCountry='India';
        insert cust;
        
        Account dlr=new Account();
        dlr.Name='Dealer';
        dlr.Phone='9876543210';
        dlr.BillingCity='Nagpur';
        dlr.BillingCountry='India';
        insert dlr;

      Milestone1_Project__c site =new Milestone1_Project__c();
        Site.Account__c=cust.Id;
        Site.Dealer__c=dlr.Id;
      // Site.Team_Lead_1_TL1__c=userinfo.getuserId();
      // Site.Team_Lead_2_TL2__c=userinfo.getuserId(); 
        insert site;
        
            Milestone1_Milestone__c work= new Milestone1_Milestone__c();
       work.Project__c=site.Id;
        insert work;
        
        	Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        	ContentVersion contentVersion_1 = new ContentVersion(
                Title= 'SampleTitle', 
                PathOnClient = 'SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
        
            insert contentVersion_1;
            
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            system.debug(contentversion_2);
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = work.Id;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            ContentDistribution cd = new ContentDistribution();
            cd.ContentVersionId = contentVersion_2.Id;
            cd.Name = 'SampleTitle';
            cd.PreferencesNotifyOnVisit =false;
            insert cd;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('id', site.Id);
        Shade_Controller sc=new Shade_Controller();
        
        SharePanelGlobal.savePDFWrapper pdfresult = SharePanelGlobal.savePDF(site.Id, 'Milestone1_Project__c', 'Shade Selection Card');
        pdfresult = SharePanelGlobal.getDocURL(site.Id);
        pdfresult = SharePanelGlobal.getPublicURL(site.Id, 'Milestone1_Project__c', 'Shade Selection Card');
        SharePanelGlobal.sendPDFCustomer(site.Id, 'Email', null, 'Milestone1_Project__c', 'Shade Selection Card');
        SharePanelGlobal.sendToCustomer(site.Id, 'Email', 'Shade Selection Card', 'Milestone1_Project__c');
        
        Test.stopTest();
       
    }

}