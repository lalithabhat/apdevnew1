public class QuoteDetails_OnSiteClose {
    
    @AuraEnabled(cacheable=true)
    public static List<QuoteDetails> getQuoteRecords(string siteId){
        List<QuoteDetails> resultList = new List<QuoteDetails>();
        try {
            List<Quote> qList = [select Id,name,Dealer__c,OpportunityId,AccountId,
                                 Account.Name, Tier__c,New_Services__c,Site__c,QuoteNumber,
                                 Subtotal,Total_Amount_after_discount__c,Total_Money_Received__c,
                                 Balance_Amount__c,
                                 (select id,Product2Id,Room__c,Surface__c,Quantity__c,Product2.Name,
                                  Consumed_Quantity__c,Balance_Quantity__c,Product2.Tier_Available__c
                                  from QuoteLineItems) 
                                 from Quote where Site__c =:siteId and Status = 'Accepted'];
            system.debug('qList::'+qList);
            for(Quote q : qList){
                Map<Id,QuoteLineItemWrapper> wrapperMap = new Map<Id,QuoteLineItemWrapper>();
                QuoteDetails qWrap = new QuoteDetails();
                qWrap.quoteName = q.Name;
                qWrap.quoteNumber = q.QuoteNumber;
                qWrap.quoteAmount = q.Total_Amount_after_discount__c;
                qWrap.receivedAmount = q.Total_Money_Received__c;
                qWrap.balanceAmount = q.Balance_Amount__c;
                qWrap.newServices = q.New_Services__c;
                qWrap.tier = q.Tier__c;
                for(QuoteLineItem ql : q.QuoteLineItems){
                    if(wrapperMap.containsKey(ql.Product2Id)){
                        QuoteLineItemWrapper qw = wrapperMap.get(ql.Product2Id);
                        if(ql.Quantity__c == null){ql.Quantity__c = 0;}
                        qw.quantity += ql.Quantity__c;
                        if(ql.Consumed_Quantity__c == null){ql.Consumed_Quantity__c = 0;}
                        qw.consumedQuantity += ql.Consumed_Quantity__c;
                        qw.balanceQuantity += ql.Balance_Quantity__c;
                        if(ql.Product2.Tier_Available__c != null && ql.Product2.Tier_Available__c.Contains(q.Tier__c)){
                            qw.mandatoryProduct = 'YES';
                        }else{
                            qw.mandatoryProduct = 'NO';
                        }
                        wrapperMap.put(ql.Product2Id,qw);
                    }else{
                        QuoteLineItemWrapper qw = new QuoteLineItemWrapper();
                        if(ql.Quantity__c == null){ql.Quantity__c = 0;}
                        qw.quantity = ql.Quantity__c;
                        if(ql.Consumed_Quantity__c == null){ql.Consumed_Quantity__c = 0;}
                        qw.consumedQuantity = ql.Consumed_Quantity__c;
                        qw.balanceQuantity = ql.Balance_Quantity__c;
                        qw.productName = ql.Product2.Name;
                        qw.productId = ql.Product2Id;
                        if(ql.Product2.Tier_Available__c != null && ql.Product2.Tier_Available__c.Contains(q.Tier__c)){
                            qw.mandatoryProduct = 'YES';
                        }else{
                            qw.mandatoryProduct = 'NO';
                        }
                        wrapperMap.put(ql.Product2Id,qw);
                    }
                }
                List<QuoteLineItemWrapper> wrapperList = new List<QuoteLineItemWrapper>();
                for(Id key : wrapperMap.keyset()){
                    wrapperList.add(wrapperMap.get(key));
                }
                qWrap.quoteItems.addAll(wrapperList);
                resultList.add(qWrap);
            }
            
            return resultList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
    
    public class QuoteDetails{
        @AuraEnabled Public string quoteName;
        @AuraEnabled Public string quoteNumber;
        @AuraEnabled Public Decimal quoteAmount;
        @AuraEnabled Public Decimal receivedAmount;
        @AuraEnabled Public Decimal balanceAmount;
        @AuraEnabled Public string tier;
        @AuraEnabled Public string newServices;
        @AuraEnabled Public List<QuoteLineItemWrapper> quoteItems;
        
        public QuoteDetails(){
            quoteItems = new List<QuoteLineItemWrapper>();
        }
    }
    public class QuoteLineItemWrapper{
        @AuraEnabled Public string productId;
        @AuraEnabled Public string productName;
        @AuraEnabled Public Decimal quantity;
        @AuraEnabled Public Decimal consumedQuantity;
        @AuraEnabled Public Decimal balanceQuantity;
        @AuraEnabled Public String mandatoryProduct;
    }
}