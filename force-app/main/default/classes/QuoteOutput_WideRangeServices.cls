public class QuoteOutput_WideRangeServices {
    public string qId{get;set;}
    public List<Quote> qRecord{get;set;}
    public string dealerName{get;set;}
    public string dealerAddress{get;set;}
    public string dealerMobile{get;set;}
    public string dealerPhone{get;set;}
    public string customerName{get;set;}
    public string tier{get;set;}
    public string quoteNumber{get;set;}
    public string quoteDate{get;set;}
    public list<QuoteLineItem> QuoteLineItems{get;set;}
    public List<Payment_Milestone__c > pmList {get;set;}
    public string CA_Name{get;set;}
    public string CA_Mobile{get;set;}
    Public string total_Quote_Line_Item_Amount {get;set;}
    Public string newServices {get;set;}
    Public string expirationDate {get;set;}
    Public string maskingKitChrge {get;set;}
    Public string mechanisedCharge {get;set;}
    public Map<string,list<QuoteLineItem>> lineItemsMap{get;set;}
    
    public QuoteOutput_WideRangeServices(){
        qId = ApexPages.currentPage().getParameters().get('id');
        qRecord = new List<Quote>();
        dealerAddress = '';
        total_Quote_Line_Item_Amount = '0';
        maskingKitChrge = '0';
        mechanisedCharge = '0';
        lineItemsMap = new Map<string,list<QuoteLineItem>>();
        
        DescribeSObjectResult describeResultQuote = Quote.getSObjectType().getDescribe();  
        List<String> fieldNamesQuote = new List<String>( describeResultQuote.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNamesQuote, ',' ) + ',Dealer__r.Name, Account.Name,' +
            ' Dealer__r.BillingAddress, Dealer__r.PersonMobilePhone,Dealer__r.Phone, ' +
            ' Dealer__r.BillingStreet,Dealer__r.BillingCity,Dealer__r.BillingState, ' +
            ' Dealer__r.BillingCountry,Dealer__r.BillingPostalCode,opportunity.OwnerId ' +
            ' FROM ' + describeResultQuote.getName() + ' where Id =' + '\'' + qId + '\'';
        
        qRecord = Database.query(query);
        dealerName = qRecord[0].Dealer__r.Name;
        dealerAddress = '';
        if(qRecord[0].Dealer__r.BillingStreet != null){
            dealerAddress = qRecord[0].Dealer__r.BillingStreet + ', ';
        }
        if(qRecord[0].Dealer__r.BillingCity != null){
            dealerAddress = dealerAddress + qRecord[0].Dealer__r.BillingCity + ', ';
        }
        if(qRecord[0].Dealer__r.BillingState != null){
            dealerAddress = dealerAddress + qRecord[0].Dealer__r.BillingState + ', ';
        }
        if(qRecord[0].Dealer__r.BillingCountry != null){
            dealerAddress = dealerAddress + qRecord[0].Dealer__r.BillingCountry + ', ';
        }
        if(qRecord[0].Dealer__r.BillingPostalCode != null){
            dealerAddress = dealerAddress + qRecord[0].Dealer__r.BillingPostalCode;
        }
        
        dealerMobile = qRecord[0].Dealer__r.PersonMobilePhone;
        dealerPhone = qRecord[0].Dealer__r.Phone;
        customerName = qRecord[0].Account.Name;
        tier = qRecord[0].Tier__c;
        quoteNumber = qRecord[0].QuoteNumber;
        quoteDate = qRecord[0].createdDate.Date().format();
        
        List<User> userList = [select id,ContactId,Contact.Name,Contact.MobilePhone from User 
                               where Id =: qRecord[0].opportunity.OwnerId];
        if(userList != null && !userList.isEmpty()){
            CA_Name = userList[0].Contact.Name;
            CA_Mobile = userList[0].Contact.MobilePhone;
        }
        newServices = qRecord[0].New_Services__c;
        if(qRecord[0].ExpirationDate != null)
        	expirationDate = qRecord[0].ExpirationDate.format();
        total_Quote_Line_Item_Amount = string.valueOf(qRecord[0].Total_Amount_after_discount__c);
       /* for(Integer i=1;i<=5;i++){
            if(string.isNotBlank((string)qRecord[0].get('Discount_Name_'+ i + '__c'))){
                
            }
        }*/
        
        QuoteLineItems = new list<QuoteLineItem>();
        DescribeSObjectResult describeResultQuoteLineItem = QuoteLineItem.getSObjectType().getDescribe();  
        List<String> fieldNamesQuoteLineItem = new List<String>( describeResultQuoteLineItem.fields.getMap().keySet() );
        String query1 = ' SELECT ' + String.join( fieldNamesQuoteLineItem, ',' ) + ',Product2.Name ' + 
            ' FROM ' + describeResultQuoteLineItem.getName() + ' where QuoteId =' + '\'' + qId + '\' ' +
            ' AND Masking_Charge__c = false AND Mechanised_Charge__c = false';
        
        QuoteLineItems = Database.query(query1);
        Decimal total = 0; 
        
        
        for(QuoteLineItem ql : QuoteLineItems){
            total += ql.Total_Price_New__c;
            if(lineItemsMap.containsKey(ql.Room__c)){
                List<QuoteLineItem> existingList = lineItemsMap.get(ql.Room__c);
                existingList.add(ql);
                lineItemsMap.put(ql.Room__c,existingList);
            }else{
                List<QuoteLineItem> existingList = new List<QuoteLineItem>();
                existingList.add(ql);
                lineItemsMap.put(ql.Room__c,existingList);
            }
        }
        //total_Quote_Line_Item_Amount = string.valueOf(total);
        pmList = new List<Payment_Milestone__c >();
        pmList = [select id,name,Stage__c,Milestone_Percentage__c,Amount__c 
                                              from Payment_Milestone__c where Quote__c =:qId];
        
        List<QuoteLineItem> masking_Mechanised_charge = [select id,subTotal,Total_Discount__c,Total_Price_New__c,
                                                         Masking_Charge__c,Mechanised_Charge__c
                                                        from QuoteLineItem where QuoteId =: qId and 
                                                        (Masking_Charge__c = true OR Mechanised_Charge__c = true)];
        if(masking_Mechanised_charge != null && !masking_Mechanised_charge.isEmpty()){
            for(QuoteLineItem qq : masking_Mechanised_charge){
                if(qq.Masking_Charge__c){
                    maskingKitChrge = string.valueOf(qq.subTotal);
                }
                if(qq.Mechanised_Charge__c){
                    mechanisedCharge = string.valueOf(qq.subTotal);
                }
        	}
        }
    }

}