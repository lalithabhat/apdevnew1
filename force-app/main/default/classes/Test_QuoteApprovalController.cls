@isTest
public class Test_QuoteApprovalController {

    @isTest
    static void QuoteController(){
        Opportunity o = new Opportunity();
        o.CloseDate = Date.today();
        o.Name = 'myOpportunity';
        o.StageName = 'Closed Won';
        o.RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
       
        insert o;
        Quote q = new Quote(Name = 'Q1', opportunityId = o.Id);
        insert q;
         Quote q1 = new Quote(Name = 'Q2', opportunityId = o.Id, Status ='Accepted');
        insert q1;
         Quote q2 = new Quote(Name = 'Q3', opportunityId = o.Id, Status ='Denied');
        insert q2;
        ApexPages.currentPage().getParameters().put('id', q.Id);
		QuoteApprovalController qc = new QuoteApprovalController();
        qc.approve();
        qc.reject();
         ApexPages.currentPage().getParameters().put('id', q1.Id);
		QuoteApprovalController qc1 = new QuoteApprovalController();
        ApexPages.currentPage().getParameters().put('id', q2.Id);
		QuoteApprovalController qc2 = new QuoteApprovalController();
       
       
    }
}