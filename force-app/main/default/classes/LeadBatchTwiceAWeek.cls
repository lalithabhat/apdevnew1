//6 Twice a week for 2 months till the lead is in 'Call Later' stage
//8 Inactive customer (have had 1-2 conversations but not converted) - Twice a week for 2 months till the lead is in 'Did not pick up' stage
//BHS 7 Twice a week for 2 months till the lead is in 'Call Later' stage
//BHS 9 Inactive customer (have had 1-2 conversations but not converted) - Twice a week for 2 months till the lead is in 'Did not pick up' stage
global class LeadBatchTwiceAWeek implements Database.Batchable<sObject>,Database.AllowsCallouts{
    Email_Parameters__c epara;
    Id userId;
    public LeadBatchTwiceAWeek(){
        this.userId =userinfo.getUserId(); 
        this.epara = Email_Parameters__c.getOrgDefaults();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date backDate = Date.today() -60;
         String backDateString = String.valueof(backDate.year()) +'-';
          if(backDate.month() >9)  backDateString +=  String.valueof(backDate.month())+'-';
              else backDateString += '0'+  String.valueof(backDate.month()) +'-';
        if(backDate.day() >9)  backDateString +=  String.valueof(backDate.day());
              else backDateString += '0'+  String.valueof(backDate.day());
        String query = 'SELECT RecordType.DeveloperName, Email, MobilePhone, Call_Later__c, Inactive_Customer__c,Call_Later_marked_on__c,Inactive_Customer_Marked_On__c  FROM Lead WHERE (Call_Later__c =true OR Inactive_Customer__c = true) AND (Call_Later_marked_on__c > '+ backDateString +' OR Inactive_Customer_Marked_On__c  > ' +backDateString + ')';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        
        List<Email_Log__c> eList = new List<Email_Log__c>(); 
        for(Lead l : leadList){
            if(l.RecordType.DeveloperName =='SPS'){
                if(l.Call_Later__c){
                Email_log__c e = SendEmailFromBatch.sendMail(l.Email, 'SPS_testimonial_1', l.Id, this.epara, this.userId);
                eList.add(e);
                }
                else{
                Email_log__c e = SendEmailFromBatch.sendMail(l.Email, 'SPS_FAB_USP', l.Id, this.epara, this.userId);
                eList.add(e);
                }
            }
            else if(l.RecordType.DeveloperName =='BHS'){
                if(l.Call_Later__c){
                Email_log__c e = SendEmailFromBatch.sendMail(l.Email, 'BHS_insp_2', l.Id, this.epara, this.userId);
                eList.add(e);
                }
                else{
                Email_log__c e = SendEmailFromBatch.sendMail(l.Email, 'BHS_FAB_USP_mailer_2', l.Id, this.epara, this.userId);
                eList.add(e);
                }
            }
            
        }
        insert eList;
    }
    
    // Database.SaveResult[] srList = Database.update(lea , false);
    
    
    
    
    
    
    
    
    
    global void finish(Database.BatchableContext BC) {
    }
    
}