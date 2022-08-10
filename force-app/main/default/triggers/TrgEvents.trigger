trigger TrgEvents on Events__c (after update) {
	Set<Id> Ids = new Set<Id>();
    
    for(Events__c e : trigger.new){
        Ids.add(e.Id);
    }
    Map<Id,List<Event>> eventMap = new Map<Id, List<Event>>();
    for(Event e : [select id,ownerId,whoId,StartDateTime,EndDateTime,Subject,whatId from Event where 
                   whatId IN:Ids and EndDateTime >=TODAY]){
                       if(eventMap.containsKey(e.whatId)){
                           List<event> dummyList = new List<Event>();
                           dummyList = eventMap.get(e.whatId);
                           dummyList.add(e);
                           eventMap.put(e.whatId, dummyList);
                       }else{
                           List<event> dummyList = new List<Event>();
                           dummyList.add(e);
                           eventMap.put(e.whatId, dummyList);
                       }                
    }
    List<Event> eventListForUpdate = new List<Event>();
    if(!eventMap.isEmpty()){
        for(Events__c e : trigger.new){
            if(eventMap.containsKey(e.Id)){
                for(event eOBJ : eventMap.get(e.Id)){
                    eOBJ.StartDateTime = e.Start_Date_Time__c;
                    eOBJ.EndDateTime = e.End_Date_Time__c;
                    eOBJ.subject = e.Reason__c;
                    eventListForUpdate.add(eOBJ);
                }
            }
        }
    }
    if(!eventListForUpdate.isEmpty()){
        update eventListForUpdate;
    }
    
    
}