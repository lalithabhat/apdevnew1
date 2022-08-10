public class WorkApprovalClass {

    public string wId {get;set;}
    public string action {get;set;}
    public List<Milestone1_Milestone__c> siteRecord {get;set;}
    
    public WorkApprovalClass(){
        wId = ApexPages.currentPage().getParameters().get('id');
        action = ApexPages.currentPage().getParameters().get('action');
        siteRecord = new List<Milestone1_Milestone__c>();
    }
    
    public void getWorkDetails(){
        DescribeSObjectResult describeResultWork = Milestone1_Milestone__c.getSObjectType().getDescribe();  
        List<String> fieldNamesWork = new List<String>( describeResultWork.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNamesWork, ',' ) + ',Opportunity__r.Account.Name,' +
            'Project__r.Contractor__r.Name, Project__r.Dealer__r.Name,Opportunity__r.Account.PersonMobilePhone, ' +
            'Project__r.Contractor__r.Phone, Project__r.Dealer__r.Phone,Project__r.Dealer__r.BillingStreet,Project__r.Dealer__r.BillingCity,' +
            'Project__r.Dealer__r.BillingState,Project__r.Dealer__r.BillingCountry,Project__r.Dealer__r.BillingPostalCode,' + 
            'Project__r.Kickoff__c,Project__r.Deadline__c,Quote__r.lastmodifiedDate,Quote__r.Site_Health_Card__r.createdDate, ' +
            'Quote__r.Public_URL__c,Quote__r.Site_Health_Card__r.Public_URL__c,Quote__r.owner.FirstName,Quote__r.owner.LastName ' +
            ' FROM ' + describeResultWork.getName() + ' where Id =' + '\'' + wId + '\'';
        
        siteRecord = Database.query(query);
        if(siteRecord[0].Approval_Status__c != 'Approval Pending'){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Looks like the site value approval already done.'));
        }else if(action == 'Approved'){
            siteRecord[0].Approval_Status__c = 'Approved';
            update siteRecord;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Approved Successfully.'));
        }else if(action == 'Rejected'){
            siteRecord[0].Approval_Status__c = 'Rejected';
            update siteRecord;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Rejected Successfully.'));
        }
    }
    
}