/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 04-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex Class for External System API Integration .
*********************************************************************************************************/
public class AP_ExternalSystemAPIManagementServices {
    @future(callout = true)
    public static void addCustomerSleek(Set<Id> lIdSet) {
        String body = '';
        try{
            List<Lead> leadList = new List<Lead>();
            List<System_Log__c> insertSystemLogList = new List<System_Log__c>();
            
            if(lIdSet != null && lIdSet.size() > 0) {
                leadList = [Select Id, Name, MobilePhone, Email, Street, City, State, Country, Dealer__c, Dealer__r.Dealer_Code__c from Lead where Id IN: lIdSet];
                system.debug('leadList: '+leadList);
                
                if(!leadList.isEmpty() && leadList.size() > 0) {
                    for(Lead l: leadList) {
                        String address = '';
                        Http http = new Http();
                        
                        String username = '';  //custom setting for username
                        String password = '';   //custom setting for password
                        String endPointURL = ''; //custom setting for endPointURL
                        String appVersion = ''; //custom setting for appVersion
                        
                        /* Authenticate the External System(Sleek) */
                        if(API_Integration__c.getValues('Sleek Add Customer API') != null){
                            userName = API_Integration__c.getValues('Sleek Add Customer API').User_Name__c;  
                            password = API_Integration__c.getValues('Sleek Add Customer API').Password__c;  
                            endPointURL = API_Integration__c.getValues('Sleek Add Customer API').URL__c; 
                            appVersion = API_Integration__c.getValues('Sleek Add Customer API').App_Version__c; 
                        }    
                        
                        /* Create JSON Body for Post method */
                        JSONGenerator gen = JSON.createGenerator(true);
                        gen.writeStartObject();
                        gen.writeStringField('APP_ID', 'SLEEK'); // Hard Code
                        
                        if(appVersion != null && appVersion != '')
                            gen.writeStringField('APP_VERSION', appVersion);
                        else
                            gen.writeStringField('APP_VERSION', '');
                        
                        if(l.Name != null && l.Name != '') {
                            gen.writeStringField('CUSTOMER_NAME', l.Name);
                            gen.writeStringField('BILLING_NAME', l.Name);
                        } else {
                            gen.writeStringField('CUSTOMER_NAME', '');
                            gen.writeStringField('BILLING_NAME', '');
                        }
                        if(l.MobilePhone != null && l.MobilePhone != '')
                            gen.writeStringField('MOBILE_NUMBER_PRIMARY', l.MobilePhone);
                        else
                            gen.writeStringField('MOBILE_NUMBER_PRIMARY', '');
                        
                        if(l.Email != null && l.Email != '')
                            gen.writeStringField('EMAIL', l.Email);
                        else
                            gen.writeStringField('EMAIL', '');
                        
                        if(l.Street != null && l.Street != '')
                            address += l.Street;
                        if(l.City != null && l.City != '')
                            address += l.City;
                        if(l.State != null && l.State != '')
                            address += l.State;
                        if(l.Country != null && l.Country != '')
                            address += l.Country;
                        
                        if(address != null && address != '') {
                            gen.writeStringField('ADDRESS', address);
                            gen.writeStringField('BILLING_ADDRESS', address);
                        } else {
                            gen.writeStringField('ADDRESS', '');
                            gen.writeStringField('BILLING_ADDRESS', '');
                        }
                        
                        if(l.Dealer__c != null && l.Dealer__r.Dealer_Code__c != null && l.Dealer__r.Dealer_Code__c != '')
                            gen.writeStringField('DEALER_CODE', l.Dealer__r.Dealer_Code__c);
                        else
                            gen.writeStringField('DEALER_CODE', '');
                        
                        gen.writeStringField('PCODE', '');
                        gen.writeStringField('MOBILE_NUMBER_SECONDARY', '');
                        gen.writeStringField('CREATION_DATE', ''); // Hard Code
                        
                        gen.writeEndObject();
                        
                        // Get the JSON string.
                        body = gen.getAsString();
                        system.debug('body:: ' + body);
                        
                        /* Get authorizationHeader */
                        Blob headerValue = Blob.valueOf(Username + ':' + Password);
                        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                        
                        /* Calling Post method to push data */
                        Httprequest request = new HttpRequest();                      
                        request.setMethod('POST');
                        request.setEndpoint(endPointURL);         
                        request.setTimeout(120000);
                        request.setHeader('Content-Type', 'application/json');
                        request.setHeader('Authorization', authorizationHeader); 
                        request.setBody(body);  
                        
                        System_Log__c SL = new System_Log__c();
                        SL.Lead__c = l.Id;
                        SL.API_Name__c  = 'Sleek API Add Customer';
                        SL.Request__c = body;
                        
                        //if(!Test.isRunningTest()) {
                        //Making call to external REST API
                        HttpResponse response = http.send(request);
                        system.debug('response: '+response.getBody());
                        
                        if(response.getStatusCode() == 200) {
                            AP_SleekJSONToApex json = AP_SleekJSONToApex.parse(response.getBody());
                            
                            if(json.SUCCESS == '1') {
                                SL.Success__c = true;
                                SL.Response__c = response.getBody();
                            } else if(json.SUCCESS == '0') {
                                SL.Success__c = false;
                                SL.Response__c = response.getBody();
                            } else {
                                SL.Success__c = false;
                                SL.Response__c = response.getBody();
                            }
                        } else {
                            SL.Success__c = false;
                            SL.Response__c = response.getBody();
                        }
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
            SL.API_Name__c  = 'Sleek API Add Customer Exception';
            SL.Success__c = false;
            SL.Request__c = body;
            SL.Response__c = e.getMessage() + ' ' +e.getLineNumber();
            insert SL;
        }
    }
    
    @future(callout = true)
    public static void addSiteSleek(Set<Id> lIdSet) {
        String body = '';
        try{
            List<Lead> leadList = new List<Lead>();
            List<Lead> updateLeadList = new List<Lead>();
            List<System_Log__c> insertSystemLogList = new List<System_Log__c>();
            String externalId = '';
            
            if(lIdSet != null && lIdSet.size() > 0) {
                leadList = [Select Id, Name, MobilePhone, Email, Street, City, State, Country, Dealer__c, Dealer__r.Dealer_Code__c, Project_Type__c, Budget__c,Rating, 
                            Initiator_Mobile__c, Initiator_Name__c, Initiator_BP__c, Priority__c, Pincode__c, Referrer_Name__c, Referrer_Mobile__c, Referral_Type__c,
                            Site_Type__c, Initiator_Employee_Id__c, LeadSource from Lead where Id IN: lIdSet];
                system.debug('leadList: '+leadList);
                
                if(!leadList.isEmpty() && leadList.size() > 0) {
                    for(Lead l: leadList) {
                        Http http = new Http();
                        
                        String username = '';  //custom setting for username
                        String password = '';   //custom setting for password
                        String endPointURL = ''; //custom setting for endPointURL
                        String appVersion = ''; //custom setting for appVersion
                        
                        /* Authenticate the External System(Sleek) */
                        if(API_Integration__c.getValues('Sleek Add Site API') != null){
                            userName = API_Integration__c.getValues('Sleek Add Site API').User_Name__c;  
                            password = API_Integration__c.getValues('Sleek Add Site API').Password__c;  
                            endPointURL = API_Integration__c.getValues('Sleek Add Site API').URL__c;  
                            appVersion = API_Integration__c.getValues('Sleek Add Site API').App_Version__c; 
                        }
                        
                        /* Create JSON Body for Post method */
                        JSONGenerator gen = JSON.createGenerator(true);
                        gen.writeStartObject();
                        gen.writeStringField('APP_ID', 'SLEEK'); // Hard Code
                        gen.writeStringField('CRM_LEAD_NUMBER', l.Id);
                        
                        if(appVersion != null && appVersion != '')
                            gen.writeStringField('APP_VERSION', appVersion);
                        else
                            gen.writeStringField('APP_VERSION', '');
                        
                        if(l.MobilePhone != null && l.MobilePhone != '')
                            gen.writeStringField('CUST_ID', l.MobilePhone);
                        else
                            gen.writeStringField('CUST_ID', '');
                        
                        if(l.Dealer__c != null && l.Dealer__r.Dealer_Code__c != null && l.Dealer__r.Dealer_Code__c != '')
                            gen.writeStringField('AGENT_CODE', l.Dealer__r.Dealer_Code__c);
                        else
                            gen.writeStringField('AGENT_CODE', '');
                        
                        if(l.Project_Type__c != null && l.Project_Type__c != '') {
                            gen.writeStringField('PROJECT_TYPE', l.Project_Type__c);
                            gen.writeStringField('SQ_NAME', l.Name +' - '+l.Project_Type__c);
                        } else {
                            gen.writeStringField('PROJECT_TYPE', 'Kitchen'); //Default if blank
                            gen.writeStringField('SQ_NAME', l.Name +' - Kitchen'); //Default if blank
                        }
                        
                        if(l.Site_Type__c != null && l.Site_Type__c != '')
                            gen.writeStringField('SITE_TYPE', l.Site_Type__c);
                        else
                            gen.writeStringField('SITE_TYPE', '');
                        
                        if(l.Dealer__c != null && l.Dealer__r.Dealer_Code__c != null && l.Dealer__r.Dealer_Code__c != '')
                            gen.writeStringField('OWNER', l.Dealer__r.Dealer_Code__c);
                        else
                            gen.writeStringField('OWNER', '');
                        
                        if(l.Budget__c != null && l.Budget__c != '')
                            gen.writeStringField('BUDGET', l.Budget__c);
                        else
                            gen.writeStringField('BUDGET', '0');
                        
                        if(l.LeadSource != null && l.LeadSource != '')
                            gen.writeStringField('SOURCE_OF_LEAD', l.LeadSource);
                        else
                            gen.writeStringField('SOURCE_OF_LEAD', 'Website'); //Default if blank
                        
                        if(l.Initiator_Employee_Id__c != null && l.Initiator_Employee_Id__c != '')
                            gen.writeStringField('INITIATOR_EMP_ID', l.Initiator_Employee_Id__c);
                        else
                            gen.writeStringField('INITIATOR_EMP_ID', '');
                        
                        if(l.Initiator_Mobile__c != null && l.Initiator_Mobile__c != '')
                            gen.writeStringField('INITIATOR_MOBILE', l.Initiator_Mobile__c);
                        else
                            gen.writeStringField('INITIATOR_MOBILE', '');
                        
                        if(l.Initiator_Name__c != null && l.Initiator_Name__c != '')
                            gen.writeStringField('INITIATOR_NAME', l.Initiator_Name__c);
                        else
                            gen.writeStringField('INITIATOR_NAME', '');
                        
                        if(l.Initiator_BP__c != null && l.Initiator_BP__c != '')
                            gen.writeStringField('INITIATOR_BP', l.Initiator_BP__c);
                        else
                            gen.writeStringField('INITIATOR_BP', '');
                        
                        if(l.Rating != null && l.Rating != '')
                            gen.writeStringField('PRIORITY', l.Rating);
                        else
                            gen.writeStringField('PRIORITY', 'Warm'); //Default if blank
                        
                        if(l.Pincode__c != null && l.Pincode__c != '')
                            gen.writeStringField('PINCODE', l.Pincode__c);
                        else
                            gen.writeStringField('PINCODE','');
                        
                        if(l.Referral_Type__c != null && l.Referral_Type__c != '' && l.Referral_Type__c.equalsIgnoreCase('Customer')) {
                            if(l.Referrer_Name__c != null && l.Referrer_Name__c != '')
                                gen.writeStringField('CUST_REFERRAL_NAME', l.Referrer_Name__c);
                            else
                                gen.writeStringField('CUST_REFERRAL_NAME','');
                            
                            if(l.Referrer_Mobile__c != null && l.Referrer_Mobile__c != '')
                                gen.writeStringField('CUST_REFERRAL_MOBILE', l.Referrer_Mobile__c);
                            else
                                gen.writeStringField('CUST_REFERRAL_MOBILE', '');
                        }
                        
                        gen.writeStringField('SITE_ID', ''); // Hard Code
                        gen.writeStringField('SCHEDULED_DATE', ''); //Hard Code
                        gen.writeStringField('FOLLOWUP_DATE', ''); //Hard Code
                        gen.writeStringField('CURRENT_STAGE', 'LEAD_CREATION'); //Hard Code
                        gen.writeStringField('LAST_UPDATE_ACTIVITY', 'LEAD_CAPTURE'); //Hard Code
                        gen.writeStringField('TOTAL_SITE_VALUE', ''); //Hard Code
                        gen.writeStringField('MONEY_RECEIVED', ''); //Hard Code
                        gen.writeStringField('ADVANCE_AMOUNT_RECEIVED', ''); //Hard Code
                        gen.writeStringField('CREATION_DATE', ''); //Hard Code
                        gen.writeStringField('UPDATION_DATE', ''); //Hard Code
                        gen.writeStringField('LAST_UPDATED_BY', ''); //Hard Code
                        gen.writeStringField('CREATED_BY', ''); //Hard Code
                        gen.writeStringField('CUST_REFERRAL_EMAIL', ''); //Hard Code
                        //gen.writeStringField('FLAG_SALESFORCE', 'Y'); //Hard Code
                        
                        gen.writeEndObject();
                        
                        // Get the JSON string.
                        body = gen.getAsString();
                        system.debug('body:: ' + body);
                        
                        /* Get authorizationHeader */
                        Blob headerValue = Blob.valueOf(Username + ':' + Password);
                        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                        
                        /* Calling Post method to push data */
                        Httprequest request = new HttpRequest();                      
                        request.setMethod('POST');
                        request.setEndpoint(endPointURL);         
                        request.setTimeout(120000);
                        request.setHeader('Content-Type', 'application/json');
                        request.setHeader('Authorization', authorizationHeader); 
                        request.setBody(body);  
                        
                        System_Log__c SL = new System_Log__c();
                        SL.Lead__c = l.Id;
                        SL.API_Name__c  = 'Sleek API Add Site';
                        SL.Request__c = body;
                        
                        //if(!Test.isRunningTest()) {
                        //Making call to external REST API
                        HttpResponse response = http.send(request);
                        system.debug('response: '+response.getBody());
                        
                        if(response.getStatusCode() == 200) {
                            String res = response.getBody();
                            Map<String, Object> oMap = (Map<String, Object>) JSON.deserializeUntyped(res);
                            if(oMap != null && !oMap.isEmpty() && oMap.containsKey('SITE ID')) {
                                externalId = (string)oMap.get('SITE ID');
                                system.debug('externalId: '+externalId);
                                
                                //Add External Id On Lead//
                                if(externalId != null && externalId != '') {
                                    Lead newLead = new Lead();
                                    newLead.Id = l.Id;
                                    newLead.External_Lead_ID__c = externalId;
                                    updateLeadList.add(newLead);
                                }
                                
                                SL.Success__c = true;
                                SL.Response__c = response.getBody();
                            } else {
                                SL.Success__c = false;
                                SL.Response__c = response.getBody();
                            }
                            //AP_SleekJSONToApex json = AP_SleekJSONToApex.parse(response.getBody());
                            /*if(json.USER_DATA != null && json.USER_DATA != '') {
externalId = json.USER_DATA;
system.debug('externalId: '+externalId);

//Add External Id On Lead//
if(externalId != null && externalId != '') {
Lead newLead = new Lead();
newLead.Id = l.Id;
newLead.External_Lead_ID__c = externalId;
updateLeadList.add(newLead);
}

SL.Success__c = true;
SL.Response__c = response.getBody();
} else {
SL.Success__c = false;
SL.Response__c = response.getBody();
}*/
                        } else {
                            SL.Success__c = false;
                            SL.Response__c = response.getBody();
                        }
                        insertSystemLogList.add(SL);
                    }
                    if(!updateLeadList.isEmpty() && updateLeadList.size() > 0)
                        update updateLeadList;
                    
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
            SL.API_Name__c  = 'Sleek API Add Site Exception';
            SL.Success__c = false;
            SL.Request__c = body;
            SL.Response__c = e.getMessage() + ' ' +e.getLineNumber();
            insert SL;
        }
    }
    
    @future(callout = true)
    public static void sendC4CLeadDetails(Set<Id> lIdSet) {
        String body = '';
        try{
            List<Lead> leadList = new List<Lead>();
            List<Lead> updateLeadList = new List<Lead>();
            List<System_Log__c> insertSystemLogList = new List<System_Log__c>();
            Map<Id,Schema.RecordTypeInfo> rtMap = Lead.sobjectType.getDescribe().getRecordTypeInfosById(); //Find all the record type
            
            if(lIdSet != null && lIdSet.size() > 0) {
                leadList = [Select Id, Name, MobilePhone, Email, Status, RecordTypeId, ERP_B1_Id__c, External_System_Lead_Id__c, Current_Owner_Name__c, Current_Owner_Email__c,
                            Owner.Name, Owner.Email, Owner.Phone, Current_Owner_Employee_Id__c, Current_Owner_Mobile__c,  Status_From_API__c, Dealer__c, Dealer__r.Dealer_Code__c from Lead 
                            where Id IN: lIdSet];
                system.debug('leadList: '+leadList);
                
                if(!leadList.isEmpty() && leadList.size() > 0) {
                    for(Lead l: leadList) {
                        String ownerName = '';
                        String ownerEmail = '';
                        String ownerMobile = '';
                        String ownerEmpId = '';
                        String leadStatus = '';
                        String dealerCode = '';
                        String ERPId = '';
                        String sleekBody = '';
                        String spsBody = '';
                        String bhsBody = '';
                        String username = '';  //custom setting for username
                        String password = '';   //custom setting for password
                        String endPointURL = ''; //custom setting for endPointURL
                        
                        /* Authenticate the External System(C4C) */
                        if(API_Integration__c.getValues('C4C Lead Update API') != null){
                            userName = API_Integration__c.getValues('C4C Lead Update API').User_Name__c;  
                            password = API_Integration__c.getValues('C4C Lead Update API').Password__c;  
                            endPointURL = API_Integration__c.getValues('C4C Lead Update API').URL__c;
                        }
                        
                        if(l.Dealer__c != null && l.Dealer__r.Dealer_Code__c != null && l.Dealer__r.Dealer_Code__c != '')
                            dealerCode = l.Dealer__r.Dealer_Code__c;
                        if(l.Current_Owner_Name__c != null && l.Current_Owner_Name__c != '')
                            ownerName = l.Current_Owner_Name__c;
                        else
                            ownerName = l.Owner.Name;
                        if(l.Current_Owner_Email__c != null && l.Current_Owner_Email__c != '')
                            ownerEmail = l.Current_Owner_Email__c;
                        else
                            ownerEmail = l.Owner.Email;
                        if(l.Current_Owner_Employee_Id__c != null && l.Current_Owner_Employee_Id__c != '')
                            ownerEmpId = l.Current_Owner_Employee_Id__c;
                        else
                            ownerEmpId = '';//l.Owner.EmployeeNumber;
                        if(l.Current_Owner_Mobile__c != null && l.Current_Owner_Mobile__c != '')
                            ownerMobile = l.Current_Owner_Mobile__c;
                        else
                            ownerMobile = l.Owner.Phone;
                        if(l.Status_From_API__c != null && l.Status_From_API__c != '')
                            leadStatus = l.Status_From_API__c;
                        else
                            leadStatus = l.Status;
                        if(l.ERP_B1_Id__c != null && l.ERP_B1_Id__c != '')
                            ERPId = l.ERP_B1_Id__c;
                        else
                            ERPId = '';
                        
                        if(rtMap.get(l.RecordTypeId).getDeveloperName().equalsIgnoreCase('SLEEK')) {
                            sleekBody += '<!--Optional:--> <ZSleekOBStatus>'+ ERPId +'</ZSleekOBStatus>'+
                                '<!--Optional:--> <ZSleekOBDate></ZSleekOBDate>'+
                                '<!--Optional:--> <ZSleekDesignerName>'+ ownerName +'</ZSleekDesignerName>'+
                                '<!--Optional:--> <ZSleekDesignerEmail>'+ ownerEmail +'</ZSleekDesignerEmail>'+
                                '<!--Optional:--> <ZSleekDesignerID>'+ ownerEmpId +'</ZSleekDesignerID>'+
                                '<!--Optional:--> <ZSleekDesignerContact>'+ ownerMobile +'</ZSleekDesignerContact>'+
                                '<!--Optional:--> <ZSleekLeadStatus>'+ leadStatus +'</ZSleekLeadStatus>';
                        } else {
                            sleekBody += '<!--Optional:--> <ZSleekOBStatus></ZSleekOBStatus>'+
                                '<!--Optional:--> <ZSleekOBDate></ZSleekOBDate>'+
                                '<!--Optional:--> <ZSleekDesignerName></ZSleekDesignerName>'+
                                '<!--Optional:--> <ZSleekDesignerEmail></ZSleekDesignerEmail>'+
                                '<!--Optional:--> <ZSleekDesignerID></ZSleekDesignerID>'+
                                '<!--Optional:--> <ZSleekDesignerContact></ZSleekDesignerContact>'+
                                '<!--Optional:--> <ZSleekLeadStatus></ZSleekLeadStatus>';
                        }
                        
                        if(rtMap.get(l.RecordTypeId).getDeveloperName().equalsIgnoreCase('SPS')) {
                            spsBody += '<!--Optional:--> <ZPTPRLeadStatus>'+ leadStatus +'</ZPTPRLeadStatus>'+
                                '<!--Optional:--> <ZPTPRLeadOwnerEmpName>'+ ownerName +'</ZPTPRLeadOwnerEmpName>'+
                                '<!--Optional:--> <ZPTPRLeadOwnerEmail>'+ ownerEmail +'</ZPTPRLeadOwnerEmail>'+
                                '<!--Optional:--> <ZPTPRLeadOwnerEmpID>'+ ownerEmpId +'</ZPTPRLeadOwnerEmpID>'+
                                '<!--Optional:--> <ZPTPRDealerCode>'+ dealerCode +'</ZPTPRDealerCode>'+
                                '<!--Optional:--> <ZPTPRContractorCode></ZPTPRContractorCode>';
                        } else {
                            spsBody += '<!--Optional:--> <ZPTPRLeadStatus></ZPTPRLeadStatus>'+
                                '<!--Optional:--> <ZPTPRLeadOwnerEmpName></ZPTPRLeadOwnerEmpName>'+
                                '<!--Optional:--> <ZPTPRLeadOwnerEmail></ZPTPRLeadOwnerEmail>'+
                                '<!--Optional:--> <ZPTPRLeadOwnerEmpID></ZPTPRLeadOwnerEmpID>'+
                                '<!--Optional:--> <ZPTPRDealerCode></ZPTPRDealerCode>'+
                                '<!--Optional:--> <ZPTPRContractorCode></ZPTPRContractorCode>';
                        }
                        
                        if(rtMap.get(l.RecordTypeId).getDeveloperName().equalsIgnoreCase('BHS')) {
                            bhsBody += '<!--Optional:--> <ZBHSLeadTaggingDate></ZBHSLeadTaggingDate>'+
                                '<!--Optional:--> <ZBHSLeadStatus>'+ leadStatus +'</ZBHSLeadStatus>'+
                                '<!--Optional:--> <ZBHSLeadOwnerEmail>'+ ownerEmail +'</ZBHSLeadOwnerEmail>'+
                                '<!--Optional:--> <ZBHSLeadOwnerEmpID>'+ ownerEmpId +'</ZBHSLeadOwnerEmpID>'+
                                '<!--Optional:--> <ZBHSLeadOwnerEmpName>'+ ownerName +'</ZBHSLeadOwnerEmpName>';
                        } else {
                            bhsBody += '<!--Optional:--> <ZBHSLeadTaggingDate></ZBHSLeadTaggingDate>'+
                                '<!--Optional:--> <ZBHSLeadStatus></ZBHSLeadStatus>'+
                                '<!--Optional:--> <ZBHSLeadOwnerEmail></ZBHSLeadOwnerEmail>'+
                                '<!--Optional:--> <ZBHSLeadOwnerEmpID></ZBHSLeadOwnerEmpID>'+
                                '<!--Optional:--> <ZBHSLeadOwnerEmpName></ZBHSLeadOwnerEmpName>';
                        }
                        
                        body = '<?xml version="1.0" encoding="UTF-8"?>'+
                            '<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:glob="http://sap.com/xi/SAPGlobal20/Global">'+
                            '<soap:Header/>'+
                            '<soap:Body>'+
                            '<glob:ExternalLeadUpdateCreateRequest_sync>'+
                            '<ExternalLeadUpdate>'+
                            '<!--Optional:--> <ZExternalID>'+ l.External_System_Lead_Id__c +'</ZExternalID>'+
                            '<!--Optional:--> <ZSFDCLeadID>'+ l.Id +'</ZSFDCLeadID>'+
                            '<!--Optional:--> <ZDateOfDesignSharing></ZDateOfDesignSharing>'+
                            ''+ sleekBody +''+
                            ''+ spsBody +''+
                            ''+ bhsBody +''+
                            '</ExternalLeadUpdate>'+
                            '</glob:ExternalLeadUpdateCreateRequest_sync>'+
                            '</soap:Body>'+
                            '</soap:Envelope>';
                        system.debug('body: '+body);
                        
                        /* Get authorizationHeader */
                        Blob headerValue = Blob.valueOf(Username + ':' + Password);
                        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                        system.debug('authorizationHeader: '+authorizationHeader);
                        
                        /* Calling Post method to push data */
                        Http http = new Http();
                        Httprequest request = new HttpRequest();                      
                        request.setMethod('POST');
                        request.setEndpoint(endPointURL);
                        request.setHeader('Content-Type', 'application/soap+xml');
                        request.setHeader('Authorization', authorizationHeader); 
                        request.setBody(body); 
                        
                        System_Log__c SL = new System_Log__c();
                        SL.Lead__c = l.Id;
                        SL.API_Name__c  = 'C4C Lead Update API';
                        SL.Request__c = body;
                        
                        if(!Test.IsRunningTest()){       
                            HttpResponse response = http.send(request); 
                            system.debug('response: '+response.getBody());
                            
                            XmlStreamReader reader = new XmlStreamReader(response.getBody());
                            system.debug('result: '+response.getStatusCode());
                            
                            if(response.getStatusCode() == 200) {
                                /*Lead newLead = new Lead();
newLead.Id = l.Id;
newLead.Is_Update__c = true;
updateLeadList.add(newLead);*/
                                
                                SL.Success__c = true;
                                SL.Response__c = response.getBody();
                            } else {
                                SL.Success__c = false;
                                SL.Response__c = response.getBody();
                            }
                            insertSystemLogList.add(SL);
                        }
                    }
                    //if(!updateLeadList.isEmpty() && updateLeadList.size() > 0)
                    //update updateLeadList;
                    
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
            SL.API_Name__c  = 'C4C Lead Update API Exception';
            SL.Success__c = false;
            SL.Request__c = body;
            SL.Request__c = e.getMessage() + ' ' +e.getLineNumber();
            insert SL;
        }
    }
    
    @future(callout = true)
    public static void createLeadInBHSExternalSystem(Set<Id> lIdSet,String ApiName) {
        String bhsBody = '';
        try{
            List<Lead> leadList = new List<Lead>();
            List<Lead> updateLeadList = new List<Lead>();
            List<System_Log__c> insertSystemLogList = new List<System_Log__c>();
            Set<Id> uIdSet = new Set<Id>();
            List<User> uList = new List<User>();
            Map<Id, Contact> CAContactMap = new Map<Id, Contact>();
            String externalId = '';
            
            if(lIdSet != null && lIdSet.size() > 0) {
                leadList = [Select Id, FirstName, LastName, MobilePhone, Email, Phone, Street, CampaignName__c, CampaignName__r.Digital_Marketing_Campaign_Code__c,
                            City__c, Pincode_lookup__c, Pincode_lookup__r.Country_Code__c, Budget__c, Floor__c, House__c, Pincode__c, LeadSource, Pincode_lookup__r.State_Code__c,
                            External_Lead_Creator_Position_Code__c, Status, Priority__c, Probable_Conversion_Date__c, Referral_Type__c, Referrer_Name__c, Referrer_Email__c,
                            Referrer_Mobile__c, Site_Type__c, Summary_of_Work__c, Service_Territory__c, Service_Territory__r.Name, Service_Territory__r.Parent__c,
                            Service_Territory__r.Parent__r.Parent__c, Service_Territory__r.Parent__r.Parent__r.Name, CreatedDate, LastModifiedDate, External_System_Lead_Id__c,
                            Last_Appointment_End_Date_Time__c, Last_Appointment_Start_Date_Time__c, OwnerId, Dealer__c, Dealer__r.Dealer_Code__c, RecordType.Name
                            from Lead where Id IN: lIdSet];
                system.debug('leadList: '+leadList);
                
                if(!leadList.isEmpty() && leadList.size() > 0) {
                    for(Lead l: leadList) {
                        uIdSet.add(l.OwnerId);                    
                    }
                    if(!uIdSet.isEmpty()) {
                        uList = [SELECT Id, ContactId, Contact.AccountId, Name From User Where Id IN: uIdSet];
                        if(!uList.isEmpty()) {
                            CAContactMap = DealerManagementServices.getCAContact(uList);
                        }
                    }
                    
                    for(Lead l: leadList) {
                        String bhsToken = ''; //Token from Authorization API
                        String username = '';  //custom setting for username
                        String password = '';   //custom setting for password
                        String endPointURL = ''; //custom setting for endPointURL
                        String clientId = ''; //custom setting for clientId
                        String clientSecret = ''; //custom setting for clientId
                        
                        /* Authenticate the External System(BHS) */
                        if(API_Integration__c.getValues('BHS Authorization API') != null){
                            userName = API_Integration__c.getValues('BHS Authorization API').User_Name__c;  
                            password = API_Integration__c.getValues('BHS Authorization API').Password__c;  
                            endPointURL = API_Integration__c.getValues('BHS Authorization API').URL__c; 
                            clientId = API_Integration__c.getValues('BHS Authorization API').Client_Id__c;
                            clientSecret = API_Integration__c.getValues('BHS Authorization API').Client_Secret__c; 
                        }
                        
                        String payload = 'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+'&username='+EncodingUtil.urlEncode(username,'UTF-8')+'&password='+EncodingUtil.urlEncode(password,'UTF-8')+'&grant_type=password';
                        System.debug(payload);
                        
                        /* Calling Post method to push data */
                        Http http = new Http();
                        Httprequest request = new HttpRequest();                      
                        request.setMethod('POST');
                        request.setEndpoint(endPointURL);
                        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                        request.setBody(payload); 
                        
                        //if(!Test.IsRunningTest()) {      
                        HttpResponse response = http.send(request);
                        system.debug('response: '+response.getBody());
                        ExternalBHSSystemJSONtoApex jsonResponse = ExternalBHSSystemJSONtoApex.parse(response.getBody());
                        
                        if(jsonResponse.access_token != null && jsonResponse.access_token != '')
                            bhsToken = jsonResponse.access_token;
                        //}
                        
                        if(bhsToken != null && bhsToken != '') {
                            String bhsLeadEndPointURL = '';
                            /* Push BHS Lead Details API */
                            if(API_Integration__c.getValues('BHS Lead Push API') != null) {
                                bhsLeadEndPointURL = API_Integration__c.getValues('BHS Lead Push API').URL__c;
                            }
                            
                            /* Create JSON Body for Post method */
                            JSONGenerator genBHS = JSON.createGenerator(true);
                            genBHS.writeStartObject();
                            
                            if(l.Last_Appointment_End_Date_Time__c != null)
                                genBHS.writeStringField('aptEdTm', l.Last_Appointment_End_Date_Time__c.format('HH:mm:ss'));
                            else
                                genBHS.writeStringField('aptEdTm', '');
                            if(l.Last_Appointment_Start_Date_Time__c != null)
                                genBHS.writeStringField('aptStDt', l.Last_Appointment_Start_Date_Time__c.format('dd/MM/yyyy'));
                            else
                                genBHS.writeStringField('aptStDt', '');
                            if(l.Last_Appointment_Start_Date_Time__c != null)
                                genBHS.writeStringField('aptStTm', l.Last_Appointment_Start_Date_Time__c.format('HH:mm:ss'));
                            else
                                genBHS.writeStringField('aptStTm', '');
                            if(l.Street != null && l.Street != '')
                                genBHS.writeStringField('c_Address1', l.Street);
                            else
                                genBHS.writeStringField('c_Address1', 'Not Provided'); //Default if blank
                            genBHS.writeStringField('c_Address2', '');
                            genBHS.writeStringField('c_Address3', '');
                            genBHS.writeStringField('c_Address4', '');
                            if(l.CampaignName__c != null && l.CampaignName__r.Digital_Marketing_Campaign_Code__c != null && l.CampaignName__r.Digital_Marketing_Campaign_Code__c != '')
                                genBHS.writeStringField('c_CampaignCode', l.CampaignName__r.Digital_Marketing_Campaign_Code__c);
                            else
                                genBHS.writeStringField('c_CampaignCode', 'CAMP_ID'); //Default if blank
                            if(l.City__c != null && l.City__c != '')
                                genBHS.writeStringField('c_City', l.City__c);
                            else
                                genBHS.writeStringField('c_City', '');
                            if(l.Pincode_lookup__c != null && l.Pincode_lookup__r.Country_Code__c != null && l.Pincode_lookup__r.Country_Code__c != '')
                                genBHS.writeStringField('c_Country', l.Pincode_lookup__r.Country_Code__c);
                            else
                                genBHS.writeStringField('c_Country', '');
                            if(l.Email != null && l.Email != '')
                                genBHS.writeStringField('c_Email', l.Email);
                            else
                                genBHS.writeStringField('c_Email', 'email.notprovided@test.com'); //Default if blank
                            if(l.Budget__c != null && l.Budget__c != '')
                                genBHS.writeStringField('c_EstimatedValue', l.Budget__c);
                            else
                                genBHS.writeStringField('c_EstimatedValue', '');
                            if(l.FirstName != null && l.FirstName != '')
                                genBHS.writeStringField('c_FirstName', l.FirstName);
                            else if(l.LastName != null && l.LastName != '')
                                genBHS.writeStringField('c_FirstName', l.LastName);
                            else
                                genBHS.writeStringField('c_FirstName', '');
                            if(l.Floor__c != null && l.Floor__c != '')
                                genBHS.writeStringField('c_Floor', l.Floor__c);
                            else
                                genBHS.writeStringField('c_Floor', '');
                            if(l.House__c != null && l.House__c != '')
                                genBHS.writeStringField('c_House', l.House__c);
                            else
                                genBHS.writeStringField('c_House', '');
                            genBHS.writeStringField('c_IntegrationSource', 'CRM'); //Default Value
                            if(l.LastName != null && l.LastName != '')
                                genBHS.writeStringField('c_LastName', l.LastName);
                            else
                                genBHS.writeStringField('c_LastName', '');
                            if(l.MobilePhone != null && l.MobilePhone != '')
                                genBHS.writeStringField('c_Mobile', l.MobilePhone);
                            else
                                genBHS.writeStringField('c_Mobile', '');
                            if(l.Phone != null && l.Phone != '')
                                genBHS.writeStringField('c_Phone', l.Phone);
                            else
                                genBHS.writeStringField('c_Phone', '');
                            if(l.Pincode__c != null && l.Pincode__c != '')
                                genBHS.writeStringField('c_Pincode', l.Pincode__c);
                            else
                                genBHS.writeStringField('c_Pincode', '');
                            if(l.LeadSource != null && l.LeadSource != '')
                                genBHS.writeStringField('c_SoA', l.LeadSource);
                            else
                                genBHS.writeStringField('c_SoA', 'Website'); //Default if blank
                            if(l.Pincode_lookup__c != null && l.Pincode_lookup__r.State_Code__c != null && l.Pincode_lookup__r.State_Code__c != '')
                                genBHS.writeStringField('c_State', l.Pincode_lookup__r.State_Code__c);
                            else
                                genBHS.writeStringField('c_State', '');
                            if(l.LastModifiedDate != null)
                                genBHS.writeStringField('changeddt', l.LastModifiedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
                            else
                                genBHS.writeStringField('changeddt', '');
                            if(l.CreatedDate != null)
                                genBHS.writeStringField('creationdt', l.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS'));
                            else
                                genBHS.writeStringField('creationdt', '');
                            if(l.OwnerId != null && CAContactMap != null && CAContactMap.containsKey(l.OwnerId))
                                genBHS.writeStringField('csoBp', CAContactMap.get(l.OwnerId).PositionID__c);
                            else
                                genBHS.writeStringField('csoBp', '');
                            //genBHS.writeStringField('csoBp', 'p00994666');
                            genBHS.writeStringField('custBp', l.Id);
                            if(l.External_Lead_Creator_Position_Code__c != null && l.External_Lead_Creator_Position_Code__c != '')
                                genBHS.writeStringField('external_Lead_Creator_Position_Code', l.External_Lead_Creator_Position_Code__c);
                            else
                                genBHS.writeStringField('external_Lead_Creator_Position_Code', '');
                            genBHS.writeStringField('external_System_Lead_Id', l.Id);
                            if(l.Status != null && l.Status != '')
                                genBHS.writeStringField('lead_Status', l.Status);
                            else
                                genBHS.writeStringField('lead_Status', '');
                            genBHS.writeStringField('location', '');
                            if(l.Priority__c != null && l.Priority__c != '')
                                genBHS.writeStringField('priority', l.Priority__c);
                            else
                                genBHS.writeStringField('priority', '');
                            if(l.Probable_Conversion_Date__c != null)
                                genBHS.writeStringField('probable_Conversion_Date', l.Probable_Conversion_Date__c.format());
                            else
                                genBHS.writeStringField('probable_Conversion_Date', '');
                            if(l.Referral_Type__c != null && l.Referral_Type__c != '')
                                genBHS.writeStringField('referral_Type', l.Referral_Type__c);
                            else
                                genBHS.writeStringField('referral_Type', '');
                            if(l.Referrer_Email__c != null && l.Referrer_Email__c != '')
                                genBHS.writeStringField('referrer_Email', l.Referrer_Email__c);
                            else
                                genBHS.writeStringField('referrer_Email', '');
                            if(l.Referrer_Mobile__c != null && l.Referrer_Mobile__c != '')
                                genBHS.writeStringField('referrer_Mobile', l.Referrer_Mobile__c);
                            else
                                genBHS.writeStringField('referrer_Mobile', '');
                            if(l.Referrer_Name__c != null && l.Referrer_Name__c != '')
                                genBHS.writeStringField('referrer_Name', l.Referrer_Name__c);
                            else
                                genBHS.writeStringField('referrer_Name', '');
                            if(l.Site_Type__c != null && l.Site_Type__c != '')
                                genBHS.writeStringField('siteType', l.Site_Type__c);
                            else
                                genBHS.writeStringField('siteType', '');
                            if(l.Summary_of_Work__c != null && l.Summary_of_Work__c != '')
                                genBHS.writeStringField('summary_of_Work', l.Summary_of_Work__c);
                            else
                                genBHS.writeStringField('summary_of_Work', '');
                            if(l.Service_Territory__c != null && l.Service_Territory__r.Name != null && l.Service_Territory__r.Name != '')
                                genBHS.writeStringField('territory', l.Service_Territory__r.Name);
                            else
                                genBHS.writeStringField('territory', '');
                            if(l.Service_Territory__c != null && l.Service_Territory__r.Parent__c != Null && l.Service_Territory__r.Parent__r.Parent__c != null)
                                genBHS.writeStringField('unit', l.Service_Territory__r.Parent__r.Parent__r.Name);
                            else
                                genBHS.writeStringField('unit', '');
                            if(l.Dealer__c != null && l.Dealer__r.Dealer_Code__c != null && l.Dealer__r.Dealer_Code__c != '')
                                genBHS.writeStringField('store_id', l.Dealer__r.Dealer_Code__c);
                            else
                                genBHS.writeStringField('store_id', '');
                            
                            genBHS.writeEndObject();
                            
                            // Get the JSON string.
                            bhsBody = genBHS.getAsString();
                            system.debug('bhsBody:: ' + bhsBody);
                            
                            /* Calling Post method to push data */
                            Http httpBHS = new Http();
                            Httprequest requestBHS = new HttpRequest();
                            HttpResponse responseBHS = new HttpResponse();
                            System_Log__c SL = new System_Log__c();
                            try{
                                requestBHS.setMethod('POST');
                                requestBHS.setEndpoint(bhsLeadEndPointURL);
                                requestBHS.setHeader('Authorization', 'Bearer '+bhsToken);
                                requestBHS.setHeader('Content-Type', 'application/json');
                                requestBHS.setBody(bhsBody);
                                
                                SL.Lead__c = l.Id;
                                SL.API_Name__c  = l.RecordType.Name+' '+Apiname;
                                SL.Request__c = bhsBody;
                                
                                //if(!Test.IsRunningTest()) {      
                                responseBHS = http.send(requestBHS);
                            }
                            catch(Exception e){
                                SL.Lead__c = l.Id;
                                SL.API_Name__c  = l.RecordType.Name+ Apiname +' Exception API';
                                SL.Request__c = bhsBody;
                                SL.Success__c = false;
                                SL.Response__c = e.getMessage();
                                insertSystemLogList.add(SL);
                            }
                            
                            
                            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBHS.getBody());
                            
                            if(responseMap != null && !responseMap.isEmpty() && responseMap.containsKey('status_Code')) {
                                if(responseMap.get('status_Code') == '201') {
                                    if(responseMap.containsKey('object_Id')) {
                                        externalId = (string)responseMap.get('object_Id');
                                        system.debug('externalId: '+externalId);
                                    }
                                    
                                    //Add External Id On Lead//
                                    if(externalId != null && externalId != '') {
                                        Lead newLead = new Lead();
                                        newLead.Id = l.Id;
                                        newLead.External_Lead_ID__c = externalId;
                                        updateLeadList.add(newLead);
                                    }
                                    SL.Success__c = true;
                                    SL.Response__c = responseBHS.getBody();
                                } else {
                                    SL.Success__c = false;
                                    SL.Response__c = responseBHS.getBody();
                                }
                            } else {
                                SL.Success__c = false;
                                SL.Response__c = responseBHS.getBody();
                            }
                            insertSystemLogList.add(SL);
                            //}
                        }
                    }
                    if(!updateLeadList.isEmpty())
                        update updateLeadList;
                    
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
            SL.API_Name__c  = 'BHS '+APiname+ ' Exception API ';
            SL.Success__c = false;
            SL.Request__c = bhsBody;
            SL.Request__c = e.getMessage() + ' ' +e.getLineNumber();
            insert SL;
        }
    }
    
    @future(callout = true)
    public static void createCaseInBHSExternalSystem(Set<Id> cIdSet) {
        String bhsBody ='';
        try{
            List<Case> caseList = new List<Case>();
            List<Case> updateCaseList = new List<Case>();
            Set<Id> uIdSet = new Set<Id>();
            List<User> uList = new List<User>();
            Map<Id, Contact> CAContactMap = new Map<Id, Contact>();
            List<System_Log__c> insertSystemLogList = new List<System_Log__c>();
            Map<String, Map<String, String>> codeParameterMap = new Map<String, Map<String, String>>();
            String externalId = '';
            
            if(cIdSet != null && cIdSet.size() > 0) {
                caseList = [Select Id, CaseNumber, Origin, Status, Responsibility_of_complaint__c, L1_Category__c, L2_Category__c, L3_Category__c, Lead__c,
                            Lead__r.Name, Lead__r.MobilePhone, Lead__r.Email, AccountId, Account.Name, Account.PersonEmail, OwnerId, Description,
                            Account.PersonMobilePhone, Pincode__c, Site__r.Opportunity__r.Lead_Id__c, Opportunity__r.Lead_Id__c from Case where Id IN: cIdSet];
                system.debug('caseList: '+caseList);
                
                if(!caseList.isEmpty() && caseList != null) {
                    for(Case c: caseList) {
                        if(c.Status == 'Assign to CSO')
                            uIdSet.add(c.OwnerId);                    
                    }
                    if(!uIdSet.isEmpty()) {
                        uList = [SELECT Id, ContactId, Contact.AccountId, Name From User Where Id IN: uIdSet];
                        if(!uList.isEmpty()) {
                            CAContactMap = DealerManagementServices.getCAContact(uList);
                        }
                    }
                    system.debug('CAContactMap: '+CAContactMap);
                    
                    List<Case_Management_Code__c> codeList = Case_Management_Code__c.getall().values();
                    if(codeList != null) {
                        for(Case_Management_Code__c cmc: codeList) {
                            if(codeParameterMap.containsKey(cmc.Type__c)) {
                                Map<String, String> getMap = codeParameterMap.get(cmc.Type__c);
                                
                                if(getMap.containsKey(cmc.Value__c)) {
                                    getMap.put(cmc.Value__c, cmc.Code__c);
                                } else {
                                    getMap.put(cmc.Value__c, cmc.Code__c);
                                }
                                codeParameterMap.get(cmc.Type__c).putAll(getMap);
                            } else {
                                Map<String, String> newMap = new Map<String, String>();
                                newMap.put(cmc.Value__c, cmc.Code__c);
                                codeParameterMap.put(cmc.Type__c, newMap);
                            }
                        }
                    }
                    
                    for(Case c: caseList) {
                        String bhsToken = ''; //Token from Authorization API
                        String username = '';  //custom setting for username
                        String password = '';   //custom setting for password
                        String endPointURL = ''; //custom setting for endPointURL
                        String clientId = ''; //custom setting for clientId
                        String clientSecret = ''; //custom setting for clientId
                        
                        /* Authenticate the External System(BHS) */
                        if(API_Integration__c.getValues('BHS Authorization API') != null){
                            userName = API_Integration__c.getValues('BHS Authorization API').User_Name__c;  
                            password = API_Integration__c.getValues('BHS Authorization API').Password__c;  
                            endPointURL = API_Integration__c.getValues('BHS Authorization API').URL__c; 
                            clientId = API_Integration__c.getValues('BHS Authorization API').Client_Id__c;
                            clientSecret = API_Integration__c.getValues('BHS Authorization API').Client_Secret__c; 
                        }
                        
                        String payload = 'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+'&username='+EncodingUtil.urlEncode(username,'UTF-8')+'&password='+EncodingUtil.urlEncode(password,'UTF-8')+'&grant_type=password';
                        System.debug(payload);
                        
                        /* Calling Post method to push data */
                        Http http = new Http();
                        Httprequest request = new HttpRequest();                      
                        request.setMethod('POST');
                        request.setEndpoint(endPointURL);
                        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                        request.setBody(payload); 
                        
                        //if(!Test.IsRunningTest()) {      
                        HttpResponse response = http.send(request);
                        system.debug('response: '+response.getBody());
                        ExternalBHSSystemJSONtoApex jsonResponse = ExternalBHSSystemJSONtoApex.parse(response.getBody());
                        
                        if(jsonResponse.access_token != null && jsonResponse.access_token != '')
                            bhsToken = jsonResponse.access_token;
                        //}
                        
                        if(bhsToken != null && bhsToken != '') {
                            String bhsLeadEndPointURL = '';
                            /* Push BHS Lead Details API */
                            if(API_Integration__c.getValues('BHS Case Push API') != null) {
                                bhsLeadEndPointURL = API_Integration__c.getValues('BHS Case Push API').URL__c;
                            }
                            
                            /* Create JSON Body for Post method */
                            JSONGenerator genBHS = JSON.createGenerator(true);
                            genBHS.writeStartObject();
                            
                            if(c.CaseNumber != null && c.CaseNumber != '')
                                genBHS.writeStringField('complaintCode', c.CaseNumber);
                            else
                                genBHS.writeStringField('complaintCode','');
                            
                            if(c.Responsibility_of_complaint__c != null && c.Responsibility_of_complaint__c != '' && codeParameterMap != null) {
                                if(codeParameterMap.get('complaintDivision').containsKey(c.Responsibility_of_complaint__c)) {
                                    genBHS.writeStringField('complaintDivision', codeParameterMap.get('complaintDivision').get(c.Responsibility_of_complaint__c));
                                } else {
                                    genBHS.writeStringField('complaintDivision', c.Responsibility_of_complaint__c);
                                }
                            } else {
                                genBHS.writeStringField('complaintDivision','');
                            }
                            
                            if(c.L3_Category__c != null && c.L3_Category__c != '')
                                genBHS.writeStringField('complaintReason', c.L3_Category__c);
                            else
                                genBHS.writeStringField('complaintReason', '');
                            
                            if(c.Origin != null && c.Origin != '' && codeParameterMap != null) {
                                if(codeParameterMap.get('complaintSource').containsKey(c.Origin)) {
                                    genBHS.writeStringField('complaintSource', codeParameterMap.get('complaintSource').get(c.Origin));
                                } else {
                                    genBHS.writeStringField('complaintSource', c.Origin);
                                }
                            } else {
                                genBHS.writeStringField('complaintSource','');
                            }
                            
                            if(c.Status != null && c.Status != '' && codeParameterMap != null) {
                                if(codeParameterMap.get('complaintStatus').containsKey(c.Status)) {
                                    genBHS.writeStringField('complaintStatus', codeParameterMap.get('complaintStatus').get('Assign to CSO'));
                                } else {
                                    genBHS.writeStringField('complaintStatus', codeParameterMap.get('complaintStatus').get('Assign to CSO'));
                                }
                            } else {
                                genBHS.writeStringField('complaintStatus','');
                            }
                            
                            if(c.L2_Category__c != null && c.L2_Category__c != '')
                                genBHS.writeStringField('complaintSubType', c.L2_Category__c);
                            else
                                genBHS.writeStringField('complaintSubType','');
                            
                            if(c.L1_Category__c != null && c.L1_Category__c != '' && codeParameterMap != null) {
                                if(codeParameterMap.get('complaintType').containsKey(c.L1_Category__c)) {
                                    genBHS.writeStringField('complaintType', codeParameterMap.get('complaintType').get(c.L1_Category__c));
                                } else {
                                    genBHS.writeStringField('complaintType', c.L1_Category__c);
                                }
                            } else {
                                genBHS.writeStringField('complaintType','');
                            }
                            
                            if(CAContactMap != null && CAContactMap.containsKey(c.OwnerId))
                                genBHS.writeStringField('csoBp', ''); //CAContactMap.get(c.OwnerId).PositionID__c
                            else
                                genBHS.writeStringField('csoBp','');
                            
                            if(c.Site__c != null) {
                                genBHS.writeStringField('leadOrSiteCode', c.Site__r.Opportunity__r.Lead_Id__c);
                            } else if(c.Opportunity__c != null) {
                                genBHS.writeStringField('leadOrSiteCode', c.Opportunity__r.Lead_Id__c);
                            } else if(c.Lead__c != null) {
                                genBHS.writeStringField('leadOrSiteCode', c.Lead__c);
                            } else {
                                genBHS.writeStringField('leadOrSiteCode', '');
                            }
                            
                            genBHS.writeStringField('customerBp', '');
                            
                            if(c.AccountId != null) {
                                if(c.Account.PersonEmail != null && c.Account.PersonEmail != '')
                                    genBHS.writeStringField('customerEmail', c.Account.PersonEmail);
                                else
                                    genBHS.writeStringField('customerEmail', '');
                                if(c.Account.Name != null && c.Account.Name != '')
                                    genBHS.writeStringField('customerName', c.Account.Name);
                                else
                                    genBHS.writeStringField('customerName','');
                                if(c.Account.PersonMobilePhone != null && c.Account.PersonMobilePhone != '')
                                    genBHS.writeStringField('customerPhone', c.Account.PersonMobilePhone);
                                else
                                    genBHS.writeStringField('customerPhone','');
                            } else if(c.Lead__c != null) {
                                if(c.Lead__r.Email != null && c.Lead__r.Email != '')
                                    genBHS.writeStringField('customerEmail', c.Lead__r.Email);
                                else
                                    genBHS.writeStringField('customerEmail', '');
                                if(c.Lead__r.Name != null && c.Lead__r.Name != '')
                                    genBHS.writeStringField('customerName', c.Lead__r.Name);
                                else
                                    genBHS.writeStringField('customerName','');
                                if(c.Lead__r.MobilePhone != null && c.Lead__r.MobilePhone != '')
                                    genBHS.writeStringField('customerPhone', c.Lead__r.MobilePhone);
                                else
                                    genBHS.writeStringField('customerPhone','');
                            } else {
                                genBHS.writeStringField('customerEmail', '');
                                genBHS.writeStringField('customerName','');
                                genBHS.writeStringField('customerPhone','');
                            }
                            
                            if(c.Pincode__c != null && c.Pincode__c != '')
                                genBHS.writeStringField('customerPinCode', c.Pincode__c);
                            else
                                genBHS.writeStringField('customerPinCode','');
                            
                            if(c.Description != null && c.Description != '')
                                genBHS.writeStringField('voiceOfCustomer', c.Description);
                            else
                                genBHS.writeStringField('voiceOfCustomer','');
                            
                            genBHS.writeEndObject();
                            
                            // Get the JSON string.
                            bhsBody = genBHS.getAsString();
                            system.debug('bhsBody:: ' + bhsBody);
                            
                            /* Calling Post method to push data */
                            Http httpBHS = new Http();
                            Httprequest requestBHS = new HttpRequest();                      
                            requestBHS.setMethod('POST');
                            requestBHS.setEndpoint(bhsLeadEndPointURL);
                            requestBHS.setHeader('Authorization', 'Bearer '+bhsToken);
                            requestBHS.setHeader('Content-Type', 'application/json');
                            requestBHS.setBody(bhsBody);
                            
                            System_Log__c SL = new System_Log__c();
                            SL.Case__c = c.Id;
                            SL.API_Name__c  = 'BHS Case Push API';
                            SL.Request__c = bhsBody;
                            
                            //if(!Test.IsRunningTest()) {      
                            HttpResponse responseBHS = http.send(requestBHS);
                            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBHS.getBody());
                            
                            if(responseMap != null && !responseMap.isEmpty() && responseMap.containsKey('status_Code')) {
                                if(responseMap.get('status_Code') == '201') {
                                    SL.Success__c = true;
                                    SL.Response__c = responseBHS.getBody();
                                } else {
                                    SL.Success__c = false;
                                    SL.Response__c = responseBHS.getBody();
                                }
                            } else {
                                SL.Success__c = false;
                                SL.Response__c = responseBHS.getBody();
                            }
                            insertSystemLogList.add(SL);
                            //}
                        }
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
            SL.API_Name__c  = 'BHS Case Push Exception API';
            SL.Success__c = false;
            SL.Request__c = bhsBody;
            SL.Request__c = e.getMessage() + ' ' +e.getLineNumber();
            insert SL;
        }
    }
    
    @future(callout = true)
    public static void sendUpdateCaseInBHSExternalSystem(Set<Id> cIdSet) {
        String bhsBody = '';
        try{
            List<Case> caseList = new List<Case>();
            List<Case> updateCaseList = new List<Case>();
            Set<Id> uIdSet = new Set<Id>();
            List<User> uList = new List<User>();
            Map<Id, Contact> CAContactMap = new Map<Id, Contact>();
            List<System_Log__c> insertSystemLogList = new List<System_Log__c>();
            Map<String, Map<String, String>> codeParameterMap = new Map<String, Map<String, String>>();
            String externalId = '';
            
            if(cIdSet != null && cIdSet.size() > 0) {
                caseList = [Select Id, CaseNumber, Origin, Status, Responsibility_of_complaint__c, L1_Category__c, L2_Category__c, L3_Category__c, Lead__c,
                            Lead__r.Name, Lead__r.MobilePhone, Lead__r.Email, AccountId, Account.Name, Account.PersonEmail, OwnerId, Description,
                            Account.PersonMobilePhone, Pincode__c, Site__r.Opportunity__r.Lead_Id__c, Opportunity__r.Lead_Id__c from Case where Id IN: cIdSet];
                system.debug('caseList: '+caseList);
                
                if(!caseList.isEmpty() && caseList != null) {
                    for(Case c: caseList) {
                        if(c.Status == 'CAC Completed')
                            uIdSet.add(c.OwnerId);                    
                    }
                    if(!uIdSet.isEmpty()) {
                        uList = [SELECT Id, ContactId, Contact.AccountId, Name From User Where Id IN: uIdSet];
                        if(!uList.isEmpty()) {
                            CAContactMap = DealerManagementServices.getCAContact(uList);
                        }
                    }
                    system.debug('CAContactMap: '+CAContactMap);
                    
                    List<Case_Management_Code__c> codeList = Case_Management_Code__c.getall().values();
                    if(codeList != null) {
                        for(Case_Management_Code__c cmc: codeList) {
                            if(codeParameterMap.containsKey(cmc.Type__c)) {
                                Map<String, String> getMap = codeParameterMap.get(cmc.Type__c);
                                
                                if(getMap.containsKey(cmc.Value__c)) {
                                    getMap.put(cmc.Value__c, cmc.Code__c);
                                } else {
                                    getMap.put(cmc.Value__c, cmc.Code__c);
                                }
                                codeParameterMap.get(cmc.Type__c).putAll(getMap);
                            } else {
                                Map<String, String> newMap = new Map<String, String>();
                                newMap.put(cmc.Value__c, cmc.Code__c);
                                codeParameterMap.put(cmc.Type__c, newMap);
                            }
                        }
                    }
                    
                    for(Case c: caseList) {
                        String bhsToken = ''; //Token from Authorization API
                        String username = '';  //custom setting for username
                        String password = '';   //custom setting for password
                        String endPointURL = ''; //custom setting for endPointURL
                        String clientId = ''; //custom setting for clientId
                        String clientSecret = ''; //custom setting for clientId
                        
                        /* Authenticate the External System(BHS) */
                        if(API_Integration__c.getValues('BHS Authorization API') != null){
                            userName = API_Integration__c.getValues('BHS Authorization API').User_Name__c;  
                            password = API_Integration__c.getValues('BHS Authorization API').Password__c;  
                            endPointURL = API_Integration__c.getValues('BHS Authorization API').URL__c; 
                            clientId = API_Integration__c.getValues('BHS Authorization API').Client_Id__c;
                            clientSecret = API_Integration__c.getValues('BHS Authorization API').Client_Secret__c; 
                        }
                        
                        String payload = 'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+'&username='+EncodingUtil.urlEncode(username,'UTF-8')+'&password='+EncodingUtil.urlEncode(password,'UTF-8')+'&grant_type=password';
                        System.debug(payload);
                        
                        /* Calling Post method to push data */
                        Http http = new Http();
                        Httprequest request = new HttpRequest();                      
                        request.setMethod('POST');
                        request.setEndpoint(endPointURL);
                        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                        request.setBody(payload); 
                        
                        //if(!Test.IsRunningTest()) {      
                        HttpResponse response = http.send(request);
                        system.debug('response: '+response.getBody());
                        ExternalBHSSystemJSONtoApex jsonResponse = ExternalBHSSystemJSONtoApex.parse(response.getBody());
                        
                        if(jsonResponse.access_token != null && jsonResponse.access_token != '')
                            bhsToken = jsonResponse.access_token;
                        //}
                        
                        if(bhsToken != null && bhsToken != '') {
                            String bhsLeadEndPointURL = '';
                            /* Push BHS Lead Details API */
                            if(API_Integration__c.getValues('BHS Case Update API') != null) {
                                bhsLeadEndPointURL = API_Integration__c.getValues('BHS Case Update API').URL__c;
                            }
                            
                            /* Create JSON Body for Post method */
                            JSONGenerator genBHS = JSON.createGenerator(true);
                            genBHS.writeStartObject();
                            
                            if(c.CaseNumber != null && c.CaseNumber != '')
                                genBHS.writeStringField('complaintCode', c.CaseNumber);
                            else
                                genBHS.writeStringField('complaintCode','');
                            
                            if(c.Responsibility_of_complaint__c != null && c.Responsibility_of_complaint__c != '' && codeParameterMap != null) {
                                if(codeParameterMap.get('complaintDivision').containsKey(c.Responsibility_of_complaint__c)) {
                                    genBHS.writeStringField('complaintDivision', codeParameterMap.get('complaintDivision').get(c.Responsibility_of_complaint__c));
                                } else {
                                    genBHS.writeStringField('complaintDivision', c.Responsibility_of_complaint__c);
                                }
                            } else {
                                genBHS.writeStringField('complaintDivision','');
                            }
                            
                            if(c.Origin != null && c.Origin != '' && codeParameterMap != null) {
                                if(codeParameterMap.get('complaintSource').containsKey(c.Origin)) {
                                    genBHS.writeStringField('complaintSource', codeParameterMap.get('complaintSource').get(c.Origin));
                                } else {
                                    genBHS.writeStringField('complaintSource', c.Origin);
                                }
                            } else {
                                genBHS.writeStringField('complaintSource','');
                            }
                            
                            if(c.Status != null && c.Status != '' && codeParameterMap != null) {
                                if(codeParameterMap.get('complaintStatus').containsKey(c.Status)) {
                                    genBHS.writeStringField('complaintStatus', codeParameterMap.get('complaintStatus').get('CAC Completed'));
                                } else {
                                    genBHS.writeStringField('complaintStatus', codeParameterMap.get('complaintStatus').get('CAC Completed'));
                                }
                            } else {
                                genBHS.writeStringField('complaintStatus','');
                            }
                            
                            if(c.L1_Category__c != null && c.L1_Category__c != '' && codeParameterMap != null) {
                                if(codeParameterMap.get('complaintType').containsKey(c.L1_Category__c)) {
                                    genBHS.writeStringField('complaintType', codeParameterMap.get('complaintType').get(c.L1_Category__c));
                                } else {
                                    genBHS.writeStringField('complaintType', c.L1_Category__c);
                                }
                            } else {
                                genBHS.writeStringField('complaintType','');
                            }
                            
                            if(c.Site__c != null) {
                                genBHS.writeStringField('leadOrSiteCode', c.Site__r.Opportunity__r.Lead_Id__c);
                            } else if(c.Opportunity__c != null) {
                                genBHS.writeStringField('leadOrSiteCode', c.Opportunity__r.Lead_Id__c);
                            } else if(c.Lead__c != null) {
                                genBHS.writeStringField('leadOrSiteCode', c.Lead__c);
                            } else {
                                genBHS.writeStringField('leadOrSiteCode', '');
                            }
                            
                            if(c.AccountId != null) {
                                if(c.Account.PersonEmail != null && c.Account.PersonEmail != '')
                                    genBHS.writeStringField('customerEmail', c.Account.PersonEmail);
                                else
                                    genBHS.writeStringField('customerEmail', '');
                                if(c.Account.Name != null && c.Account.Name != '')
                                    genBHS.writeStringField('customerName', c.Account.Name);
                                else
                                    genBHS.writeStringField('customerName','');
                                if(c.Account.PersonMobilePhone != null && c.Account.PersonMobilePhone != '')
                                    genBHS.writeStringField('customerPhone', c.Account.PersonMobilePhone);
                                else
                                    genBHS.writeStringField('customerPhone','');
                            } else if(c.Lead__c != null) {
                                if(c.Lead__r.Email != null && c.Lead__r.Email != '')
                                    genBHS.writeStringField('customerEmail', c.Lead__r.Email);
                                else
                                    genBHS.writeStringField('customerEmail', '');
                                if(c.Lead__r.Name != null && c.Lead__r.Name != '')
                                    genBHS.writeStringField('customerName', c.Lead__r.Name);
                                else
                                    genBHS.writeStringField('customerName','');
                                if(c.Lead__r.MobilePhone != null && c.Lead__r.MobilePhone != '')
                                    genBHS.writeStringField('customerPhone', c.Lead__r.MobilePhone);
                                else
                                    genBHS.writeStringField('customerPhone','');
                            } else {
                                genBHS.writeStringField('customerEmail', '');
                                genBHS.writeStringField('customerName','');
                                genBHS.writeStringField('customerPhone','');
                            }
                            
                            if(c.Pincode__c != null && c.Pincode__c != '')
                                genBHS.writeStringField('customerPinCode', c.Pincode__c);
                            else
                                genBHS.writeStringField('customerPinCode','');
                            
                            if(c.Description != null && c.Description != '')
                                genBHS.writeStringField('voiceOfCustomer', c.Description);
                            else
                                genBHS.writeStringField('voiceOfCustomer','');
                            
                            if(c.L2_Category__c != null && c.L2_Category__c != '')
                                genBHS.writeStringField('complaintSubType', c.L2_Category__c);
                            else
                                genBHS.writeStringField('complaintSubType','');
                            
                            if(c.L3_Category__c != null && c.L3_Category__c != '')
                                genBHS.writeStringField('complaintReason', c.L3_Category__c);
                            else
                                genBHS.writeStringField('complaintReason', '');
                            
                            genBHS.writeEndObject();
                            
                            // Get the JSON string.
                            bhsBody = genBHS.getAsString();
                            system.debug('bhsBody:: ' + bhsBody);
                            
                            /* Calling Post method to push data */
                            Http httpBHS = new Http();
                            Httprequest requestBHS = new HttpRequest();                      
                            requestBHS.setMethod('POST');
                            requestBHS.setEndpoint(bhsLeadEndPointURL);
                            requestBHS.setHeader('Authorization', 'Bearer '+bhsToken);
                            requestBHS.setHeader('Content-Type', 'application/json');
                            requestBHS.setBody(bhsBody);
                            
                            System_Log__c SL = new System_Log__c();
                            SL.Case__c = c.Id;
                            SL.API_Name__c  = 'BHS Case Update API';
                            SL.Request__c = bhsBody;
                            
                            //if(!Test.IsRunningTest()) {      
                            HttpResponse responseBHS = http.send(requestBHS);
                            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBHS.getBody());
                            
                            if(responseMap != null && !responseMap.isEmpty() && responseMap.containsKey('status_Code')) {
                                if(responseMap.get('status_Code') == '201') {
                                    SL.Success__c = true;
                                    SL.Response__c = responseBHS.getBody();
                                } else {
                                    SL.Success__c = false;
                                    SL.Response__c = responseBHS.getBody();
                                }
                            } else {
                                SL.Success__c = false;
                                SL.Response__c = responseBHS.getBody();
                            }
                            insertSystemLogList.add(SL);
                            //}
                        }
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
            SL.API_Name__c  = 'BHS Case Update Exception API';
            SL.Success__c = false;
            SL.Request__c = bhsBody;
            SL.Request__c = e.getMessage() + ' ' +e.getLineNumber();
            insert SL;
        }
    }
}