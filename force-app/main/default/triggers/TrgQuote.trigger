trigger TrgQuote on Quote (after update) {
    //Id accountId;
    //string pincode;
    string qId;
    if(trigger.new.size() == 1){
        Quote qRecord = new Quote();
        Quote qRecordNew = new Quote();
        for(Quote q : trigger.new){
            if(trigger.oldMap.get(q.Id).Site__c != trigger.newMap.get(q.Id).Site__c && q.Site__c != null){
                qRecord = q;
            }
            if(trigger.oldMap.get(q.Id).Contractor__c != trigger.newMap.get(q.Id).Contractor__c && 
               q.Contractor__c != null){
                qRecordNew = q;
            }
        }
        
        if(qRecord != null && qRecord.Id != null){
            Opportunity op = new Opportunity();
            op.Id = qRecord.OpportunityId;
            op.Site__c = qRecord.site__c;
            update op;
            
            if(qRecord.Site_Health_Card__c != null){
                Site_Health_Card__c shc = new Site_Health_Card__c();
                shc.Id = qRecord.Site_Health_Card__c;
                shc.Site__c = qRecord.site__c;
                update shc;
            }
        }    
            
                
        
        if(qRecordNew != null && qRecordNew.Id != null){
            system.debug('qRecordNew::'+qRecordNew);
            Milestone1_Project__c site = new Milestone1_Project__c();
            site.Id = qRecordNew.Site__c;
            site.Dealer__c = qRecordNew.Dealer__c;
            site.Contractor__c = qRecordNew.Contractor__c;
            site.Tier__c = qRecordNew.Tier__c;
            site.OwnerId = qRecordNew.OwnerId;
            update site;
        }
    }
    
}