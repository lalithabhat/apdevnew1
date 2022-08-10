@RestResource(urlMapping='/Lead/*')
global class REST_WebToLead {
    @HttpPOST
    global static REST_result LeadDetails(REST_Request req) {
        REST_result r = new REST_result();
        List<Lead> leadList = new List<Lead>();
        List<Lead> localLeadList = new List<Lead>();
        Map<Id, String> leadValidationMap = new Map<Id, String>();
        
        if(!String.isBlank(req.Lead_Status) && req.Lead_Status.equalsIgnoreCase('Allocation Done') && String.isBlank(req.External_Lead_Creator_Position_Code)) {
            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
            if(isEnabled[0].Enable_Logs__c){
                System_Log__c SL = new System_Log__c();
                //SL.Lead__c = CRMLeadID;
                SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                SL.Request__c = JSON.serialize(req);
                SL.Success__c = false;
                insert SL;
            }
            r.returnCode = 400;
            r.message = 'Please Provide External Lead Creator Position Code.';
            return r;
        } 
        else if(req.clickToAction == 'Visit' && req.visitDate == null){
            r.returnCode = 400;
            r.message = 'Please Provide Visit Date.';
            return r;
        }
        else {
            Lead l = new Lead();
            l.FirstName = req.C_FirstName;
            l.LastName = req.C_LastName;
            l.MobilePhone = req.C_Mobile;
            if(req.C_Email != null && req.C_Email != '' && req.C_Email != 'null')
            	l.Email = req.C_Email;
            l.Pincode__c = req.C_Pincode;
            if(!String.isBlank(req.C_WhatsappNotification) && (req.C_WhatsappNotification.equalsIgnoreCase('True') || req.C_WhatsappNotification.equalsIgnoreCase('Y'))) {
                l.Whatsapp_Notification__c = true;
                l.Consent_for_Whatsapp__c = true;
            }
            l.Status = 'Allocation Done';
            
            if(!String.isBlank(req.C_CampaignId)) {
                l.Campaign_Code__c = req.C_CampaignId;
                CampaignManagementServices.AssignCampaignInfoToLead(l);
            }
            if(!String.isBlank(req.C_IntegrationSource)) {
                if(req.C_IntegrationSource.equalsIgnoreCase('Web')){
                    l.Is_Digital__c = true;    
                } else if(req.C_IntegrationSource.equalsIgnoreCase('C4C')) {
                    l.Is_Digital__c = true;
                } else if(req.C_IntegrationSource.equalsIgnoreCase('ColourWithAP')) {
                    l.Is_Digital__c = true;
                } else if(req.C_IntegrationSource.equalsIgnoreCase('SPS')) {
                    l.Is_Local__c = true;
                } else if(req.C_IntegrationSource.equalsIgnoreCase('BHS')) {
                    l.Is_Local__c = true;
                    l.Is_Allow_Duplicates__c = true;
                } else if(req.C_IntegrationSource.equalsIgnoreCase('SLEEK')) {
                    l.Is_Local__c = true;
                    l.Is_Allow_Duplicates__c = true;
                } else if(req.C_IntegrationSource.equalsIgnoreCase('BH Store')) {
                    l.Is_Local__c = true;
                    l.Is_Allow_Duplicates__c = true;
                } else {
                    l.Is_Digital__c = true;
                }
                if(!String.isBlank(req.C_Service)) {
                    system.debug('record type-->'+req.C_Service);
                    l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get(req.C_Service).getRecordTypeId();
                    l.Skills__c = req.C_Service;
                }
            }
            /*if(!String.isBlank(req.C_IntegrationSource) && !req.C_IntegrationSource.equalsIgnoreCase('Web') && !req.C_IntegrationSource.equalsIgnoreCase('C4C')) {
                l.Is_Local__c = true; 
                if(!String.isBlank(req.C_Service)) {
                    l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get(req.C_Service).getRecordTypeId();
                    l.Skills__c = req.C_Service;
                }
            } else {
                l.Is_Digital__c = true;
            }*/
            l.UTM_Device__c = req.UTM_Device;
            l.UTM_Medium__c = req.UTM_Medium;
            l.IP_Address__c = req.ip_address;
            l.Visitor_Id__c = req.visitor_id;
            l.Page_Url__c = req.page_url;
            l.Status = req.Lead_Status;
            l.Initiator_BP__c = req.Architect_BP;
            l.Initiator_Name__c = req.Architect_Name;
            l.Initiator_Mobile__c = req.Architect_Mobile;
            l.RO_BP__c = req.External_Lead_Creator_Employee_Id;
            l.RO_Name__c = req.External_Lead_Creator_Name;
            l.RO_Mobile__c = req.External_Lead_Creator_Mobile;
            l.Firm_BP__c = req.Firm_BP;
            l.Firm_Name__c = req.Firm_Name;
            l.Firm_Mobile__c = req.Firm_Mobile;
            l.Integration_Source__c = req.C_IntegrationSource;
            if(!String.isBlank(req.C_SoA))
                l.LeadSource = req.C_SoA;
            l.House__c = req.C_House;
            l.Floor__c = req.C_Floor;
            if(!String.isBlank(req.C_Address1))
                l.Street = req.C_Address1;
            if(!String.isBlank(req.C_Address2))
                l.Street += ' '+req.C_Address2;
            l.City = req.C_City;
            l.State = req.C_State;
            l.Country = req.C_Country;
            l.Budget__c = req.C_EstimatedValue;
            l.Rating = req.Priority;
            l.Project_Type__c = req.Project_Type; 
            l.Summary_of_Work__c = req.Summary_of_Work;
            l.Description = req.C_Comments;
            l.External_System_Lead_Id__c = req.External_System_Lead_Id;
            l.External_Lead_Creator_Position_Code__c = req.External_Lead_Creator_Position_Code; //TBD
            if(!String.isBlank(req.Lead_Status) && req.Skip_Calling.equalsIgnoreCase('Y'))
                l.Skip_Calling__c = true;
            if(!String.isBlank(req.Lead_Status) && req.Lead_Status.equalsIgnoreCase('Allocation Done') && !String.isBlank(req.External_Lead_Creator_Position_Code)) {
                //l.External_Lead_Creator_Position_Code__c = req.External_Lead_Creator_Position_Code;
                List<User> userList = APIMangementServices.getUserFrom_PositionId(req.External_Lead_Creator_Position_Code);
                if(userList != null && !userList.isEmpty())
                    l.OwnerId = userList[0].Id;    
            }
            if(req.Dealer_Code != null && req.Dealer_Code != '') {
                Account dealer = DealerManagementServices.getDealer(req.Dealer_Code);
                if(dealer != null){
                  l.Dealer__c = dealer.Id;
                }
                else if(dealer == null){
                    r.returnCode = 400;
                    r.message = 'Invalid Dealer Code, Please give valid Dealer Code';
                    return r;
                }  
            }
            if(String.isBlank(req.Dealer_Code)){
                     r.returnCode = 400;
                     r.message = 'Dealer_Code should not be empty';
                     return r;
            }
            if(req.BP_Code != null && req.BP_Code != '')
                l.Current_Owner_PositionID__c = req.BP_Code;
            if(req.Referral_Type != null && req.Referral_Type != '') {
                l.Referral_Type__c = req.Referral_Type;
                l.Referrer_Name__c = req.Referrer_Name;
                l.Referrer_Mobile__c = req.Referrer_Mobile;
                l.Referrer_Email__c = req.Referrer_Email;
            }else if(req.C_SoA != null && req.C_SoA != '' && req.C_SoA.contains('Referral')){
                l.Referral_Type__c = req.Referral_Type;
                l.Referrer_Name__c = req.Referrer_Name;
                l.Referrer_Mobile__c = req.Referrer_Mobile;
                l.Referrer_Email__c = req.Referrer_Email;
            }
            if(req.Original_Lead_Id != null && req.Original_Lead_Id != '') {
                l.Cross_Sell_By__c = 'Field Team';
                l.Inter_Related_BU_1__c = req.Original_Lead_Id;
            }
            if(!String.isBlank(req.Probable_Conversion_Date))
                l.Probable_Conversion_Date__c = date.parse(req.Probable_Conversion_Date);
            l.Organization_Name__c = req.organization_name;
            l.Segment__c = req.segment;
            l.Title__c = req.title;
            l.Designation__c = req.designation;
            l.Process_Type_Web__c = req.process_type;
            l.Created_Time__c = req.created_time;
            l.Camp_Name__c = req.camp_name;
            l.Send_to_CRM__c = req.send_to_crm;
            l.Dummy_1__c = req.dummy1;
            l.Dummy_2__c = req.dummy2;
            l.Dummy_3__c = req.dummy3;
            l.BP_No__c = req.bpno;
            l.Measure_Need__c = req.measureneed;
            l.Sku_Chosen__c = req.skuchosen;
            l.Dealer_Name__c = req.dealer_name;
            l.Answer__c = req.answer;
            l.Date_Picker_Data__c = req.date_picker_data;
            l.Hybris_Id__c = req.hybris_id;
            l.Appointment_Time__c = req.appointment_time;
            l.CC_SA_BP__c = req.cc_sa_bp;
            l.Hybris_Updated__c = req.hybris_updated;
            l.Interior_Exterior__c = req.interior_exterior;
            l.No_of_Rooms__c = req.no_of_rooms;
            l.Appointment_End_Time__c = req.appointment_end_time;
            l.Sync_Hybris_Marketing__c = req.sync_hybris_marketing;
            l.Custom_Field__c = req.custom_Field;
            l.Address_1__c = req.address1;
            l.Address_2__c = req.address2;
            l.Phone = req.Phone;
            l.Click_To_Action__c = req.clickToAction;
            l.BH_Store_Visit_Date__c = req.visitDate;
            if(req.C_Service != null && req.C_Service != ''){
                l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get(req.C_Service).getRecordTypeId();
              //  l.RecordTypeId = l.RecordTypeId;
                if(req.C_Available_Product_Categories != null){
                   /* List<String> availableProd = new List<String>{'Furniture','Furnishings','Lights','Home Automation','Rugs','Madeups','Wooden Flooring','Tiles','Kitchen','BathFittings','UPVC','Paint','Sleek'};
                    List<String> selectedProd = new List<String>();
                    List<String> unavailableProd = new List<String>();*/
                    Set<String> ProductCategory = new Set<String>();
                    l.Product_Categories__c = req.C_Available_Product_Categories;
                    l.Unavailable_Product_Categories__c = req.C_Unavailable_Product_Categories;
                    ProductCategory.add(req.C_Available_Product_Categories);
                   // Boolean Pin = AP_BHStoreManagementService.isSkillSetAvailable(req.C_Pincode,ProductCategory);
                    /*if(Pin == false){
                          r.returnCode = 400;
                          r.message = leadValidationMap.get(l.Id);
                          return r;
                      }*/
                 }
                    }
            
            //lead insert and enquiry creation logic
            if (l != null) {
                if(!l.Is_Allow_Duplicates__c) {
                    leadList.add(l);
                    leadValidationMap = LeadManagementServices.validateLeadDetails(leadList);
                    system.debug('leadValidationMap: '+leadValidationMap);
                    
                    if(!leadValidationMap.isEmpty()) {
                        List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                        if(isEnabled[0].Enable_Logs__c){
                            System_Log__c SL = new System_Log__c();
                            //SL.Lead__c = CRMLeadID;
                            SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                            SL.Request__c = JSON.serialize(req);
                            SL.Response__c = leadValidationMap.get(l.Id);
                            SL.Success__c = false;
                            insert SL;
                        }
                        r.returnCode = 400;
                        r.message = leadValidationMap.get(l.Id);
                        return r;
                    } else {
                        try {
                            ServiceabilityManagement.assignBotProcessTypeonLead(leadList);
                            ServiceabilityManagement.checkLeadServiceability(leadList); 
                            List<DupResultsDTO> dupList = LeadManagementServices.leadPreprocessing(leadList, 'WEB');
                            if (dupList.isEmpty()) {
                                try {
                                    Database.DMLOptions dml = new Database.DMLOptions();
                                    dml.DuplicateRuleHeader.AllowSave = true;
                                    Database.saveResult[] srList = Database.insert(leadList, dml);
                                    for (Database.SaveResult sr: srList) {
                                        if (sr.isSuccess()) {
                                            // Operation was successful, so get the ID of the record that was processed
                                            System.debug('Successfully inserted lead. lead ID: ' + sr.getId());
                                            Lead newLead = [Select Id, RecordType.Name from Lead where Id =: sr.getId()];
                                            
                                            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                                            if(isEnabled[0].Enable_Logs__c){
                                                System_Log__c SL = new System_Log__c();
                                                SL.Lead__c = newLead.Id;
                                                SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                                                SL.Request__c = JSON.serialize(req);
                                                SL.Response__c = 'Lead record inserted successfully';
                                                SL.Success__c = true;
                                                insert SL;
                                            }
                                            
                                            r.returnCode = 201; 
                                            r.message = 'Lead record inserted successfully';
                                            r.CRMleadId = newLead.Id;
                                            r.Revised_LOB = newLead.RecordType.Name;
                                            return r;
                                        } else {
                                            // Operation failed, so get all errors  
                                            String msg = null;
                                            for (Database.Error err: sr.getErrors()) {
                                                
                                                msg = 'Lead Insert Failed : ' + err.getMessage();
                                            }
                                            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                                            if(isEnabled[0].Enable_Logs__c){
                                                System_Log__c SL = new System_Log__c();
                                                //SL.Lead__c = newLead.Id;
                                                SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                                                SL.Request__c = JSON.serialize(req);
                                                SL.Response__c = msg;
                                                SL.Success__c = false;
                                                insert SL;
                                            }
                                            r.returnCode = 400;
                                            r.message = msg;
                                            return r;
                                        }
                                    }
                                } catch (System.DmlException ex) {
                                    String msg = null;
                                    for (Integer i = 0; i < ex.getNumDml(); i++) {
                                        msg = 'Lead Insert Failed :' + ex.getMessage();
                                    }
                                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                                    if(isEnabled[0].Enable_Logs__c){
                                        System_Log__c SL = new System_Log__c();
                                        //SL.Lead__c = newLead.Id;
                                        SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                                        SL.Request__c = JSON.serialize(req);
                                        SL.Response__c = msg;
                                        SL.Success__c = false;
                                        insert SL;
                                    }
                                    system.debug('Insert failed: '+msg);
                                    r.returnCode = 400;
                                    r.message = msg;
                                    return r;
                                }
                            } else {
                                Map<boolean, String> resultMap = EnquiryManagementServices.enquiryProcessing(dupList, leadList);
                                system.debug('resultMap: '+resultMap);
                                
                                if(!resultMap.isEmpty()) {
                                    for(boolean b: resultMap.keySet()) {
                                        if(b == TRUE) {
                                            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                                            if(isEnabled[0].Enable_Logs__c){
                                                System_Log__c SL = new System_Log__c();
                                                SL.Lead__c = resultMap.get(b).substringAfter(':-');
                                                SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                                                SL.Request__c = JSON.serialize(req);
                                                SL.Response__c = resultMap.get(b).substringBefore(':-');
                                                SL.Success__c = true;
                                                insert SL;
                                            }
                                            r.returnCode = 201;
                                            r.message = resultMap.get(b).substringBefore(':-');
                                            r.CRMleadId = resultMap.get(b).substringAfter(':-');
                                            r.Revised_LOB = [Select RecordType.Name from Lead where Id = : r.CRMleadId].RecordType.Name;
                                            return r;
                                        } else {
                                            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                                            if(isEnabled[0].Enable_Logs__c){
                                                System_Log__c SL = new System_Log__c();
                                                //SL.Lead__c = resultMap.get(b).substringAfter(':-');
                                                SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                                                SL.Request__c = JSON.serialize(req);
                                                SL.Response__c = resultMap.get(b);
                                                SL.Success__c = false;
                                                insert SL;
                                            }
                                            r.returnCode = 400;
                                            r.message = resultMap.get(b);
                                            return r;
                                        }
                                    }
                                } else {
                                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                                    if(isEnabled[0].Enable_Logs__c){
                                        System_Log__c SL = new System_Log__c();
                                        //SL.Lead__c = resultMap.get(b).substringAfter(':-');
                                        SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                                        SL.Request__c = JSON.serialize(req);
                                        SL.Response__c = 'Error occured while processing request';
                                        SL.Success__c = false;
                                        insert SL;
                                    }
                                    system.debug('Result Map is Empty');
                                    r.returnCode = 400;
                                    r.message = 'Error occured while processing request';
                                    return r;
                                }
                            }
                        } catch (GlobalException g) {
                            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                            if(isEnabled[0].Enable_Logs__c){
                                System_Log__c SL = new System_Log__c();
                                //SL.Lead__c = resultMap.get(b).substringAfter(':-');
                                SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                                SL.Request__c = JSON.serialize(req);
                                SL.Response__c = 'Global Exception : ' +g.getErrorMsg()[0];
                                SL.Success__c = false;
                                insert SL;
                            }
                            System.debug('Global Exception catch: '+g.getErrorMsg()[0]);
                            r.returnCode = 400;
                            r.message = 'Global Exception : ' +g.getErrorMsg()[0];
                            return r;
                        }
                        return r;
                    }
                } else {
                    localLeadList.add(l);
                    leadValidationMap = LeadManagementServices.validateLeadDetails(localLeadList);
                    system.debug('leadValidationMap: '+leadValidationMap);
                    
                    if(!leadValidationMap.isEmpty()) {
                        List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                        if(isEnabled[0].Enable_Logs__c){
                            System_Log__c SL = new System_Log__c();
                            //SL.Lead__c = resultMap.get(b).substringAfter(':-');
                            SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                            SL.Request__c = JSON.serialize(req);
                            SL.Response__c = leadValidationMap.get(l.Id);
                            SL.Success__c = false;
                            insert SL;
                        }
                        r.returnCode = 400;
                        r.message = leadValidationMap.get(l.Id);
                        return r;
                    } else {
                        try {
                            ServiceabilityManagement.assignBotProcessTypeonLead(leadList);
                            ServiceabilityManagement.checkLeadServiceability(localLeadList);
                            Database.DMLOptions dml = new Database.DMLOptions();
                            dml.DuplicateRuleHeader.AllowSave = true;
                            Database.saveResult[] srList = Database.insert(localLeadList, dml);
                            for (Database.SaveResult sr: srList) {
                                if (sr.isSuccess()) {
                                    // Operation was successful, so get the ID of the record that was processed
                                    System.debug('Successfully inserted lead. lead ID: ' + sr.getId());
                                    Lead newLead = [Select Id, RecordType.Name from Lead where Id =: sr.getId()];
                                    
                                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                                    if(isEnabled[0].Enable_Logs__c){
                                        System_Log__c SL = new System_Log__c();
                                        SL.Lead__c = newLead.Id;
                                        SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                                        SL.Request__c = JSON.serialize(req);
                                        SL.Response__c = 'Lead record inserted successfully';
                                        SL.Success__c = true;
                                        insert SL;
                                    }
                                    r.returnCode = 201; 
                                    r.message = 'Lead record inserted successfully';
                                    r.CRMleadId = newLead.Id;
                                    r.Revised_LOB = newLead.RecordType.Name;
                                    return r;
                                } else {
                                    // Operation failed, so get all errors  
                                    String msg = null;
                                    for (Database.Error err: sr.getErrors()) {
                                        msg = 'Lead Insert Failed : ' + err.getMessage();
                                    }
                                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                                    if(isEnabled[0].Enable_Logs__c){
                                        System_Log__c SL = new System_Log__c();
                                        //SL.Lead__c = newLead.Id;
                                        SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                                        SL.Request__c = JSON.serialize(req);
                                        SL.Response__c = msg;
                                        SL.Success__c = false;
                                        insert SL;
                                    }
                                    r.returnCode = 400;
                                    r.message = msg;
                                    return r;
                                }
                            }
                        } catch (System.DmlException ex) {
                            String msg = null;
                            for (Integer i = 0; i < ex.getNumDml(); i++) {
                                msg = 'Lead Insert Failed :' + ex.getMessage();
                            }
                            system.debug('Insert failed: '+msg);
                            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                            if(isEnabled[0].Enable_Logs__c){
                                System_Log__c SL = new System_Log__c();
                                //SL.Lead__c = newLead.Id;
                                SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                                SL.Request__c = JSON.serialize(req);
                                SL.Response__c = msg;
                                SL.Success__c = false;
                                insert SL;
                            }
                            r.returnCode = 400;
                            r.message = msg;
                            return r;
                        }
                        return r;
                    }
                }
            } else {
                System.debug('Lead list empty UNKNOWN EXCEPTION:');
                List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                if(isEnabled[0].Enable_Logs__c){
                    System_Log__c SL = new System_Log__c();
                    //SL.Lead__c = newLead.Id;
                    SL.API_Name__c  = 'WebToLead API- '+req.C_IntegrationSource;
                    SL.Request__c = JSON.serialize(req);
                    SL.Response__c = 'UNKNOWN EXCEPTION';
                    SL.Success__c = false;
                    insert SL;
                }
                r.returnCode = 400;
                r.message = 'UNKNOWN EXCEPTION';
                return r;
            }
        }
    }
    
    global class REST_result {
        webservice Integer returnCode;
        webservice String message;
        webservice String CRMleadId;
        webservice String Revised_LOB;
    }
    global class REST_Request {
        webservice String C_FirstName;
        webservice String C_LastName;
        webservice String C_Mobile;
        webservice String C_Email;
        webservice String C_Pincode;
        webservice String C_WhatsappNotification;
        webservice String C_CampaignId;
        webservice String C_Comments;
        webservice String Lead_Status;
        webservice String C_SoA;
        webservice String C_IntegrationSource;
        webservice String C_House;
        webservice String C_Floor;
        webservice String C_Address1;
        webservice String C_Address2;
        webservice String C_City;
        webservice String C_State;
        webservice String C_Country;
        webservice String C_EstimatedValue;
        webservice String C_Service;
        webservice String Priority;
        webservice String Architect_BP;
        webservice String Architect_Name;
        webservice String Architect_Mobile;
        webservice String External_Lead_Creator_Position_Code;
        webservice String External_Lead_Creator_Employee_Id;
        webservice String External_Lead_Creator_Name;
        webservice String External_Lead_Creator_Mobile;
        webservice String Firm_Name;
        webservice String Firm_BP;
        webservice String Firm_Mobile;
        webservice String Dealer_Code;
        webservice String BP_Code;
        webservice String Original_Lead_Id;
        webservice String Referral_Type;
        webservice String Referrer_Name;
        webservice String Referrer_Mobile;
        webservice String Referrer_Email;
        webservice String Probable_Conversion_Date; //format should be mm/dd/yyyy
        webservice String Summary_of_Work;
        webservice String Project_Type;
        webservice String Skip_Calling;
        webservice String utm_device;
        webservice String utm_medium;
        webservice String ip_address;
        webservice String visitor_id;
        webservice String page_url;
        webservice String External_System_Lead_Id;
        webservice String organization_name;
        webservice String segment;
        webservice String title;
        webservice String designation;
        webservice String process_type;
        webservice String created_time;
        webservice String camp_name;
        webservice String send_to_crm;
        webservice String dummy1;
        webservice String dummy2;
        webservice String dummy3;
        webservice String bpno;
        webservice String measureneed;
        webservice String skuchosen;
        webservice String dealer_name;
       // webservice String Dealer_Code;
        webservice String answer;
        webservice String date_picker_data;
        webservice String hybris_id;
        webservice String appointment_time;
        webservice String cc_sa_bp;
        webservice String hybris_updated;
        webservice String interior_exterior;
        webservice String no_of_rooms;
        webservice String appointment_end_time;
        webservice String sync_hybris_marketing;
        webservice String custom_Field;
        webservice String address1;
        webservice String address2;
        webservice String phone;
        webservice String utm_source;
        webservice String utm_campaign;
        webservice String clickToAction;
        webservice Date visitDate;
        webservice String C_Available_Product_Categories;
        webservice String C_Unavailable_Product_Categories;
    }
}