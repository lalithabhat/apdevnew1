public class SharePanelGlobal {
    
    
    @Auraenabled
    public static void sendToCustomer(String shcId, String medium, String url, String objName){
        Map<String,String> input = new Map<String, String>();
        input.put('recordId',shcId);
        input.put('medium',medium);
        system.debug('shcId::'+shcId);
        system.debug('medium::'+medium);
        system.debug('objName::'+objName);
        if(string.isBlank(objName)){
            Id myId = shcId;
            objName = myId.getSObjectType().getDescribe().getName();
        }
        if(objName.equalsIgnoreCase('site_health_card__c')){
            Flow.Interview.Site_Health_Card_SMS flow1 = new Flow.Interview.Site_Health_Card_SMS(input);
            flow1.start();
        }
        else if(objName.equalsIgnoreCase('quote')){
            Flow.Interview.Quote_SMS_Email flow1 = new FLow.Interview.Quote_SMS_Email(input);
            flow1.start();
        }else if(objName.equalsIgnoreCase('Milestone1_Project__c')){
            Flow.Interview.Site_Completion_Card_SMS_Email flow1 = new FLow.Interview.Site_Completion_Card_SMS_Email(input);
            flow1.start();
        }
        else if(objName.equalsIgnoreCase('Milestone1_Project__c_SanAssure')){
            Flow.Interview.San_Assure_SMS_Email flow1 = new FLow.Interview.San_Assure_SMS_Email(input);
            flow1.start();
        }
        else if(objName.equalsIgnoreCase('Milestone1_Project__c_Warranty')){
            Flow.Interview.Site_Warranty_SMS_Email flow1 = new FLow.Interview.Site_Warranty_SMS_Email(input);
            flow1.start();
        }
        else if(objName.equalsIgnoreCase('Milestone1_Project__c_Shade')){
            Flow.Interview.Shade_Card_SMS_Email flow1 = new FLow.Interview.Shade_Card_SMS_Email(input);
            flow1.start();
        }
    }
    
    @auraenabled(cacheable=true)  
    public static savePDFWrapper getDocURL(String shcId){
        savePDFWrapper spw = new savePDFWrapper();
        
        List<ContentDocumentLink> cd = [SELECT ID, ContentDocumentId FROM  ContentDocumentLink WHERE LinkedEntityId =: shcId ];
        system.debug(cd);
        Set<ID> cdId = new Set<Id>();
        for(ContentDocumentLink c : cd){
            cdId.add(c.ContentDocumentId);
        }
        ContentDistribution c = [select id, ContentDownloadUrl, DistributionPublicUrl, PdfDownloadUrl from ContentDistribution where ContentDocumentId IN :cdId][0];//Assuming there will be only on distribution
        system.debug(c);
        spw.downloadURL = c.PdfDownloadUrl;
        spw.publicURL = c.DistributionPublicUrl;
        system.debug(spw);
        return spw;
    }
    
    public class savePDFWrapper{
        @Auraenabled public string contentDocumentID {get;set;}
        @Auraenabled public string downloadURL {get;set;}
        @Auraenabled public string publicURL {get;set;}
    }
    
    
    @Auraenabled
    public static  savePDFWrapper savePDF(String shcId,String objName,string buttonName){
        system.debug('shcId::'+shcId);
        system.debug('objName::'+objName);
        system.debug('objName::'+buttonName);
        if(string.isBlank(objName)){
            Id myId = shcId;
            objName = myId.getSObjectType().getDescribe().getName();
        }
        savePDFWrapper spw = new savePDFWrapper();
        PageReference PDf;
        if(objName.equalsIgnoreCase('site_health_card__c')){
            pdf =  Page.SHC_vf;
        } else if(objName.equalsIgnoreCase('quote')){
            pdf =  Page.QuoteOutput_WideRangeServices;
        }else if(objName.equalsIgnoreCase('Milestone1_Milestone__c')){
            if(buttonName == 'Work Schedule'){
                pdf =  Page.Work_Schedule_Record_PDF;
            }else if(buttonName == 'Work Progress'){
                pdf =  Page.Work_Progress_Card_PDF;
            }
        }else if(objName.equalsIgnoreCase('Milestone1_Project__c')){
            if(buttonName == 'Site Completion Card'){
                pdf =  Page.Site_Completion_Card_PDF;
            }
            else if(buttonName == 'Shade Selection Card'){
                system.debug('in shade card');
                pdf =  Page.Shade_vf;
            }
        }else if(objName == 'Case'){
            if(buttonName == 'Complaint Report Card'){
                pdf =  Page.Compaint_Report_PDF;
            }
        }  
        pDF.getParameters().put('id',shcId);
        PDf.setRedirect(true);
        Blob b;
        if(Test.isRunningTest()){
            b=Blob.valueOf('Unit Test ContentVersion Body to be insert in test class for testing the');
        }else{
            b =PDf.getContent();
        }
        string title;
        string pathclient;
        if(objName.equalsIgnoreCase('site_health_card__c')){
            title = 'Site Health Card';
            pathclient = 'Site_Health_Card.pdf';
        }else if(objName.equalsIgnoreCase('quote')){
            title = 'Quote';
            pathclient = 'Quote.pdf';
        }else if(objName.equalsIgnoreCase('Milestone1_Milestone__c')){
            if(buttonName == 'Work Schedule'){
                title = 'Work Schedule Record';
                pathclient = 'Work Schedule Record.pdf';
            }else if(buttonName == 'Work Progress'){
                title = 'Work Progress Card';
                pathclient = 'Work Progress Card.pdf';
            }
        }else if(objName.equalsIgnoreCase('Milestone1_Project__c')){
            if(buttonName == 'Site Completion Card'){
				title = 'Site Completion Card';
                pathclient = 'Site Completion Card.pdf';
            }
            else if(buttonName == 'Shade Selection Card'){
                title = 'Shade Card';
                pathClient = 'Shade Card.pdf';
            }
        }else if(objName == 'Case'){
            if(buttonName == 'Complaint Report Card'){
                title = 'Complaint Report Card';
                pathclient = 'Complaint Report Card.pdf';
            }
        }
        ContentVersion contentVersion_1 = new ContentVersion(
            Title= title, 
            PathOnClient = pathclient,
            VersionData = b, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        system.debug(contentversion_2);
        ContentDocumentLink contentlink = new ContentDocumentLink();
        // contentlink.LinkedEntityId = '00672000000I5xJAAS';
        contentlink.LinkedEntityId = shcId;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        ContentDistribution cd = new ContentDistribution();
        cd.ContentVersionId = contentVersion_2.Id;
        cd.Name = title + ' - ' + Date.today().format();
        cd.PreferencesNotifyOnVisit =false;
        insert cd;
        system.debug(cd.id);
        ContentDistribution c = [select id, ContentDownloadUrl, DistributionPublicUrl, PdfDownloadUrl from ContentDistribution where id =: cd.Id][0];
        spw.contentDocumentId = contentVersion_2.ContentDocumentId;
        spw.downloadURL = c.PdfDownloadUrl;
        spw.publicURL = c.DistributionPublicUrl;
        
        if(objName.equalsIgnoreCase('site_health_card__c')){
            site_health_card__c s = new site_health_card__c(Id = shcId, public_URL__c =c.DistributionPublicUrl );
            update s;
        }
        else if(objName.equalsIgnoreCase('quote')){
            Quote q = new Quote();
            q.Id = shcId;
            q.Public_URL__c = c.DistributionPublicUrl;
            URL__c url = [SELECT URL__c FROM URL__c WHERE Name =:'Quote Approval'][0];
            q.Quote_Approval_Link__c = url.url__c +'?id='+ shcId;
            update q;
        }else if(objName.equalsIgnoreCase('Milestone1_Milestone__c')){
            Milestone1_Milestone__c w = new Milestone1_Milestone__c();
            w.Id = shcId;
            if(buttonName == 'Work Schedule'){
                w.Work_Schedule_Public_URL__c = c.DistributionPublicUrl;
                w.Work_Schedule_Download_URL__c = c.PdfDownloadUrl;
            }else if(buttonName == 'Work Progress'){
                w.Work_Progress_Report_Public_URL__c = c.DistributionPublicUrl;
                w.Work_Progress_Report_Download_URL__c = c.PdfDownloadUrl;
            }
            update w;
        }else if(objName.equalsIgnoreCase('Milestone1_Project__c')){
            Milestone1_Project__c site = new Milestone1_Project__c();
            site.Id = shcId;
            if(buttonName == 'Site Completion Card'){
                site.Site_Completion_Card_Download_URL__c = c.PdfDownloadUrl;
                site.Site_Completion_Card_Public_URL__c = c.DistributionPublicUrl;
            }
            else if(buttonName == 'Shade Selection Card'){
                site.Shade_Card_Download_URL__c = c.PdfDownloadUrl;
                site.Shade_Card_URL__c = c.DistributionPublicUrl;
            }
            update site;
        }else if(objName == 'Case'){
            Case cObj = new Case();
            cObj.Id = shcId;
            if(buttonName == 'Complaint Report Card'){
                cObj.Complaint_Report_Download_URL__c = c.PdfDownloadUrl;
                cObj.Complaint_Report_Public_URL__c = c.DistributionPublicUrl;
            }
            update cObj;
        }
        return spw;
    }
    
    @auraenabled(cacheable=true)  
    public static savePDFWrapper getPublicURL (String recordId, string objName, string buttonName){
        savePDFWrapper spw = new savePDFWrapper();
        if(string.isBlank(objName)){
            Id myId = recordId;
            objName = myId.getSObjectType().getDescribe().getName();
        }
        if(objName == 'Milestone1_Milestone__c'){
            List<Milestone1_Milestone__c> workRecord = [select id,name,Work_Progress_Report_Public_URL__c,
                                                        Work_Schedule_Public_URL__c,Work_Progress_Report_Download_URL__c,
                                                        Work_Schedule_Download_URL__c from Milestone1_Milestone__c where 
                                                        id=:recordId];
            if(buttonName == 'Work Schedule'){
                if(workRecord[0].Work_Schedule_Public_URL__c != null){
                    spw.publicURL = workRecord[0].Work_Schedule_Public_URL__c;
                    spw.downloadURL = workRecord[0].Work_Schedule_Download_URL__c;
                    
                }
            }else if(buttonName == 'Work Progress'){
                if(workRecord[0].Work_Progress_Report_Public_URL__c != null){
                    spw.publicURL = workRecord[0].Work_Progress_Report_Public_URL__c;
                    spw.downloadURL = workRecord[0].Work_Progress_Report_Download_URL__c;
                    
                }
            }
        }else if(objName == 'Milestone1_Project__c'){
            List<Milestone1_Project__c> siteRecord = [select id,name,Site_Completion_Card_Download_URL__c,
                                                      Site_Completion_Card_Public_URL__c,Shade_Card_URL__c,Shade_Card_Download_URL__c from Milestone1_Project__c where 
                                                      id=:recordId];
            if(buttonName == 'Site Completion Card'){
                if(siteRecord[0].Site_Completion_Card_Public_URL__c != null){
                    spw.publicURL = siteRecord[0].Site_Completion_Card_Public_URL__c;
                    spw.downloadURL = siteRecord[0].Site_Completion_Card_Download_URL__c;
                    
                }
            }
            else if(buttonName == 'Shade Selection Card'){
                if(siteRecord[0].Shade_Card_URL__c != null){
                    spw.publicURL = siteRecord[0].Shade_Card_URL__c;
                    spw.downloadURL = siteRecord[0].Shade_Card_Download_URL__c;
                    
                }
            }
        }else if(objName == 'Case'){
            List<Case> CaseRecord = [select id,caseNumber,Complaint_Report_Download_URL__c,
                                     Complaint_Report_Public_URL__c from Case where 
                                     id=:recordId];
            if(buttonName == 'Complaint Report Card'){
                if(CaseRecord[0].Complaint_Report_Public_URL__c != null){
                    spw.publicURL = CaseRecord[0].Complaint_Report_Public_URL__c;
                    spw.downloadURL = CaseRecord[0].Complaint_Report_Download_URL__c;
                    
                }
            }
        }        
        system.debug(spw);
        return spw;
    }
    
    @Auraenabled
    public static void sendPDFCustomer(String shcId, String medium, String url, String objName, string buttonName){
        Map<String,String> input = new Map<String, String>();
        input.put('recordId',shcId);
        input.put('medium',medium);
        system.debug('shcId::'+shcId);
        system.debug('medium::'+medium);
        system.debug('objName::'+objName);
        if(string.isBlank(objName)){
            Id myId = shcId;
            objName = myId.getSObjectType().getDescribe().getName();
        }
        if(objName.equalsIgnoreCase('site_health_card__c')){
            Flow.Interview.Site_Health_Card_SMS flow1 = new Flow.Interview.Site_Health_Card_SMS(input);
            flow1.start();
        }
        else if(objName.equalsIgnoreCase('quote')){
            Flow.Interview.Quote_SMS_Email flow1 = new FLow.Interview.Quote_SMS_Email(input);
            flow1.start();
        }else if(objName.equalsIgnoreCase('Milestone1_Project__c')){
            if(buttonName == 'SiteCompletion'){
            Flow.Interview.Site_Completion_Card_SMS_Email flow1 = new FLow.Interview.Site_Completion_Card_SMS_Email(input);
            flow1.start();
            }
            else if(buttonName == 'SanAssure'){
            Flow.Interview.San_Assure_SMS_Email flow1 = new FLow.Interview.San_Assure_SMS_Email(input);
            flow1.start();
            }
            else if(buttonName == 'Warranty'){
            Flow.Interview.Site_Warranty_SMS_Email flow1 = new FLow.Interview.Site_Warranty_SMS_Email(input);
            flow1.start();
            }
        }else if(objName.equalsIgnoreCase('Milestone1_Milestone__c')){
            if(buttonName == 'Work Schedule'){
                Flow.Interview.Work_Schedule_Report_Email_SMS flow1 = new FLow.Interview.Work_Schedule_Report_Email_SMS(input);
                flow1.start();
            }else if(buttonName == 'Work Progress'){
                Flow.Interview.Work_Progress_Card_SMS_Email flow1 = new FLow.Interview.Work_Progress_Card_SMS_Email(input);
                flow1.start();
            }
            
        }else if(objName.equalsIgnoreCase('Case')){
            if(buttonName == 'Complaint Report Card'){
                Flow.Interview.Complaint_Report_Card flow1 = new FLow.Interview.Complaint_Report_Card(input);
                flow1.start();
            }
            
        }
    }
    
}