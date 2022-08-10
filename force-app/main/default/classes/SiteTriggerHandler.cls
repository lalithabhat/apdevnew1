public class SiteTriggerHandler {
    
    
    @Auraenabled public static Milestone1_Project__c getSite(String recordId){
        return  [Select status__c, Tier__c, New_Service__c from Milestone1_Project__c where ID =: recordId];
    }
    @Auraenabled(cacheable =true) public static SharePanelGlobal.savePDFWrapper getURL(String recordId, String docType){
        SharePanelGlobal.savePDFWrapper sw = new SharePanelGlobal.savePDFWrapper();
        Milestone1_Project__c s= [Select Warranty_Card_Download_URL__c, Warranty_Card_URL__c, Site_Certificate_Download_URL__c, Site_Certificate_URL__c from Milestone1_Project__c where ID =: recordId];
        if(docType =='Warranty'){
            sw.publicURL = s.Warranty_Card_URL__c;
            sw.downloadURL =s.Warranty_Card_Download_URL__c;
        }
        else{
            sw.publicURL =s.Site_Certificate_URL__c;
            sw.downloadURL =s.Site_Certificate_Download_URL__c;
        }
        return sw;
    }

    @InvocableMethod(label='Create Site Certificate'  category='Other')
    public static void createCert(List<Id> siteId){
        Milestone1_Project__c site = [Select New_Service__c, Tier__c from Milestone1_Project__c WHERE ID =: siteId[0]];
        PageReference pdf;
        if(site.New_Service__c =='San Assure') pdf = Page.San_Assure_Certificate;
        else  if(site.New_Service__c =='San Assure +') pdf = Page.San_AssurePlus_Certificate;
        else  if(site.New_Service__c =='San Assure Advanced') pdf = Page.San_Assure_Advance;
        Milestone1_Project__c siteN= new Milestone1_Project__c(Id = siteId[0]);
        if(pdf !=null){
            pDF.getParameters().put('id',siteId[0]);
            SharePanelGlobal.savePDFWrapper sw  = insertFile(pdf,site.Id, 'SiteCertificate');
            siteN.Site_Certificate_URL__c = sw.publicURL;
            siteN.Site_Certificate_Download_URL__c = sw.downloadURL;
        }
        if(site.Tier__c == 'Platinum'){
            pdf = Page.WarrantyCardPdf;
            pDF.getParameters().put('id',siteId[0]);
            SharePanelGlobal.savePDFWrapper sw  = insertFile(pdf,site.Id, 'WarrantyCard');
            siteN.Warranty_Card_URL__c = sw.publicURL; 
            siteN.Warranty_Card_Download_URL__c = sw.downloadURL;
           
        }
        pdf = Page.Site_Completion_Card_PDF;
        pDF.getParameters().put('id',siteId[0]);
        SharePanelGlobal.savePDFWrapper sw  = insertFile(pdf,site.Id, 'WarrantyCard');
        siteN.Site_Completion_Card_Public_URL__c = sw.publicURL; 
        siteN.Site_Completion_Card_Download_URL__c = sw.downloadURL;
        update siteN;
    }
    
    public static SharePanelGlobal.savePDFWrapper insertFile(PageReference PDF, ID siteId, String title){
        SharePanelGlobal.savePDFWrapper sw = new SharePanelGlobal.savePDFWrapper();
        
        pDF.getParameters().put('id',siteId);
        PDf.setRedirect(true);
        Blob b;
        if(Test.isRunningTest()) b = blob.valueOf('Unit.Test');
		else  b=PDf.getContent();
            
        ContentVersion contentVersion_1 = new ContentVersion(
            Title= title, 
            PathOnClient =title +'.pdf',
            VersionData = b, 
            origin = 'H'
        );
        insert contentVersion_1;
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        system.debug(contentversion_2);
        ContentDocumentLink contentlink = new ContentDocumentLink();
        // contentlink.LinkedEntityId = '00672000000I5xJAAS';
        contentlink.LinkedEntityId = siteId;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        ContentDistribution cd = new ContentDistribution();
        cd.ContentVersionId = contentVersion_2.Id;
        cd.Name = title + Date.today().format();
        cd.PreferencesNotifyOnVisit =false;
        insert cd;
        system.debug(cd.id);
        ContentDistribution c = [select id, ContentDownloadUrl, DistributionPublicUrl, PdfDownloadUrl from ContentDistribution where id =: cd.Id][0];
        system.debug(c.DistributionPublicUrl); 
        sw.publicURL = c.DistributionPublicUrl;
        sw.downloadURL =c.PdfDownloadUrl;
        
        return sw;
    }
        @Auraenabled public static void setStatus(String recordId, String status){
      /*  Milestone1_Project__c s = new Milestone1_Project__c(Id= recordid, Status__c = status);
        update s;
        Milestone1_Project__c site =[Select Name,Team_Lead_1_TL1__c, Account__r.Name ,Tier__c, Account__r.PersonMobilePhone,  Account__r.PersonEmail ,status__c from Milestone1_Project__c where ID =: recordId];
        if(site.Team_Lead_1_TL1__c !=null){
            String msg = 'Please note that the work at '+  site.Name +' has been completed. Please complete Technical Audit.'
                + '\n Customer Name: ' + site.Account__r.Name 
                + '\n  Customer Mobile: ' + site.Account__r.PersonMobilePhone 
                + '\n Customer Email: ' + site.Account__r.PersonEmail
                + '\n Site Tier: ' + site.Tier__c;
            
            
            Set<String> recipient = new Set<String>{site.Team_Lead_1_TL1__c}; 
                Notification_Utility.notifyUsers(recipient,recordId,'Work Completion Report Alert', msg);
        }  */                
    }
}