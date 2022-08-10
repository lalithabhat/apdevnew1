public without sharing class  QuoteApprovalController {
    public string pdf {get;set;}
    public boolean showSuccess {get;set;}
    public boolean showError {get;set;}
    public boolean alreadyApproved {get;set;}
    public boolean alreadyRejected {get;set;}
    public boolean showRejected {get;set;}
    public Quote q= new Quote();
    public QuoteApprovalController(){
        
        showSuccess = false;
        showRejected = false;
        showError =false;
        alreadyRejected = false;
        alreadyApproved = false;
        try{
            String quoteID = ApexPages.currentPage().getParameters().get('id');
            
            q= [SELECT ID,Age_Band__c, public_URL__c,Status,Approval_Date__c FROM QUOTE WHERE ID =: quoteId][0];
            pdf = q.Public_URL__c;
            if(q.Status =='Accepted'){//check if already approved
                alreadyApproved = true;
            }else if(q.Status =='Denied'){
                alreadyRejected = true;
            }
            
        }
        catch(exception e){
            showError = true;
        }         
    }
    public void approve(){
        try{
            
            q.Status = 'Accepted';
            q.Approval_Date__c = system.today();
            update q;
           	showSuccess = true;
            
        }
        catch(Exception e){
            showError = true;
        }
        
        
    }
    
    public void reject(){
        try{
            
            q.Status = 'Denied';
            update q;
            showRejected = true;
            
            
        }
        catch(Exception e){
            showError = true;
        }
        
        
    }
}