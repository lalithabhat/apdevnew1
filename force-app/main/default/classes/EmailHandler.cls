public class EmailHandler {
    public class responseWrapper{
        public string code {get;set;}
        public string body {get;set;}
    }
    public static responseWrapper sendEmail(Email_Log__c emailLog,Email_Parameters__c epara,  Id userid){
        responseWrapper response = new responseWrapper();
        response.code = '';
        response.body = '';
        try{
            List<EmailTemplate> et = [Select Id, DeveloperName from EmailTemplate where DeveloperName =: emailLog.Email_Template__c];
            
            if(et.size()>0 && emailLog.email__c !=null && emailLog.What_Id__c !=null && !String.isBlank(emailLog.What_Id__c)){
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(et[0].Id, userId, emailLog.What_Id__c);
                List<Attachment> attList =[SELECT Name, Body From Attachment where parentId = :et[0].Id];
                
                JSONGenerator body = JSON.createGenerator(true);
                body.writeStartObject(); 
                body.writeStringField('version',epara.API_version__c );
                body.writeStringField('userName', epara.userName__c);
                body.writeStringField('password', epara.password__c);
                body.writeFieldName('message');
                body.writeStartObject();   
                body.writeStringField('fromEmail', epara.fromEmail__c);
                body.writeStringField('fromName',epara.fromName__c);
                body.writeStringField('replyTo', epara.replyTo__c);
                body.writeStringField('subject', email.getSubject());
                body.writeStringField('recipient', emailLog.email__c);
                body.writeStringField('html', email.getHtmlBody());
                body.writeStringField('text',email.getPlainTextBody());
                if(attList.size()>0){
                    body.writeFieldName('attachments');
                    body.writeStartArray();
                    for(Attachment a: attList){
                        
                        body.writeStartObject(); 
                        body.writeStringField('name', a.name);
                        body.writeStringField('attachmentData', EncodingUtil.base64Encode(a.body));
                        body.writeEndObject();
                    }
                    body.writeEndArray();
                }
                body.writeEndObject(); 
                body.writeEndObject();
                
                String jsonString = body.getAsString(); 
                HttpRequest req = new HttpRequest();
                req.setEndpoint (epara.Endpoint__c);
                req.setMethod ('POST');
                req.setBody(jsonString);
                req.setHeader('Content-Type', 'application/json');
                Http http = new Http();
                
                HTTPResponse res = http.send(req);
                system.debug(res.getBody());
                response.code = String.valueof(res.getStatusCode());
                response.body = res.getBody();
            }
            else{
                response.code = '0';
                response.body = 'Email or What Id not provided';
            }
        }
        catch(exception e){
            system.debug(e);
            response.code = '0';
            response.body = e.getMessage() + '\n' +e.getLineNumber();
           
        }
        system.debug('response'+ response);
        return response;
    }
}