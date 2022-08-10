trigger WorkTrg on Milestone1_Milestone__c (after insert, after update, after delete, after undelete) {
	map<Id,List<Milestone1_Milestone__c>> quoteWorkMap = new map<Id,List<Milestone1_Milestone__c>>();
    Set<Id> quoteIds = new set<Id>();
    if((trigger.isAfter && trigger.isInsert) || (trigger.isAfter && trigger.isUndelete) ||
      (trigger.isAfter && trigger.isUpdate)){
        for(Milestone1_Milestone__c m : trigger.new){
            system.debug('m.Quote__c::'+m.Quote__c);
            if(m.Quote__c != null){
                quoteIds.add(m.Quote__c);
            }
        }
          system.debug('quoteIds::'+quoteIds);
        if(!quoteIds.isEmpty()){
            List<Milestone1_Milestone__c> workList = [select id,name,Money_Collected__c,Quote__c from Milestone1_Milestone__c
                                                       where Quote__c IN: quoteIds];
            system.debug('workList::'+workList.size());
            for(Milestone1_Milestone__c m : workList){
                if(quoteWorkMap.containsKey(m.Quote__c)){
                    List<Milestone1_Milestone__c> dummyList = new List<Milestone1_Milestone__c>();
                    dummyList = quoteWorkMap.get(m.Quote__c);
                    dummyList.add(m);
                    quoteWorkMap.put(m.Quote__c, dummyList);
                }else{
                    List<Milestone1_Milestone__c> dummyList = new List<Milestone1_Milestone__c>();
                    dummyList.add(m);
                    quoteWorkMap.put(m.Quote__c, dummyList);
                }
            }
            List<Quote> quoteListToUpdate = new List<Quote>();
            system.debug('quoteWorkMap::'+quoteWorkMap);
            for(Id key : quoteWorkMap.keySet()){
                decimal moneyReceived = 0;
                for(Milestone1_Milestone__c m : quoteWorkMap.get(key)){
                    if(m.Money_Collected__c != null){
                        moneyReceived += m.Money_Collected__c; 
                    }else{
                        moneyReceived += 0;
                    }
                }
                system.debug('moneyReceived::'+moneyReceived);
                Quote q = new Quote();
                q.Id = key;
                q.Total_Money_Received__c = moneyReceived;
                quoteListToUpdate.add(q);
            }
            system.debug('quoteListToUpdate::'+quoteListToUpdate);
            if(!quoteListToUpdate.isEmpty()){
                update quoteListToUpdate;
            }
        }  
      }else if(trigger.isAfter && trigger.isDelete){
        for(Milestone1_Milestone__c m : trigger.Old){
            if(m.Quote__c != null){
                if(quoteWorkMap.containsKey(m.Quote__c)){
                    List<Milestone1_Milestone__c> dummyList = new List<Milestone1_Milestone__c>();
                    dummyList = quoteWorkMap.get(m.Quote__c);
                    dummyList.add(m);
                    quoteWorkMap.put(m.Quote__c, dummyList);
                }else{
                    List<Milestone1_Milestone__c> dummyList = new List<Milestone1_Milestone__c>();
                    dummyList.add(m);
                    quoteWorkMap.put(m.Quote__c, dummyList);
                }
            }
        }  
          if(!quoteWorkMap.isEmpty()){
              Map<Id,Quote> quoteMap = new Map<Id,Quote>();
              for(Quote q : [select id,name,Total_Money_Received__c from Quote where Id IN: quoteWorkMap.keyset()]){
                  quoteMap.put(q.Id,q);
              }
              List<Quote> quoteListToUpdate = new List<Quote>();
              for(Id key : quoteWorkMap.keySet()){
                  decimal moneyReceived = 0;
                    for(Milestone1_Milestone__c m : quoteWorkMap.get(key)){
                        if(m.Money_Collected__c != null){
                        	moneyReceived += m.Money_Collected__c; 
                        }else{
                            moneyReceived += 0;
                        }
                    }
                  if(quoteMap.containskey(key)){
                      Quote q = new Quote();
                      q = quoteMap.get(key);
                      q.Total_Money_Received__c = q.Total_Money_Received__c - moneyReceived;
                      quoteListToUpdate.add(q);
                  }
                    
              }
              if(!quoteListToUpdate.isEmpty()){
                  update quoteListToUpdate;
              }
          }  
      }    
          
    
}