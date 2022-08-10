public class Work_S_R_PDF_Controller {
    
    public Milestone1_Milestone__c work{get;set;}
    public List<Milestone1_Milestone__c> workRecord{get;set;}
    public string wId{get;set;}
    public string Today_Date{get;set;}
    public string customerName{get;set;}
    public string customerMobile{get;set;}
    public string contractorName{get;set;}
    public string contractorMobile{get;set;}
    public string visitedBy{get;set;}
    public string visitedMobile{get;set;}
     public string siteName{get;set;}
    public string dealerName{get;set;}
    public string dealerAddress{get;set;}
    public string dealerMobile{get;set;}
    public string quoteApprovalDate{get;set;}
    public string siteStartDate{get;set;}
    public string siteCompletionDate{get;set;}
    public string SHCDate{get;set;}
    public string SHCLink{get;set;}
    public string quoteLink{get;set;}
    Public List<Milestone1_Task__c > taskList {get;set;}
    public string Total_no_Days{get;set;}
    public string associate_Name{get;set;}
    public string associate_Contact{get;set;}
    public string Tech_associate_Name{get;set;}
    public string Tech_associate_Contact{get;set;}
    public string team_Lead_Name{get;set;}
    public string team_lead_Contact{get;set;}
    public string tier{get;set;}
    public string services{get;set;}
    public string description{get;set;}
    
    public Work_S_R_PDF_Controller(){
        wId = ApexPages.currentPage().getParameters().get('id');
       // wId= 'a0C7200000FcKjREAV';
        workRecord = new List<Milestone1_Milestone__c>();
        Today_Date = system.today().format();
        tier = '';
        services = '';
        description = '';
        
        DescribeSObjectResult describeResultWork = Milestone1_Milestone__c.getSObjectType().getDescribe();  
        List<String> fieldNamesWork = new List<String>( describeResultWork.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNamesWork, ',' ) + ',Opportunity__r.Account.Name,' +
            'Contractor__r.Name, Project__r.Dealer__r.Name,Opportunity__r.Account.PersonMobilePhone, ' +
            'Contractor__r.Phone, Project__r.Dealer__r.Phone,Project__r.Dealer__r.BillingStreet,Project__r.Dealer__r.BillingCity,' +
            'Project__r.Dealer__r.BillingState,Project__r.Dealer__r.BillingCountry,Project__r.Dealer__r.BillingPostalCode,' + 
            'Project__r.Kickoff__c,Project__r.Deadline__c,Quote__r.lastmodifiedDate,Quote__r.Site_Health_Card__r.createdDate, ' +
            'Quote__r.Public_URL__c,Quote__r.Site_Health_Card__r.Public_URL__c,Team_Lead_1_TL1__r.contact.name,Team_Lead_1_TL1__r.ContactId,' +
            'Team_Lead_1_TL1__r.contact.mobilePhone,Team_Lead_2_TL2__r.contact.name,Team_Lead_2_TL2__r.ContactId,Team_Lead_2_TL2__r.contact.mobilePhone,' +
            'Opportunity__r.Owner.contact.name,Opportunity__r.Owner.ContactId,Opportunity__r.Owner.contact.mobilePhone,' + 
            'Quote__r.Tier__c,Quote__r.New_Services__c, Project__r.owner.Name,Project__r.OwnerId, Project__r.Name ' +
            ' FROM ' + describeResultWork.getName() + ' where Id =' + '\'' + wId + '\'';
        
        workRecord = Database.query(query);
        visitedBy = workRecord[0].Project__r.owner.Name;
        List<User> u = [Select Contact.MobilePhone from user where id =: workRecord[0].Project__r.OwnerId];
        if(!u.isEmpty() && u[0].COntact.MobilePhone !=null) visitedMobile = u[0].Contact.MobilePhone;
        else visitedMobile = '';
         siteName = workRecord[0].Project__r.Name;
        customerName = workRecord[0].Opportunity__r.Account.Name;
        customerMobile = workRecord[0].Opportunity__r.Account.PersonMobilePhone;
        contractorName = workRecord[0].Contractor__r.Name;
        contractorMobile = workRecord[0].Contractor__r.Phone;
        dealerName = workRecord[0].Project__r.Dealer__r.Name;
        dealerMobile = workRecord[0].Project__r.Dealer__r.Phone;
        quoteApprovalDate = workRecord[0].Quote__r.lastmodifiedDate.Date().format();
        dealerAddress ='';
        if(workRecord[0].Project__r.Kickoff__c != null){
            siteStartDate = workRecord[0].Project__r.Kickoff__c.format();
        }
        if(workRecord[0].Project__r.Deadline__c != null){
            siteCompletionDate = workRecord[0].Project__r.Deadline__c.format();
        }
        if(workRecord[0].Project__r.Dealer__r.BillingStreet != null){
            dealerAddress = workRecord[0].Project__r.Dealer__r.BillingStreet + ',';
            //dealerAddress = dealerAddress.replaceAll('r','<br />'); 
        }
        if(workRecord[0].Project__r.Dealer__r.BillingCity != null){
            dealerAddress = dealerAddress + workRecord[0].Project__r.Dealer__r.BillingCity + ', ';
        }
        if(workRecord[0].Project__r.Dealer__r.BillingState != null){
            dealerAddress = dealerAddress + workRecord[0].Project__r.Dealer__r.BillingState + ', ';
        }
        if(workRecord[0].Project__r.Dealer__r.BillingCountry != null){
            dealerAddress = dealerAddress + workRecord[0].Project__r.Dealer__r.BillingCountry + ', ';
        }
        if(workRecord[0].Project__r.Dealer__r.BillingPostalCode != null){
            dealerAddress = dealerAddress + workRecord[0].Project__r.Dealer__r.BillingPostalCode;
        }
        SHCDate = workRecord[0].Quote__r.Site_Health_Card__r.createdDate.date().format();
        SHCLink = workRecord[0].Quote__r.Site_Health_Card__r.Public_URL__c;
        quoteLink = workRecord[0].Quote__r.Public_URL__c;
        Total_no_Days = string.valueOf(workRecord[0].Total_Days__c);
        tier = workRecord[0].Quote__r.Tier__c;
        services = workRecord[0].Quote__r.New_Services__c;
        description = workRecord[0].Description__c; 
        if(workRecord[0].Team_Lead_1_TL1__c != null && workRecord[0].Team_Lead_1_TL1__r.ContactId != null){
            Tech_associate_Name = workRecord[0].Team_Lead_1_TL1__r.Contact.Name;
            Tech_associate_Contact = workRecord[0].Team_Lead_1_TL1__r.Contact.MobilePhone;
        }
        if(workRecord[0].Team_Lead_2_TL2__c != null && workRecord[0].Team_Lead_2_TL2__r.ContactId != null){
            team_Lead_Name = workRecord[0].Team_Lead_2_TL2__r.Contact.Name;
            team_lead_Contact = workRecord[0].Team_Lead_2_TL2__r.Contact.MobilePhone;
        }
        if(workRecord[0].Opportunity__c != null && workRecord[0].Opportunity__r.Owner.ContactId != null){
            associate_Name = workRecord[0].Opportunity__r.Owner.Contact.Name;
            associate_Contact = workRecord[0].Opportunity__r.Owner.Contact.MobilePhone;
        }
        
        taskList = new List<Milestone1_Task__c >();
        DescribeSObjectResult describeResultTask = Milestone1_Task__c.getSObjectType().getDescribe();  
        List<String> fieldNamesTask = new List<String>( describeResultTask.fields.getMap().keySet() );
        String query2 = ' SELECT ' + String.join( fieldNamesTask, ',' ) + 
            ' FROM ' + describeResultTask.getName() + ' where Project_Milestone__c =' + '\'' + wId + '\'';
        
        taskList = Database.query(query2);
    }
    /*public Milestone1_Milestone__c getWork() {
        return work;
    }*/
}