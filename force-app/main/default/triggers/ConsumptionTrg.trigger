trigger ConsumptionTrg on Consumption__c (after insert, after update, after delete, after undelete) {
	set<Id> consumptionIds = new set<Id>();
    set<Id> productIds = new set<Id>();
    if((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUndelete) ||
       (trigger.isAfter && trigger.isUpdate)){
        if(trigger.new.size() == 1){
            for(Consumption__c c : trigger.new){
                if(c.Product__c != null){
                    consumptionIds.add(c.Id);
                    productIds.add(c.Product__c);
                }
            }
          if(!consumptionIds.isEmpty()){
            List<Consumption__c> consumptionList = [select id,name,Work__c,Work__r.Quote__c,Quantity__c from Consumption__c where 
                                                   Id IN:consumptionIds];
            Id quoteId;
            if(consumptionList[0].Work__r.Quote__c != null){
                quoteId = consumptionList[0].Work__r.Quote__c;                  
            }
            if(quoteId != null){
                List<Consumption__c> otherConsumptionList = [select id,name,Work__c,Work__r.Quote__c,Quantity__c,Product__c from Consumption__c where 
                                                   Work__c != null and Work__r.Quote__c != null and Work__r.Quote__c =: quoteId and product__c IN: productIds];
                Map<Id, List<Consumption__c>> consumptionProductMap = new Map<Id, List<Consumption__c>>();
                for(Consumption__c c : otherConsumptionList){
                    if(consumptionProductMap.containsKey(c.Product__c)){
                        List<Consumption__c> dummyList = new List<Consumption__c>();
                        dummyList = consumptionProductMap.get(c.Product__c);
                        dummyList.add(c);
                        consumptionProductMap.put(c.Product__c,dummyList);
                    }else{
                        List<Consumption__c> dummyList = new List<Consumption__c>();
                        dummyList.add(c);
                        consumptionProductMap.put(c.Product__c,dummyList);
                    }
                }
                List<QuoteLineItem > quoteLineItems = [select id, Product2Id, QuoteId, Consumed_Quantity__c from QuoteLineItem where 
                                                      Product2Id IN: productIds and QuoteId =: quoteId];
                if(!quoteLineItems.isEmpty()){
                    for(QuoteLineItem ql : quoteLineItems){
                        
                        if(consumptionProductMap.containsKey(ql.Product2Id)){
                            decimal quantity = 0;
                            for(Consumption__c c : consumptionProductMap.get(ql.Product2Id)){
                                if(c.Quantity__c == null){
                                    c.Quantity__c = 0;
                                }
                                quantity += c.Quantity__c;
                            }
                            ql.Consumed_Quantity__c = quantity;
                        }
                         
                    }
                    update quoteLineItems;
                }
            }
            
          }
            
        }
   }else if(trigger.isAfter && trigger.isDelete){
       if(trigger.old.size() == 1){
           Id workId;
           decimal quantity = 0;
        for(Consumption__c c : trigger.Old){
            if(c.Product__c != null){
                    consumptionIds.add(c.Id);
                    productIds.add(c.Product__c);
                	workId = c.Work__c;
                    if(c.Quantity__C != null){
                        quantity = c.Quantity__C;
                    }
            }
        }
           //system.debug('consumptionIds::'+consumptionIds);
           //system.debug('productIds::'+productIds);
        if(workId != null){
            /*List<Consumption__c> consumptionList = [select id,name,Work__c,Work__r.Quote__c,Quantity__c from Consumption__c where 
                                                   Id IN:consumptionIds];*/
            List<Milestone1_Milestone__c> workList = [select id,name,Quote__C from Milestone1_Milestone__c where Id =: workId];
            //system.debug('workList::'+workList);
            Id quoteId = workList[0].Quote__c;
            List<QuoteLineItem > quoteLineItems = [select id, Product2Id, QuoteId, Consumed_Quantity__c from QuoteLineItem where 
                                                  Product2Id IN: productIds and QuoteId =: quoteId];
            for(QuoteLineItem ql : quoteLineItems){
               
                ql.Consumed_Quantity__c = ql.Consumed_Quantity__c - quantity;
            }
            if(!quoteLineItems.isEmpty()){
                update quoteLineItems;
            }
        }
      }
   }
    
}