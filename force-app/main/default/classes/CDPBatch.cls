global class CDPBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Lead_Score__c,Mobile_Number__c, Mobile__c, Lead_score_text__c FROM CDP_Customer_Data__c';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<CDP_Customer_Data__c> cdpList) {
        Map<String,Decimal> scoremap = new Map<String,Decimal>();
        Map<String, String> scoremap1 = new Map<String,String>();
        for(CDP_Customer_Data__c cdp : cdpList){
            scoremap.put(cdp.Mobile__c, cdp.Lead_Score__c);
            scoremap1.put(cdp.Mobile__c, cdp.Lead_Score_Text__c);
        }
        List<Lead> leadList = new List<Lead>();
        for(Lead l: [Select Id, MobilePhone from Lead WHERE MobilePhone IN: scoreMap.keySet()]){
            
            if((scoreMap.get(l.MobilePhone) !=null) && (scoreMap1.get(l.MobilePhone) !=null)){
                Lead ln = new Lead(Id = l.Id, CDP_Score__c = scoreMap.get(l.MobilePhone), Lead_Score_Text__c = scoremap1.get(l.MobilePhone));
                leadList.add(ln);
            }
        }
        List<Account> accList = new List<Account>();
        for(Account a: [Select Id, PersonMobilePhone from Account WHERE PersonMobilePhone IN: scoreMap.keySet() AND recordtype.developerName ='PersonAccount']){
            if(scoreMap.get(a.personMobilePhone) !=null){
                Account an = new Account(Id = a.Id, CDP_Score__c = scoreMap.get(a.PersonMobilePhone));
                accList.add(an);
            }
        }
        
        Database.update(leadList , false);
        Database.update(accList , false);
        
        
        
        
    }
    
    
    
    
    global void finish(Database.BatchableContext BC) {
    }
}