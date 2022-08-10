public class convertProductSalesLead {

    
     public class ResponseWrapper {
        @AuraEnabled public Boolean success {get; set;}
        @AuraEnabled public String recId {get; set;}
        @AuraEnabled public String message {get; set;}
        @AuraEnabled public Boolean isError {get; set;}
    }
}