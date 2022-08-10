public without sharing class MyTeam_View_Controller {
    
    @Auraenabled(cacheable =true)
    public static List<result> getMyTeam(){
        List<result> results = new List<result>();
        // Id currentCId = '00372000001m8hzAAA';// [Select ContactId from User where Id =: userInfo.getUserId()].ContactId;
        Id currentCId = [Select ContactId from User where Id =: userInfo.getUserId()].ContactId;
        Map<Id,SA_Pincode_Mapping__c> contactMap = new Map<Id,SA_Pincode_Mapping__c>();
        Map<Id,Id> contactUserMap = new Map<Id,Id>();
        Map<Id,Double> mtdMap = new Map<Id,Double>();
        Map<Id,Double> ytdMap = new Map<Id,Double>();
        for(SA_Pincode_Mapping__c s:  [Select Id,SA__c, SA__r.Name, SA__r.Persona__c,SA__r.PositionID__c, SA__r.Account.Name from SA_Pincode_Mapping__c WHERE (TL1__c =: currentCId OR TL2__c =:currentCId) /*AND SA__r.Active__c =true*/ ORDER BY SA__r.Name]){
            contactmap.put(s.SA__c, s);
        }
        system.debug('contactmap '+contactmap);
        for(User u : [Select Id,ContactId from User where ContactId IN :contactmap.keySet() AND ContactId !=null]){
            contactUsermap.put(u.contactId, u.Id);
        }
        system.debug('contactUsermap '+contactUsermap);
        system.debug([Select SUM(Money_Collected__c)total, Project__r.ownerId from Milestone1_Milestone__c WHERE Project__r.ownerId IN : contactUserMap.values() AND CreatedDate >= THIS_MONTH GROUP BY Project__r.ownerId ]);
        for(AggregateResult m : [Select SUM(Money_Collected__c)total, Project__r.ownerId from Milestone1_Milestone__c WHERE Project__r.ownerId IN : contactUserMap.values() AND CreatedDate >= THIS_MONTH GROUP BY Project__r.ownerId ]){
            if(m.get('total')!=null){
                mtdMap.put((Id)m.get('OwnerId'),(Double)m.get('total'));
            }    
        }
        for(AggregateResult m : [Select SUM(Money_Collected__c)total, Project__r.ownerId from Milestone1_Milestone__c WHERE Project__r.ownerId IN : contactUserMap.values() AND CreatedDate >= THIS_FISCAL_YEAR GROUP BY Project__r.ownerId]){
            if(m.get('total')!=null){
                ytdMap.put((Id)m.get('OwnerId'),(Double)m.get('total'));
            }
        }
        system.debug('mtdMap '+mtdMap + ' '+ ytdMap);
        for(SA_Pincode_Mapping__c s : contactMap.values()){
            result r = new result();
            r.contactId = s.SA__c;
            r.name = s.SA__r.Name;
            r.positionId = s.SA__r.PositionID__c;
            r.dealer =s.SA__r.Account.Name; 
            r.role = s.SA__r.Persona__c;
            if(contactUserMap.containsKey(s.SA__c)){
                Id userId =  contactUserMap.get(s.SA__c);
                if(mtdMap.containsKey(userId)) r.mtd = mtdMap.get(userId);
                if(ytdMap.containsKey(userId)) r.ytd = ytdMap.get(userId);
            }
            results.add(r);
        }
        return results;
    }
    
    public class result{
        @auraenabled public string contactId {get;set;}
        @auraEnabled public string name {get;set;}
        @auraEnabled public string positionId {get;set;}
        @auraEnabled public string dealer {get;set;}
        @auraEnabled public string role {get;set;}
        @auraEnabled public double mtd {get;set;}
        @auraEnabled public double ytd {get;set;}
        
        public result(){
            this.mtd = 0;
            this.ytd = 0;
            
        }
    }
    
}