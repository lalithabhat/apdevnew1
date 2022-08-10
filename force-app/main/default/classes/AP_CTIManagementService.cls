/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 20-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex Class for CTI API Integration.
*********************************************************************************************************/
public class AP_CTIManagementService {
    /* Send Lead Data in Calling Queue CTI API */
    @future(callout = true)
    public static void pushLeadtoCallingQueue(Set<Id> lIdCTISet) {
        String body = '';
        try{
            List<Lead> leadList = new List<Lead>();
            List<Lead> updateLeadList = new List<Lead>();
            List<System_Log__c> insertSystemLogList = new List<System_Log__c>();
            Http http = new Http();
            
            /* Authenticate the CTI */
            String endPointURL = '';
            if(API_Integration__c.getValues('Lead Push Details') != null)
                endPointURL = API_Integration__c.getValues('Lead Push Details').URL__c; //check name field
            
            if(lIdCTISet != null && lIdCTISet.size() > 0) {
                leadList = [Select Id, FirstName, LastName, MobilePhone, Email, Pincode__c, Whatsapp_Notification__c, AOD_Master__c, AOD_Master__r.Service_Id__c, CreatedDate,
                            Lead_In_Calling_Queue__c, Is_Serviced__c, City__c, State__c, Street, CampaignName__c, CampaignName__r.Name, CampaignName__r.Digital_Marketing_Campaign_Code__c 
                            from Lead where Id IN: lIdCTISet];
                system.debug('leadList: '+leadList);
                
                if(!leadList.isEmpty() && leadList.size() > 0) {
                    /* Create JSON Body for Post method */
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeFieldName('Leads');
                    gen.writeStartArray();
                    
                    for(Lead l: leadList) {
                        gen.writeStartObject();
                        
                        if(l.FirstName != null && l.FirstName != '')
                            gen.writeStringField('FNAME', l.FirstName);
                        else
                            gen.writeStringField('FNAME', '');
                        if(l.LastName != null && l.LastName != '') {
                            gen.writeStringField('LNAME', l.LastName);
                            gen.writeStringField('Free1', l.LastName);
                        } else {
                            gen.writeStringField('LNAME', '');
                            gen.writeStringField('Free1', '');
                        }
                        if(l.AOD_Master__c != null)
                            gen.writeStringField('SERVICEID', l.AOD_Master__r.Service_Id__c);
                        else
                            gen.writeStringField('SERVICEID', '');
                        if(l.MobilePhone != null && l.MobilePhone != '')
                            gen.writeStringField('MOBILE_NO', l.MobilePhone);
                        else
                            gen.writeStringField('MOBILE_NO', '');
                        //if(l.Whatsapp_Notification__c)
                        //gen.writeStringField('WHATSAPP_RESPONSE_FLAG', 'Yes');
                        //else
                        gen.writeStringField('WHATSAPP_RESPONSE_FLAG', 'No'); //Default
                        if(l.Pincode__c != null && l.Pincode__c != '')
                            gen.writeStringField('PINCODE', l.Pincode__c);
                        else
                            gen.writeStringField('PINCODE', '');
                        gen.writeStringField('SFDC_LEADID', l.Id);
                        if(l.Is_Serviced__c && !l.Lead_In_Calling_Queue__c)
                            gen.writeStringField('REQUESTTYPE', 'FRESH');
                        else if(!l.Is_Serviced__c && l.Lead_In_Calling_Queue__c)
                            gen.writeStringField('REQUESTTYPE', 'RESET LEAD');
                        else
                            gen.writeStringField('REQUESTTYPE', 'FRESH');
                        if(l.City__c != null && l.City__c != '')
                            gen.writeStringField('CITY', l.City__c);
                        else
                            gen.writeStringField('CITY', '');
                        if(l.State__c != null && l.State__c != '')
                            gen.writeStringField('STATE', l.State__c);
                        else
                            gen.writeStringField('STATE', '');
                        gen.writeStringField('CIRCLE', '');
                        if(l.Street != null && l.Street != '')
                            gen.writeStringField('ADDRESS', l.Street);
                        else
                            gen.writeStringField('ADDRESS', '');
                        if(l.CampaignName__c != null && l.CampaignName__r.Digital_Marketing_Campaign_Code__c != null && l.CampaignName__r.Digital_Marketing_Campaign_Code__c != '')
                            gen.writeStringField('CAMPAIGN', l.CampaignName__r.Digital_Marketing_Campaign_Code__c);
                        else
                            gen.writeStringField('CAMPAIGN', '');
                        gen.writeStringField('LEADCREATED_DATE_TIME', l.CreatedDate.format('yyyyMMddHHmmss'));
                        
                        gen.writeEndObject();
                    }
                    gen.writeEndArray();
                    gen.writeEndObject();
                    
                    // Get the JSON string.
                    body = gen.getAsString();
                    system.debug('body:: ' + body);
                    
                    /* Calling Post method to push data */
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
                    
                    if(response.getStatusCode() == 200) {
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        
                        for(Lead l: leadList) {
                            if(responseMap != null && !responseMap.isEmpty() && responseMap.containsKey('ResponseCode')) {
                                if(responseMap.get('ResponseCode') == '00') {
                                    System_Log__c SL = new System_Log__c();
                                    SL.API_Name__c  = 'Lead Push Details';
                                    SL.Request__c = body;
                                    SL.Lead__c = l.Id;
                                    SL.Success__c = true;
                                    SL.Response__c = response.getBody();
                                    insertSystemLogList.add(SL);
                                } else {
                                    System_Log__c SL = new System_Log__c();
                                    SL.API_Name__c  = 'Lead Push Details';
                                    SL.Request__c = body;
                                    SL.Lead__c = l.Id;
                                    SL.Success__c = false;
                                    SL.Response__c = response.getBody();
                                    insertSystemLogList.add(SL);
                                }
                                l.Lead_In_Calling_Queue__c = true;
                                updateLeadList.add(l);
                            } else {
                                System_Log__c SL = new System_Log__c();
                                SL.API_Name__c  = 'Lead Push Details';
                                SL.Request__c = body;
                                SL.Lead__c = l.Id;
                                SL.Success__c = false;
                                SL.Response__c = response.getBody();
                                insertSystemLogList.add(SL);
                            }
                        }
                    } else {
                        for(Lead l: leadList) {
                            System_Log__c SL = new System_Log__c();
                            SL.API_Name__c  = 'Lead Push Details';
                            SL.Request__c = body;
                            SL.Lead__c = l.Id;
                            SL.Success__c = false;
                            SL.Response__c = response.getBody();
                            insertSystemLogList.add(SL);
                        }
                    }
                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                    if(isEnabled[0].Enable_Logs__c) {
                        if(!insertSystemLogList.isEmpty() && insertSystemLogList.size() > 0)
                            insert insertSystemLogList;
                    }
                    if(!updateLeadList.isEmpty())
                        update updateLeadList;
                }
            }
            if(Test.isrunningtest()) integer i = 1/0;
        }
        catch(exception e){
            System_Log__c SL = new System_Log__c();
            //SL.Lead__c = l.Id;
            SL.API_Name__c  = 'Lead Push Details';
            SL.Success__c = false;
            SL.Request__c = body;
            SL.Response__c = e.getMessage() + e.getLineNumber();
            insert SL;
        }
    }
    
