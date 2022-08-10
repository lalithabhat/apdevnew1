public class SanAssureController {
    public String cDate {get;set;}
    public String products {get;set;}
    public Milestone1_Project__c site {get;set;}
    public SanAssureController(){
        Id siteId = ApexPages.currentPage().getParameters().get('id');
        //siteId = 'a0E72000000T7qwEAC';
        products = '';
        site = [Select Id,Account__r.Name, Dealer__r.Name  from Milestone1_Project__c where id =: siteId];
        cDate = String.valueof(Date.today().day()).leftPad(2,'0') +'-'+
            String.valueof(Date.today().month()).leftPad(2,'0')+'-'+
            Date.today().year();
        
        for(Consumption__c p :  [Select Product__r.Name, Product__r.Tier_Available__c from Consumption__c where Work__r.Project__c =: siteId ]){
            if(p.Product__r.Tier_Available__c !=null && p.Product__r.Tier_Available__c.contains('San Assure')) products += p.Product__r.Name +', ';
        }
       
        products = products.removeEnd(', ');
     
       
    }
}