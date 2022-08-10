global class EmailBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    Set<Id> emailSet = new Set<Id>();
   Email_Parameters__c epara;
    Id userId;
    public EmailBatch( Set<Id> eLogSet ){
    	this.userId =userinfo.getUserId(); //require a valid whoId for renderStoredEmailTemplate method. It will not be used 
        this.emailSet = eLogSet;
       
        
        this.epara = Email_Parameters__c.getOrgDefaults();
   
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
       // String query = 'SELECT ID, ProfileID FROM User WHERE ISActive = True';
        String query = 'SELECT Email_Template__c, Account__c, Opportunity__c, Case__c, Lead__c, email__c,What_Id__c FROM Email_Log__c WHERE ID In :';
        query += 'emailSet';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Email_Log__c> eList) {
        for(Email_Log__c e: eList){
           EmailHandler.responseWrapper rw = EmailHandler.sendEmail(e, this.epara, this.userId);
           e.response__c = rw.body ;
           e.response_status__c = rw.code;
        }
        update eList;
    }
    global void finish(Database.BatchableContext BC) {
    }
}