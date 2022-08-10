@isTest 
public class TestWorkControllers {
    @isTest
    private static void testGetShadeImage(){
         Test.setMock(HttpCalloutMock.class, new Mock());
        API_Integration__c a = new API_Integration__c();
        a.Name ='Shade Code API';
        a.URL__c = 'abc.com';
        insert a;
        Test.startTest();
        workCreationController.getShadeImage('7112');
        Test.stopTest();
        
       
    }
    @isTest
    private static void testValidateConsumption(){
        Work_Creation_Setting__c w = new Work_Creation_Setting__c();
        w.Enable_Consumption_Check__c =true;
        w.Start_Date__c = date.today();
        insert w;
        List<workCreationController.productItemWrapper> pw = new List<workCreationController.productItemWrapper>();
        workCreationController.productItemWrapper p = new workCreationController.productItemWrapper();
        p.consumption = new consumption__c();
        pw.add(p);
        workCreationController.validateConsumption(pw, null);
    }
   
     public class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setStatusCode(200);
            response.setBodyAsBlob(blob.valueOf('mock response'));
            return response;
        }
    }

	@isTest  
    private static void addWorkTest_I() {
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        Map<String,string> resultMap = TestDataFactory.createData_for_Quote(op.Id);
        string shcId = resultMap.get('SHC');
        string productId1 = resultMap.get('Product 1');
        string productId2 = resultMap.get('Product 2');
        set<string> productIds = new set<string>{productId1,productId2};
        string product_serialize = JSON.serialize(productIds);
        string portalId = resultMap.get('Portal USer');
        string SHC_Serialize = resultMap.get('SHC_Serialize');
        string dealerId = resultMap.get('DEALER');
        string Contractor = resultMap.get('Contractor 1');
        
        Test.startTest();
        	List<string> roomValues = Quotation.getRoomValues();
        	List<string> surfaceValues = Quotation.getSurfaceValues();
        	Map<string,string> dataMap = new Map<string,string>();
        	dataMap = TestQuotation.createData(productId1,productId2,surfaceValues[0],roomValues[0],dealerId);
        	string msg = Quotation.saveQuote(dataMap.get('quoteItems'), dataMap.get('productdiscounts'), dataMap.get('quotediscounts'), 
                                  dataMap.get('othercharge'), dataMap.get('paymentList'), dataMap.get('fieldset'), 
                                  SHC_Serialize,null,null
                                  );   
        
            Quote q = WorkCreationController.getQuoteDetails(msg);    
        	List<WorkCreationController.QuoteLevelProductWrapper> quoteLevelProd = WorkCreationController.getQuoteLevelProduct(msg);
        	list<Dealer_Contractor_Mapping__c> contractorList =  WorkCreationController.getContractorList(dealerId);
            List<WorkCreationController.productItemWrapper> addProduct = WorkCreationController.addProductItem(null, 'Consumption 1');
        	List<Product2> prodList = WorkCreationController.getProductItems('Other Top Coats');
        	
        Test.stopTest();
    }
    
    @isTest  
    private static void addWorkTest_II() {
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        Map<String,string> resultMap = TestDataFactory.createData_for_Quote(op.Id);
        string shcId = resultMap.get('SHC');
        string productId1 = resultMap.get('Product 1');
        string productId2 = resultMap.get('Product 2');
        set<string> productIds = new set<string>{productId1,productId2};
        string product_serialize = JSON.serialize(productIds);
        string portalId = resultMap.get('Portal USer');
        string SHC_Serialize = resultMap.get('SHC_Serialize');
        string dealerId = resultMap.get('DEALER');
        string Contractor = resultMap.get('Contractor 1');
        
        Milestone1_Project__c site = new Milestone1_Project__c();
        site.Status__c = 'Active';
        site.Kickoff__c = system.today();
        site.Deadline__c = system.today().addDays(1);
        site.Reason__c = 'First Site';
        site.PincodeLookup__c = pincode.Id;
        site.Account__c = ac.Id;
        insert site;
        
        Test.startTest();
        	List<string> roomValues = Quotation.getRoomValues();
        	List<string> surfaceValues = Quotation.getSurfaceValues();
        	Map<string,string> dataMap = new Map<string,string>();
        	dataMap = TestQuotation.createData(productId1,productId2,surfaceValues[0],roomValues[0],dealerId);
        	string msg = Quotation.saveQuote(dataMap.get('quoteItems'), dataMap.get('productdiscounts'), dataMap.get('quotediscounts'), 
                                  dataMap.get('othercharge'), dataMap.get('paymentList'), dataMap.get('fieldset'), 
                                  SHC_Serialize,null,null
                                  );  
        
        	Quote qToUpdate = new Quote();
        	qToUpdate.Id = msg;
        	qToUpdate.Site__c = site.Id;
        	qToUpdate.Contractor__c = Contractor;
        	qToUpdate.Status = 'Accepted';
        	update qToUpdate;
            Quote q = WorkCreationController.getQuoteDetails(msg);  
        	string quote_Serialize = Json.serialize(q);
        	string fieldSet = '[{"label":"moneyCollected","value":"1234"},{"label":"kickOff","value":"2022-01-21"},'+
                +'{"label":"deadLine","value":"2022-01-22"},{"label":"description","value":"ok"},'+
                +'{"label":"shadeCode","value":"AX"}]';
        	
        	List<WorkCreationController.productItemWrapper> items = new List<WorkCreationController.productItemWrapper>();
        	WorkCreationController.productItemWrapper item = new WorkCreationController.productItemWrapper();
        	Consumption__c c = new Consumption__c();
        	c.Name = 'Consumption 1';
        	c.Product__c = productId1;
        	c.Product_Family__c = 'Other Top Coats';
        	c.Quantity__c = 1;
        	item.consumption = c;
        	item.sequence = 0;
        	items.add(item);
        	string items_Serialize = Json.serialize(items);
        	Id workId = WorkCreationController.saveWork(fieldSet, items_Serialize, quote_Serialize, Contractor,getShadeImages());
        
        	Milestone1_Milestone__c work = WorkCreationController.getWorkDetails(workId);
        	string work_Serialize = Json.serialize(work);
        	List<WorkCreationController.productItemWrapper> existingConsumption = WorkCreationController.getExistingConsumption(workId);
       		Id newId = WorkCreationController.updateWork(fieldset, items_Serialize, work_Serialize);
        Test.stopTest();
    }
    
    @isTest  
    private static void addWorkTest_III() {
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        Map<String,string> resultMap = TestDataFactory.createData_for_Quote(op.Id);
        string shcId = resultMap.get('SHC');
        string productId1 = resultMap.get('Product 1');
        string productId2 = resultMap.get('Product 2');
        set<string> productIds = new set<string>{productId1,productId2};
        string product_serialize = JSON.serialize(productIds);
        string portalId = resultMap.get('Portal USer');
        string SHC_Serialize = resultMap.get('SHC_Serialize');
        string dealerId = resultMap.get('DEALER');
        string Contractor = resultMap.get('Contractor 1');
        
        Milestone1_Project__c site = new Milestone1_Project__c();
        site.Status__c = 'Active';
        site.Kickoff__c = system.today();
        site.Deadline__c = system.today().addDays(1);
        site.Reason__c = 'First Site';
        site.PincodeLookup__c = pincode.Id;
        site.Account__c = ac.Id;
        insert site;
        
        URL__c url = new URL__c();
        url.name = 'WorkApproval';
        url.URL__c = 'https://apldev-chatbottest.ind3s.sfdc-y37hzm.force.com/workapproval';
        insert url;
        
        Test.startTest();
        	List<string> roomValues = Quotation.getRoomValues();
        	List<string> surfaceValues = Quotation.getSurfaceValues();
        	Map<string,string> dataMap = new Map<string,string>();
        	dataMap = TestQuotation.createData(productId1,productId2,surfaceValues[0],roomValues[0],dealerId);
        	string msg = Quotation.saveQuote(dataMap.get('quoteItems'), dataMap.get('productdiscounts'), dataMap.get('quotediscounts'), 
                                  dataMap.get('othercharge'), dataMap.get('paymentList'), dataMap.get('fieldset'), 
                                  SHC_Serialize,null,null
                                  );  
        
        	Quote qToUpdate = new Quote();
        	qToUpdate.Id = msg;
        	qToUpdate.Site__c = site.Id;
        	qToUpdate.Contractor__c = Contractor;
        	qToUpdate.Status = 'Accepted';
        	update qToUpdate;
         WorkCreationController.isMoneyApprovalRequired(site.Id, 100000);
            Quote q = WorkCreationController.getQuoteDetails(msg);  
        	string quote_Serialize = Json.serialize(q);
        	string fieldSet = '[{"label":"moneyCollected","value":"1234"},{"label":"kickOff","value":"2022-01-21"},'+
                +'{"label":"deadLine","value":"2022-01-22"},{"label":"description","value":"ok"},'+
                +'{"label":"shadeCode","value":"AX"}]';
        	
        	List<WorkCreationController.productItemWrapper> items = new List<WorkCreationController.productItemWrapper>();
        	WorkCreationController.productItemWrapper item = new WorkCreationController.productItemWrapper();
        	Consumption__c c = new Consumption__c();
        	c.Name = 'Consumption 1';
        	c.Product__c = productId1;
        	c.Product_Family__c = 'Other Top Coats';
        	c.Quantity__c = 1;
        	item.consumption = c;
        	item.sequence = 0;
        	items.add(item);
        	string items_Serialize = Json.serialize(items);
        	Id workId = WorkCreationController.saveWork(fieldSet, items_Serialize, quote_Serialize, Contractor,getShadeImages());
        	Milestone1_Milestone__c workRecord = new Milestone1_Milestone__c();
        	workRecord.Id = workId;
        	workRecord.Approval_Status__c = 'Approval Pending';
        	update workRecord;
                
        	PageReference pRef2 = Page.Work_Schedule_Record_PDF;
            Test.setCurrentPage(pRef2);
        	ApexPages.currentPage().getParameters().put('id',workId);
            Work_S_R_PDF_Controller workSchedule = new Work_S_R_PDF_Controller();
        	
        	SharePanelGlobal.savePDFWrapper pdfresult = SharePanelGlobal.savePDF(workId, 'Milestone1_Milestone__c', 'Work Schedule');
        	pdfresult = SharePanelGlobal.getDocURL(workId);
        	pdfresult = SharePanelGlobal.getPublicURL(workId, 'Milestone1_Milestone__c', 'Work Schedule');
        	SharePanelGlobal.sendPDFCustomer(workId, 'Email', null, 'Milestone1_Milestone__c', 'Work Schedule');
        	SharePanelGlobal.sendToCustomer(workId, 'Email', 'Work Schedule', 'Milestone1_Milestone__c');
        
        	PageReference pRef3 = Page.WorkApprovalPage;
            Test.setCurrentPage(pRef3);
        	ApexPages.currentPage().getParameters().put('id',workId); 
            ApexPages.currentPage().getParameters().put('action','Rejected');
            WorkApprovalClass workApproval = new WorkApprovalClass();
        	workApproval.getWorkDetails();
        
        	WorkMoenyCollectedApprovalProcess approval = new WorkMoenyCollectedApprovalProcess();
        	approval.siteId = workId;
        	approval.getSiteDetails();
        	List<Consumption__c> consumptions = [select id,name from Consumption__c];
        	delete consumptions;
        	Milestone1_Milestone__c delWork = new Milestone1_Milestone__c();
        	delWork.Id = workId;
        	delete delWork;
        
        Test.stopTest();
    }
    
    @isTest  
    private static void addWorkTest_IV() {
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        Map<String,string> resultMap = TestDataFactory.createData_for_Quote(op.Id);
        string shcId = resultMap.get('SHC');
        string productId1 = resultMap.get('Product 1');
        string productId2 = resultMap.get('Product 2');
        set<string> productIds = new set<string>{productId1,productId2};
        string product_serialize = JSON.serialize(productIds);
        string portalId = resultMap.get('Portal USer');
        string SHC_Serialize = resultMap.get('SHC_Serialize');
        string dealerId = resultMap.get('DEALER');
        string Contractor = resultMap.get('Contractor 1');
        
        Milestone1_Project__c site = new Milestone1_Project__c();
        site.Status__c = 'Active';
        site.Kickoff__c = system.today();
        site.Deadline__c = system.today().addDays(1);
        site.Reason__c = 'First Site';
        site.PincodeLookup__c = pincode.Id;
        site.Account__c = ac.Id;
        insert site;
        
        URL__c url = new URL__c();
        url.name = 'WorkApproval';
        url.URL__c = 'https://apldev-chatbottest.ind3s.sfdc-y37hzm.force.com/workapproval';
        insert url;
        
        Test.startTest();
        	List<string> roomValues = Quotation.getRoomValues();
        	List<string> surfaceValues = Quotation.getSurfaceValues();
        	Map<string,string> dataMap = new Map<string,string>();
        	dataMap = TestQuotation.createData(productId1,productId2,surfaceValues[0],roomValues[0],dealerId);
        	string msg = Quotation.saveQuote(dataMap.get('quoteItems'), dataMap.get('productdiscounts'), dataMap.get('quotediscounts'), 
                                  dataMap.get('othercharge'), dataMap.get('paymentList'), dataMap.get('fieldset'), 
                                  SHC_Serialize,null,null
                                  );  
        
        	Quote qToUpdate = new Quote();
        	qToUpdate.Id = msg;
        	qToUpdate.Site__c = site.Id;
        	qToUpdate.Contractor__c = Contractor;
        	qToUpdate.Status = 'Accepted';
        	update qToUpdate;
            Quote q = WorkCreationController.getQuoteDetails(msg);  
        	string quote_Serialize = Json.serialize(q);
        	string fieldSet = '[{"label":"moneyCollected","value":"1234"},{"label":"kickOff","value":"2022-01-21"},'+
                +'{"label":"deadLine","value":"2022-01-22"},{"label":"description","value":"ok"},'+
                +'{"label":"shadeCode","value":"AX"}]';
        	
        	List<WorkCreationController.productItemWrapper> items = new List<WorkCreationController.productItemWrapper>();
        	WorkCreationController.productItemWrapper item = new WorkCreationController.productItemWrapper();
        	Consumption__c c = new Consumption__c();
        	c.Name = 'Consumption 1';
        	c.Product__c = productId1;
        	c.Product_Family__c = 'Other Top Coats';
        	c.Quantity__c = 1;
        	item.consumption = c;
        	item.sequence = 0;
        	items.add(item);
        	string items_Serialize = Json.serialize(items);
        	Id workId = WorkCreationController.saveWork(fieldSet, items_Serialize, quote_Serialize, Contractor,getShadeImages());
        	/*Milestone1_Milestone__c workRecord = new Milestone1_Milestone__c();
        	workRecord.Id = workId;
        	workRecord.Approval_Status__c = 'Approval Pending';
        	update workRecord;*/
        	Milestone1_Task__c task1 = new Milestone1_Task__c();
        	task1.Name = 'BEDROOM';
        	task1.Description_of_Area__c = 'BEDROOM';
        	task1.Activity_Details__c = 'Masking Covering';
        	task1.Project_Milestone__c  = workId;
        	task1.Start_Date__c = system.today();
        	task1.Due_Date__c = system.today().addDays(1);
        	insert task1;
        
            PageReference pRef = Page.Work_Progress_Card_PDF;
            Test.setCurrentPage(pRef);
        	ApexPages.currentPage().getParameters().put('id',workId);
            Work_Progress_Card_PDF workProgress = new Work_Progress_Card_PDF();
        
        	SharePanelGlobal.savePDFWrapper pdfresult = SharePanelGlobal.savePDF(workId, 'Milestone1_Milestone__c', 'Work Progress');
        	pdfresult = SharePanelGlobal.getDocURL(workId);
        	pdfresult = SharePanelGlobal.getPublicURL(workId, 'Milestone1_Milestone__c', 'Work Progress');
        	SharePanelGlobal.sendPDFCustomer(workId, 'Email', null, 'Milestone1_Milestone__c', 'Work Progress');
        	SharePanelGlobal.sendToCustomer(workId, 'Email', 'Work Progress', 'Milestone1_Milestone__c');
        	    
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
            contentlink.LinkedEntityId = workId;
            contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
            contentlink.ShareType = 'V';
            insert contentlink;
            ContentDistribution cd = new ContentDistribution();
            cd.ContentVersionId = contentVersion_2.Id;
            cd.Name = 'SampleTitle';
            cd.PreferencesNotifyOnVisit =false;
            insert cd;
        	
        	list<UpdateFileTagClass.FlowRequest> reqlist = new List<UpdateFileTagClass.FlowRequest>();
        	UpdateFileTagClass.FlowRequest req = new UpdateFileTagClass.FlowRequest();
        	req.tag = 'Before Picture:BEDROOM';
            List<string> contentId = new List<string>();
        	contentId.add(contentVersion_1.Id);
        	req.contentId = contentId;
        	List<string> result = UpdateFileTagClass.updateFileTag(reqlist);
        	reqlist.add(req);
        	List<string> result2 = UpdateFileTagClass.updateFileTag(reqlist);
        
        	PageReference pRef2 = Page.Site_Completion_Card_PDF;
            Test.setCurrentPage(pRef2);
        	ApexPages.currentPage().getParameters().put('id',site.Id);
            Site_Completion_Card_PDF siteCompletion = new Site_Completion_Card_PDF();
        
        	SharePanelGlobal.savePDFWrapper pdfresult2 = SharePanelGlobal.savePDF(site.Id, 'Milestone1_Project__c', 'Site Completion Card');
        	pdfresult2 = SharePanelGlobal.getDocURL(site.Id);
        	pdfresult2 = SharePanelGlobal.getPublicURL(site.Id, 'Milestone1_Project__c', 'Site Completion Card');
        	SharePanelGlobal.sendPDFCustomer(site.Id, 'Email', null, 'Milestone1_Project__c', 'Site Completion Card');
        	SharePanelGlobal.sendToCustomer(site.Id, 'Email', 'Site Completion Card', null);
        	
        	List<Id> workIds = new List<Id>();
        	workIds.add(workId);
        	List<string> str = CloseWork.updateWork(workIds);
                
        Test.stopTest();
    }
    
    public static List<WorkCreationController.shadeImage> getShadeImages(){
        List<WorkCreationController.shadeImage> si = new List<WorkCreationController.shadeImage>();
        return si;
    }
}