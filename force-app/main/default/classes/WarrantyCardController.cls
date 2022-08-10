public class WarrantyCardController {
    public Milestone1_Project__c site {get;set;}
     public String dateOfWarranty {get;set;}
    public String validTill {get;set;}
    
    public WarrantyCardController(){
         Id siteId = ApexPages.currentPage().getParameters().get('id');
      //  siteId = 'a0E72000000T7qwEAC';
         site = [Select Name,Warranty_No__c, Account__r.Name,Account__r.PersonContact.Email,Account__r.PersonContact.MobilePhone,
                 Dealer__r.Name, Dealer__r.Phone,  Dealer__r.BillingStreet,Dealer__r.BillingCity ,Dealer__r.BillingState ,
               Dealer__r.BillingPostalCode,Dealer__r.BillingCountry,
                 Associate_Contact_No__c,Address__c  from Milestone1_Project__c where id =: siteId];
        dateOfWarranty = String.valueof(Date.today().day()).leftPad(2,'0') +'/'+String.valueof(Date.today().month()).leftPad(2,'0')+'/'+Date.today().year();
        Date oneYear = Date.today() +364;
        validTill = String.valueof(oneYear.day()).leftPad(2,'0') +'/'+String.valueof(oneYear.month()).leftPad(2,'0')+'/'+oneYear.year();
       
       
    }
}