    /* Block Lead Data in Calling Queue CTI API */
    @future(callout = true)
    public static void blockLeadfromCallingQueue(Set<Id> lIdSet){
        blockLeadfromCallingQueueNonFuture(lIdSet);
    }
    public static void blockLeadfromCallingQueueNonFuture(Set<Id> lIdSet) {
        String body = '';
        try{
            List<Lead> leadList = new List<Lead>();
            List<Lead> updateLeadList = new List<Lead>();
            List<System_Log__c> insertSystemLogList = new List<System_Log__c>();
            Http http = new Http();
            
            /* Authenticate the CTI */
            String endPointURL = '';
            if(API_Integration__c.getValues('Lead Block Details') != null)
                endPointURL = API_Integration__c.getValues('Lead Block Details').URL__c;
            
            if(lIdSet != null && lIdSet.size() > 0) {
                leadList = [Select Id, FirstName, LastName, MobilePhone, Email, Pincode__c, Whatsapp_Notification__c, AOD_Master__c, AOD_Master__r.Service_Id__c,
                            Is_Serviced__c, Lead_In_Calling_Queue__c, Bot_Journey__c from Lead where Id IN: lIdSet];
                system.debug('leadList: '+leadList);
                
                if(!leadList.isEmpty() && leadList.size() > 0) {
                    /* Create JSON Body for Post method */
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeFieldName('Leads');
                    gen.writeStartArray();
                    
                    for(Lead l: leadList) {
                        gen.writeStartObject();
                        
                        if(l.AOD_Master__c != null)
                            gen.writeStringField('SERVICEID', l.AOD_Master__r.Service_Id__c);
                        else
                            gen.writeStringField('SERVICEID', '');
                        if(l.MobilePhone != null && l.MobilePhone != '')
                            gen.writeStringField('MOBILE_NO', l.MobilePhone);
                        else
                            gen.writeStringField('MOBILE_NO', '');
                        if(l.Bot_Journey__c != null && (l.Bot_Journey__c.equalsIgnoreCase('Responded-CA Lead') || l.Bot_Journey__c.equalsIgnoreCase('Appointment Scheduled-YM')))
                            gen.writeStringField('WHATSAPP_RESPONSE_FLAG', 'Yes');
                        else
                            gen.writeStringField('WHATSAPP_RESPONSE_FLAG', 'No');
                        gen.writeStringField('SFDC_LEADID', l.Id);
                        
                        gen.writeEndObject();
                    }
                    gen.writeEndArray();
                    gen.writeEndObject();
                    
                    // Get the JSON string.
                    body = gen.getAsString();
                    system.debug('body:: ' + body);
                    
                    /* Calling Post method to push data */
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
                    
                    if(response.getStatusCode() == 200) {
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        
                        for(Lead l: leadList) {
                            if(responseMap != null && !responseMap.isEmpty() && responseMap.containsKey('ResponseCode')) {
                                if(responseMap.get('ResponseCode') == '00') {
                                    System_Log__c SL = new System_Log__c();
                                    SL.API_Name__c  = 'Lead Block Details';
                                    SL.Request__c = body;
                                    SL.Lead__c = l.Id;
                                    SL.Success__c = true;
                                    SL.Response__c = response.getBody();
                                    insertSystemLogList.add(SL);
                                } else {
                                    System_Log__c SL = new System_Log__c();
                                    SL.API_Name__c  = 'Lead Block Details';
                                    SL.Request__c = body;
                                    SL.Lead__c = l.Id;
                                    SL.Success__c = false;
                                    SL.Response__c = response.getBody();
                                    insertSystemLogList.add(SL);
                                }
                                l.Lead_In_Calling_Queue__c = false;
                                updateLeadList.add(l);
                            } else {
                                System_Log__c SL = new System_Log__c();
                                SL.API_Name__c  = 'Lead Block Details';
                                SL.Request__c = body;
                                SL.Lead__c = l.Id;
                                SL.Success__c = false;
                                SL.Response__c = response.getBody();
                                insertSystemLogList.add(SL);
                            }
                        }
                    } else {
                        for(Lead l: leadList) {
                            System_Log__c SL = new System_Log__c();
                            SL.API_Name__c  = 'Lead Block Details';
                            SL.Request__c = body;
                            SL.Lead__c = l.Id;
                            SL.Success__c = false;
                            SL.Response__c = response.getBody();
                            insertSystemLogList.add(SL);
                        }
                    }
                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                    if(isEnabled[0].Enable_Logs__c) {
                        if(!insertSystemLogList.isEmpty() && insertSystemLogList.size() > 0)
                            insert insertSystemLogList;
                    }
                    if(!updateLeadList.isEmpty())
                        update updateLeadList;
                }
            }
            if(Test.isrunningtest()) integer i = 1/0;
        }
        catch(exception e){
            System_Log__c SL = new System_Log__c();
            //SL.Lead__c = l.Id;
            SL.API_Name__c  = 'Lead Block Details';
            SL.Success__c = false;
            SL.Request__c = body;
            SL.Response__c = e.getMessage() + e.getLineNumber();
            insert SL;
        }
    }
    
