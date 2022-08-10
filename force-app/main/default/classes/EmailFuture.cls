public class EmailFuture {
    
    @future  (callout=true)
    public static void sendEmail(Set<Id> eLogSet){
        Id userId =userinfo.getUserId(); //require a valid whoId for renderStoredEmailTemplate method. It will not be used 
        
        Email_Parameters__c epara = Email_Parameters__c.getOrgDefaults();
        List<System_Log__c> logsToInsert = new List<System_Log__c>();
        List<Email_Log__c> eList =[SELECT Email_Template__c, Account__c, Opportunity__c, Case__c, Lead__c, email__c,What_Id__c FROM Email_Log__c WHERE ID In : eLogSet];
        for(Email_Log__c e: eList){
            EmailHandler.responseWrapper rw = EmailHandler.sendEmail(e, epara,userId);
            e.response__c = rw.body ;
            e.response_status__c = rw.code;
            if(rw.code !='200'){
                System_Log__c SL = new System_Log__c();
                //SL.Lead__c = CRMLeadID;
                SL.API_Name__c  = 'Email API';
                SL.Response__c ='Status Code: '+ rw.code +' '+ rw.body;
                SL.Lead__c = e.Lead__c;
                SL.Opportunity__c = e.Opportunity__c;
                SL.Case__c = e.Case__c;
                SL.Account__c = e.Account__c;
                SL.Email_Log__c = e.Id;
                logsToInsert.add(SL);
            }
        }
        update eList;
        if(!logsToInsert.isEmpty()) insert logsToInsert;
    }
}