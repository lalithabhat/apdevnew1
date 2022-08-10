public class YM_Lead_API {
    
    @future(callout = true)
    Public Static void call_YM_LeadAPI(set<Id> leadIds){
        List<System_Log__c> logsToInsert = new List<System_Log__c>();
        system.debug('inside YM API');
        //Lead lead = ScheduleAppointmentServices.getLead(leadId);
        List<Lead> lList = [select id,name,Service_By__c,SA_Name__c,Multiple_SA__c,CA_Name__c,SA_Declined__c,Skills__c,
                            Declined_Reason__c,Pincode__c,CA_Name__r.Name,recordtypeId,OwnerId,Reason_For_SA_Declined__c, 
                            recordtype.name,status, Last_Appointment_End_Date_Time__c,Street,City,State,Country,PostalCode,
                            Last_Appointment_Start_Date_Time__c,Service_Territory__c,mobilePhone,Bot_Journey__c,
                            Service_Territory__r.Business_Hour_End__c, Service_Territory__r.Business_Hour_start__c,
                            YM_Campaign_Code__c,BP_No__c,Email 
                            from lead where id IN:leadIds and isConverted = false];
        
        List<Lead> leadListToUpdate = new List<Lead>();
        if(lList != null && !lList.isEmpty()){
            for(Lead lead : lList){
                String endPointURL = ''; //custom setting for endPointURL
                String whatsAppBotId = ''; //custom setting for whatsAppBotId
                try{
                    if(API_Integration__c.getValues('YM Push Lead API') != null) {
                        endPointURL = API_Integration__c.getValues('YM Push Lead API').URL__c;
                        whatsAppBotId = API_Integration__c.getValues('YM Push Lead API').App_Version__c;
                    }
                    
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    if(lead.MobilePhone != null){
                        gen.writeStringField('from', '91' + lead.MobilePhone);
                    }else{
                        gen.writeStringField('from', '');
                    }
                    gen.writeStringField('to', whatsAppBotId);
                    gen.writeStringField('source', 'whatsapp');
                    
                    gen.writeFieldName('data');
                    gen.writeStartObject();
                    gen.writeFieldName('event');
                    gen.writeStartObject();
                    gen.writeStringField('code','WELCOME_MESSAGE');
                    //gen.writeStartObject();
                    gen.writeFieldName('data');
                    gen.writeStartObject();
                    gen.writeStringField('countryCode', '');
                    if(lead.MobilePhone != null){
                        gen.writeStringField('mobile', '91' + lead.MobilePhone);
                    }else{
                        gen.writeStringField('mobile', '');
                    }
                    if(lead.Name != null){
                        gen.writeStringField('name', lead.Name);
                    }else{
                        gen.writeStringField('name', '');
                    }
                    if(lead.Pincode__c != null){
                        gen.writeStringField('pincode', lead.Pincode__c);
                    }else{
                        gen.writeStringField('pincode', '');
                    }
                    if(lead.YM_Campaign_Code__c  != null){
                        gen.writeStringField('campaignId', lead.YM_Campaign_Code__c);
                    }else{
                        gen.writeStringField('campaignId', '');
                    }
                    if(lead.BP_No__c != null){
                        gen.writeStringField('bpNumber', lead.BP_No__c);
                    }else{
                        gen.writeStringField('bpNumber', '');
                    }
                    gen.writeStringField('zconId', lead.Id);
                    if(lead.Email != null){
                        gen.writeStringField('email', lead.Email);
                    }else{
                        gen.writeStringField('email', '');
                    }
                    gen.writeStringField('Soa', 'YWL');
                    
                    gen.writeEndObject();
                    //gen.writeEndObject();
                    gen.writeEndObject();
                    gen.writeEndObject();
                    gen.writeEndObject();
                    String body = gen.getAsString();
                    system.debug('body:: ' + body);
                    
                    Http http = new Http();
                    Httprequest request = new HttpRequest();                      
                    request.setMethod('POST');
                    request.setEndpoint(endPointURL);         
                    request.setTimeout(120000);
                    request.setHeader('Content-Type', 'application/json');
                    request.setBody(body);  
                    //if(!Test.isRunningTest()) {
                    //Making call to external REST API
                    HttpResponse response = http.send(request);
                    system.debug('Response: '+response.getBody());
                    if(response.getStatusCode() == 200){
                        system.debug('success::');
                        lead.Bot_Journey__c = 'Initiated';
                        leadListToUpdate.add(lead);
                    }
                    else{
                        System_Log__c SL = new System_Log__c();
                        SL.API_Name__c  = 'YM Lead API';
                        SL.Response__c ='Status Code: '+ response.getStatusCode() +' '+ response.getBody();
                        SL.Lead__c = lead.Id;
                        logsToInsert.add(SL);
                    }
                }  catch(exception e){
                    System_Log__c SL = new System_Log__c();
                    SL.API_Name__c  = 'YM Lead API';
                    SL.Response__c =e.getMessage() + '\n' +e.getLineNumber();
                    SL.Lead__c = lead.Id;
                    logsToInsert.add(SL);
                    
                    
                }
            }
            
            if(!leadListToUpdate.isEmpty()){
                update leadListToUpdate;
            }
        }
        if(!logsToInsert.isEmpty()) insert logsToInsert;
    }
}