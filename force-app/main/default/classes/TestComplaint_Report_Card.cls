@isTest
public class TestComplaint_Report_Card {
    @isTest  
    private static void complaint_Report_Card_Test() {
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        Map<String,string> resultMap = TestDataFactory.createData_for_Quote(op.Id);
        string portalId = resultMap.get('Portal USer');
        string dealerId = resultMap.get('DEALER');
        string Contractor = resultMap.get('Contractor 1');
        
        Test.startTest();
            Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
            Case c = new Case();      
            c.AccountId = ac.Id;
            c.Opportunity__c = op.Id;
            c.subject = 'Service related query';
            c.Origin = 'Phone';
            c.RecordTypeId = caseRecordTypeId;
            c.Status = 'Working';
            c.Dealer__c = dealerId;
            insert c;
        
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
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = c.Id;
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
            reqlist.add(req);
            List<string> result = UpdateFileTagClass.updateFileTag(reqlist);
        
            ContentVersion contentVersion_II = new ContentVersion(
                Title= 'SampleTitle', 
                PathOnClient = 'SampleTitle.jpg',
                VersionData = bodyBlob, 
                origin = 'H'
            );
            insert contentVersion_II;
            
            ContentVersion contentVersion_III = [SELECT Id, Title, ContentDocumentId 
                                               FROM ContentVersion WHERE Id = :contentVersion_II.Id LIMIT 1];
            ContentDocumentLink contentlinkII = new ContentDocumentLink();
            contentlinkII.LinkedEntityId = c.Id;
            contentlinkII.contentdocumentid = contentVersion_III.contentdocumentid;
            contentlinkII.ShareType = 'V';
            insert contentlinkII;
            ContentDistribution cdII = new ContentDistribution();
            cdII.ContentVersionId = contentVersion_III.Id;
            cdII.Name = 'SampleTitle';
            cdII.PreferencesNotifyOnVisit =false;
            insert cdII;
        
            list<UpdateFileTagClass.FlowRequest> reqlist2 = new List<UpdateFileTagClass.FlowRequest>();
            UpdateFileTagClass.FlowRequest req2 = new UpdateFileTagClass.FlowRequest();
            req2.tag = 'After Picture:BEDROOM';
            List<string> contentId2 = new List<string>();
            contentId2.add(contentVersion_II.Id);
            req2.contentId = contentId2;
            reqlist2.add(req2);
            List<string> result2 = UpdateFileTagClass.updateFileTag(reqlist2);
        
            PageReference pRef = Page.Compaint_Report_PDF;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('id',c.Id);
            Complaint_Report_Card complaintCard = new Complaint_Report_Card();
        
            SharePanelGlobal.savePDFWrapper pdfresult2 = SharePanelGlobal.savePDF(c.Id, 'Case', 'Complaint Report Card');
            pdfresult2 = SharePanelGlobal.getDocURL(c.Id);
            pdfresult2 = SharePanelGlobal.getPublicURL(c.Id, 'Case', 'Complaint Report Card');
            SharePanelGlobal.sendPDFCustomer(c.Id, 'Email', null, 'Case', 'Complaint Report Card');
            SharePanelGlobal.sendToCustomer(c.Id, 'Email', 'Complaint Report Card', null);
                            
        Test.stopTest();
    }
}