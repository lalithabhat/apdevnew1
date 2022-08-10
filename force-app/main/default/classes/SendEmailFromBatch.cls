public class SendEmailFromBatch {

    public static Email_Log__c sendMail(String emailId, String templateName, String whatId,Email_Parameters__c epara ,Id userId){
         Email_Log__c e = new Email_Log__c();
            e.email__c = emailId;
            e.Email_Template__c = templateName;
            e.What_Id__c = whatId;
            e.bypass_trigger__c = true;
            EmailHandler.responseWrapper rw = EmailHandler.sendEmail(e, epara, userId);
            e.response__c = rw.body ;
            e.response_status__c = rw.code;
        	return e;
    }
}