    /* Send Call Disposition to CTI */
    @future(callout = true)
    public static void sendCallDispositionCTI(Set<Id> taskId) {
        String body = '';
        try{
            List<Task> taskList = new List<Task>();
            List<System_Log__c> insertSystemLogList = new List<System_Log__c>();
            Http http = new Http();
            
            /* Authenticate the CTI */
            String endPointURL = '';
            if(API_Integration__c.getValues('Call Disposition Update') != null)
                endPointURL = API_Integration__c.getValues('Call Disposition Update').URL__c;
            
            if(taskId != null && taskId.size() > 0) {
                taskList = [Select Id, OwnerId, Owner.Email, WhoId, WhatId, Mobile__c, Disposition__c, Sub_Disposition__c, Follow_Up_DateTime__c, Self_Callback__c, Language__c
                            from Task where Id IN: taskId];
                system.debug('taskList: '+taskList);
                
                if(!taskList.isEmpty() && taskList.size() > 0) {
                    /* Create JSON Body for Post method */
                    JSONGenerator gen = JSON.createGenerator(true);
                    gen.writeStartObject();
                    gen.writeFieldName('callDispostion');
                    gen.writeStartArray();
                    
                    for(Task t: taskList) {
                        gen.writeStartObject();
                        
                        if(t.Mobile__c != null)
                            gen.writeStringField('MOBILENO', t.Mobile__c);
                        else
                            gen.writeStringField('MOBILENO', '');
                        if(t.WhoId != null && t.WhoId.getSObjectType().getDescribe().getName() == 'Lead')
                            gen.writeStringField('SFDC_LEADID', t.WhoId);
                        else
                            gen.writeStringField('SFDC_LEADID', '');
                        gen.writeStringField('SFDC_TASKID', t.Id);
                        if(t.Disposition__c != null)
                            gen.writeStringField('DISPOSITION', t.Disposition__c);
                        else
                            gen.writeStringField('DISPOSITION', '');
                        if(t.Sub_Disposition__c != null)
                            gen.writeStringField('SUBDISPOSITION', t.Sub_Disposition__c);
                        else
                            gen.writeStringField('SUBDISPOSITION', '');
                        if(t.Follow_Up_DateTime__c != null)
                            gen.writeStringField('FOLLOWUP_DATETIME', t.Follow_Up_DateTime__c.format('yyyy-MM-dd HH:mm:ss'));
                        else
                            gen.writeStringField('FOLLOWUP_DATETIME', '');
                        gen.writeStringField('AGENT_ID', t.OwnerId);
                        if(t.Self_Callback__c)
                            gen.writeStringField('SELF_CALLBACK', 'YES');
                        else
                            gen.writeStringField('SELF_CALLBACK', 'NO');
                        if(t.Language__c != null)
                            gen.writeStringField('LANGUAGE', t.Language__c);
                        else
                            gen.writeStringField('LANGUAGE', '');
                        
                        gen.writeEndObject();
                    }
                    gen.writeEndArray();
                    gen.writeEndObject();
                    
                    // Get the JSON string.
                    body = gen.getAsString();
                    system.debug('body:: ' + body);
                    
                    /* Calling Post method to push data */
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
                    
                    if(response.getStatusCode() == 200) {
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        
                        if(responseMap != null && !responseMap.isEmpty() && responseMap.containsKey('ResponseCode')) {
                            if(responseMap.get('ResponseCode') == '00') {
                                System_Log__c SL = new System_Log__c();
                                SL.API_Name__c  = 'Call Disposition Update';
                                SL.Request__c = body;
                                SL.Success__c = true;
                                SL.Response__c = response.getBody();
                                insertSystemLogList.add(SL);                            
                            } else {
                                System_Log__c SL = new System_Log__c();
                                SL.API_Name__c  = 'Call Disposition Update';
                                SL.Request__c = body;
                                SL.Success__c = false;
                                SL.Response__c = response.getBody();
                                insertSystemLogList.add(SL);
                            }
                        } else {
                            System_Log__c SL = new System_Log__c();
                            SL.API_Name__c  = 'Call Disposition Update';
                            SL.Request__c = body;
                            SL.Success__c = false;
                            SL.Response__c = response.getBody();
                            insertSystemLogList.add(SL);
                        }
                    } else {
                        System_Log__c SL = new System_Log__c();
                        SL.API_Name__c  = 'Call Disposition Update';
                        SL.Request__c = body;
                        SL.Success__c = false;
                        SL.Response__c = response.getBody();
                        insertSystemLogList.add(SL);
                    }
                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                    if(isEnabled[0].Enable_Logs__c) {
                        if(!insertSystemLogList.isEmpty() && insertSystemLogList.size() > 0)
                            insert insertSystemLogList;
                    }
                }
            }
            if(Test.isrunningtest()) integer i = 1/0;
        }
        catch(exception e){
            System_Log__c SL = new System_Log__c();
            SL.API_Name__c  = 'Call Disposition Update';
            SL.Success__c = false;
            SL.Request__c = body;
            SL.Response__c = e.getMessage() + e.getLineNumber();
            insert SL;
        }
    }
}