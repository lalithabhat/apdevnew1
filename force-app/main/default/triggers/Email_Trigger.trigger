trigger Email_Trigger on Email_Log__c (after insert) {
    Set<Id> emailLogIds = new Set<Id>();
    for(Email_Log__c e: trigger.new){
      if(!e.Bypass_Trigger__c)  emailLogIds.add(e.Id);
    }
    if(!emailLogIds.isEmpty()){
        emailFuture.sendEmail(emailLogIds);
   //	EmailBatch myBatchObject = new EmailBatch(emailLogIds); 
   // Database.executeBatch(myBatchObject,100);
    }
}