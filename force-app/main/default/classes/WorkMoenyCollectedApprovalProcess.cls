public class WorkMoenyCollectedApprovalProcess {

    public id siteId{get;set;}
    public string dealerName{get;set;}
    public string customerName{get;set;}
    public decimal siteValue{get;set;}
    public string CAName{get;set;}
    public string kickoffDate{get;set;}
    public List<Milestone1_Milestone__c> siteRecord {get;set;}
    public string urllink {get;set;}
    public string urllink_Approve {get;set;}
    public string urllink_Reject {get;set;}
    
    public WorkMoenyCollectedApprovalProcess(){
        siteRecord = new List<Milestone1_Milestone__c>();
    }
    
    public void getSiteDetails() {
        DescribeSObjectResult describeResultWork = Milestone1_Milestone__c.getSObjectType().getDescribe();  
        List<String> fieldNamesWork = new List<String>( describeResultWork.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNamesWork, ',' ) + ',Opportunity__r.Account.Name,' +
            'Project__r.Contractor__r.Name, Project__r.Dealer__r.Name,Opportunity__r.Account.PersonMobilePhone, ' +
            'Project__r.Contractor__r.Phone, Project__r.Dealer__r.Phone,Project__r.Dealer__r.BillingStreet,Project__r.Dealer__r.BillingCity,' +
            'Project__r.Dealer__r.BillingState,Project__r.Dealer__r.BillingCountry,Project__r.Dealer__r.BillingPostalCode,' + 
            'Project__r.Kickoff__c,Project__r.Deadline__c,Quote__r.lastmodifiedDate,Quote__r.Site_Health_Card__r.createdDate, ' +
            'Quote__r.Public_URL__c,Quote__r.Site_Health_Card__r.Public_URL__c,Quote__r.owner.FirstName,Quote__r.owner.LastName, ' +
            'Project__r.Total_Money_Collected_Work__c ' +
            ' FROM ' + describeResultWork.getName() + ' where Id =' + '\'' + siteId + '\'';
        
        siteRecord = Database.query(query);
        dealerName = siteRecord[0].Project__r.Dealer__r.Name;
        customerName = siteRecord[0].Opportunity__r.Account.Name;
        CAName = siteRecord[0].Quote__r.owner.FirstName + ' ' + siteRecord[0].Quote__r.owner.lastName;
        siteValue = siteRecord[0].Project__r.Total_Money_Collected_Work__c; 
        kickoffDate = siteRecord[0].Project__r.Kickoff__c.format();
        URL__c url = [SELECT URL__c FROM URL__c WHERE Name =:'WorkApproval'][0];
        urllink = url.url__c +'?id=' + siteRecord[0].Id;
        urllink_Approve = urllink + '&action=Approved';
        urllink_Reject = urllink + '&action=Rejected';
    }
    
  
    
}