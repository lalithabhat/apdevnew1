public class EnquiryManagementServices {
    public static String className = EnquiryManagementServices.class.getName();
    public static Map<Boolean, String> enquiryProcessing (List <DupResultsDTO> dupList, List<Lead> incomingLeadList) {
        Map<Boolean, String> resultMap = new Map<Boolean, String>();
        String msg = '';
        Set<Id> leadId = new Set<Id>();
        Set<Id> accountId = new Set<Id>();
        List<Lead> lList = new List<Lead>();
        List<Lead> updateLeadList = new List<Lead>();
        
        for(DupResultsDTO d: dupList) {
            for(String key: d.duplicatesMap.keySet()) {
                if(key == 'Account') {
                    system.debug('In Duplicate Account: '+d.duplicatesMap.get(Key));
                    accountId = d.duplicatesMap.get(Key);
                }
                if(key == 'Lead') {
                    system.debug('In Duplicate Lead: '+d.duplicatesMap.get(Key));
                    leadId= d.duplicatesMap.get(Key);
                }
            }
        }
        
        if(!accountId.isEmpty()) {
            //Duplicate Account Present.
            //Get Original Lead Record Type Name
            String recordTypeName = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosById().get(incomingLeadList[0].RecordTypeId).getName();
            system.debug('recordTypeName: '+recordTypeName);
            
            if(!leadId.isEmpty()) {
                lList = [Select Id, Name, MobilePhone, Email, Campaign_Code__c from Lead 
                         where Id IN: leadId AND RecordType.Name =: recordTypeName AND isConverted = false AND Active__c = true];
                system.debug('leadList: '+lList);
                
                if(!lList.isEmpty()) {
                    // Tag Campaign Information
                    for(Lead l: lList) {
                        l.Campaign_Code__c = incomingLeadList[0].Campaign_Code__c;
                        updateLeadList.add(l);
                    }
                    
                    if (!updateLeadList.isEmpty()) {
                        try {
                            Database.SaveResult[] srList = Database.update(updateLeadList, true);
                            for (Database.SaveResult sr: srList) {
                                if (sr.isSuccess()) {
                                    // Operation was successful, so get the ID of the record that was processed
                                    System.debug('Successfully updated lead. Lead ID: ' + sr.getId());
                                } else {
                                    // Operation failed, so get all errors  
                                    List<String> customMsgList = new List<String>();
                                    for (Database.Error err: sr.getErrors()) {
                                        msg = 'Lead Update Failed :' + err.getMessage();
                                        customMsgList.add(msg);
                                    }
                                    throw new GlobalException(customMsgList, '', 'enquiryProcessing');
                                }
                            }
                        } catch (System.DmlException ex) {
                            List<String> customMsgList = new List<String>();
                            for (Integer i = 0; i < ex.getNumDml(); i++) {
                                msg = 'Lead Update Failed :' + ex.getMessage();
                                customMsgList.add(msg);
                            }
                            System.debug('global exception:' + customMsgList);
                            throw new GlobalException(customMsgList, '', 'enquiryProcessing');
                        }
                    }
                    
                    // Create Enquiry
                    try {
                        system.debug('lList-->'+lList[0].Id);
                        system.debug('incomingLeadList-->'+incomingLeadList[0]);
                        Map<Id,Lead> enquiryMap = new Map<Id,Lead>();
                        enquiryMap.put(lList[0].Id, incomingLeadList[0]);
                        Map<Id,Enquiry__c> whoIdMap = new Map<Id,Enquiry__c>();
                        whoIdMap = createTaskforEnquiries(enquiryMap);
                        
                        msg = 'New Enquiry Cretated Against Existing Lead:-'+lList[0].Id;
                        resultMap.put(True, msg);
                    } catch(Exception ex) {
                        msg = ex.getMessage();
                        resultMap.put(FALSE, msg);
                        System.debug('Catch and Ignore enquiry task create exception:' + ex.getMessage());
                    }
                } else {
                    // Create Lead
                    resultMap = createLead(incomingLeadList);
                }
            } else {
                //Create Lead
                resultMap = createLead(incomingLeadList);
            }
        } else if(!leadId.isEmpty()) {
            //Duplicate Lead Present.
            //Get Original Lead Record Type Name
            String recordTypeName = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosById().get(incomingLeadList[0].RecordTypeId).getName();
            system.debug('recordTypeName: '+recordTypeName);
            
            lList = [Select Id, Name, MobilePhone, Email, Campaign_Code__c from Lead 
                     where Id IN: leadId AND RecordType.Name =: recordTypeName AND isConverted = false AND Active__c = true];
            system.debug('leadList: '+lList);
            
            if(!lList.isEmpty()) {
                // Tag Campaign Information
                for(Lead l: lList) {
                    l.Campaign_Code__c = incomingLeadList[0].Campaign_Code__c;
                    updateLeadList.add(l);
                }
                
                if (!updateLeadList.isEmpty()) {
                    try {
                        Database.SaveResult[] srList = Database.update(updateLeadList, true);
                        for (Database.SaveResult sr: srList) {
                            if (sr.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully updated lead. Lead ID: ' + sr.getId());
                            } else {
                                // Operation failed, so get all errors  
                                List<String> customMsgList = new List<String>();
                                for (Database.Error err: sr.getErrors()) {
                                    msg = 'Lead Update Failed :' + err.getMessage();
                                    customMsgList.add(msg);
                                }
                                throw new GlobalException(customMsgList, '', 'enquiryProcessing');
                            }
                        }
                    } catch (System.DmlException ex) {
                        List<String> customMsgList = new List<String>();
                        for (Integer i = 0; i < ex.getNumDml(); i++) {
                            msg = 'Lead Update Failed :' + ex.getMessage();
                            customMsgList.add(msg);
                        }
                        System.debug('global exception:' + customMsgList);
                        throw new GlobalException(customMsgList, '', 'enquiryProcessing');
                    }
                }
                
                // Create Enquiry
                try {
                    Map<Id,Lead> enquiryMap = new Map<Id,Lead>();
                    enquiryMap.put(lList[0].Id, incomingLeadList[0]);
                    Map<Id,Enquiry__c> whoIdMap = new Map<Id,Enquiry__c>();
                    whoIdMap = createTaskforEnquiries(enquiryMap);
                    
                    msg = 'New Enquiry Cretated Against Existing Lead:-'+lList[0].Id;
                    resultMap.put(True, msg);
                } catch(Exception ex) {
                    msg = ex.getMessage();
                    resultMap.put(FALSE, msg);
                    System.debug('Catch and Ignore enquiry task create exception:' + ex.getMessage());
                }
            } else {
                // Create Lead
                resultMap = createLead(incomingLeadList);
            }
        } else {
            system.debug('Error: Duplicate Lead & Account Not Present.');
        }
        return resultMap;
    }
    
    public static Map<Boolean, String> createLead(List<Lead> incomingLeadList) {
        Map<Boolean, String> resultMap = new Map<Boolean, String>();
        String msg = '';
        
        try {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.saveResult[] srList = Database.insert(incomingLeadList, dml);
            //Database.saveResult[] srList = Database.insert(incomingLeadList, true);
            for (Database.SaveResult sr: srList) {
                if (sr.isSuccess()) {
                    msg = 'Lead record inserted successfully:-'+sr.getId();
                    resultMap.put(True, msg);
                } else {
                    msg = null;
                    for (Database.Error err: sr.getErrors()) {
                        msg = 'Lead Insert Failed :' + err.getMessage();
                    }
                    resultMap.put(FALSE, msg);
                }
            }
        } catch (System.DmlException ex) {
            msg = null;
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                msg = 'Lead Insert Failed :' + ex.getMessage();
            }
            System.debug('Error:' + msg);
            resultMap.put(FALSE, msg);
        }
        system.debug('resultMap: '+resultMap);
        return resultMap;
    }
    
    public static Map<Id, Enquiry__c> createTaskforEnquiries(Map<Id, Lead> enquiriesMap) {
        List<Enquiry__c> retEnquiryList = new List <Enquiry__c>();
        List<Id> enquiryIds = new List <Id>();
        Map<Id, Enquiry__c> taskWhoIdMap = new Map<Id, Enquiry__c>();
        List<Enquiry__c> enquiryList = new List<Enquiry__c>();
        
        if(!enquiriesMap.isEmpty()) {
            for(Id wId: enquiriesMap.keyset()) {
                Enquiry__c eq = new Enquiry__c();
                if(String.isNotBlank(enquiriesMap.get(wId).FirstName))
                    eq.Customer_Name__c = (enquiriesMap.get(wId).FirstName) + ' ';
                else
                    eq.Customer_Name__c = '';
                if(String.isNotBlank(enquiriesMap.get(wId).LastName))
                    eq.Customer_Name__c += (enquiriesMap.get(wId).LastName);
                if(String.isNotBlank(enquiriesMap.get(wId).Email))
                    eq.Email__c = (enquiriesMap.get(wId).Email);
                if(String.isNotBlank(enquiriesMap.get(wId).MobilePhone))
                    eq.Mobile__c = (enquiriesMap.get(wId).MobilePhone);
                if(String.isNotBlank(enquiriesMap.get(wId).CampaignName__c))
                    eq.Campaign__c = (enquiriesMap.get(wId).CampaignName__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Pincode__c))
                    eq.Pincode__c = (enquiriesMap.get(wId).Pincode__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Campaign_Code__c))
                    eq.Campaign_Code__c = (enquiriesMap.get(wId).Campaign_Code__c);
                if(String.isNotBlank(enquiriesMap.get(wId).UTM_Device__c))
                    eq.UTM_Device__c = (enquiriesMap.get(wId).UTM_Device__c);
                if(String.isNotBlank(enquiriesMap.get(wId).UTM_Medium__c))
                    eq.UTM_Medium__c = (enquiriesMap.get(wId).UTM_Medium__c);
                if(String.isNotBlank(enquiriesMap.get(wId).IP_Address__c))
                    eq.IP_Address__c = (enquiriesMap.get(wId).IP_Address__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Visitor_Id__c))
                    eq.Visitor_Id__c = (enquiriesMap.get(wId).Visitor_Id__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Page_Url__c))
                    eq.Page_Url__c = (enquiriesMap.get(wId).Page_Url__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Initiator_BP__c))
                    eq.Initiator_BP__c = (enquiriesMap.get(wId).Initiator_BP__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Initiator_Name__c))
                    eq.Initiator_Name__c = (enquiriesMap.get(wId).Initiator_Name__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Initiator_Mobile__c))
                    eq.Initiator_Mobile__c = (enquiriesMap.get(wId).Initiator_Mobile__c);
                if(String.isNotBlank(enquiriesMap.get(wId).RO_BP__c))
                    eq.RO_BP__c = (enquiriesMap.get(wId).RO_BP__c);
                if(String.isNotBlank(enquiriesMap.get(wId).RO_Name__c))
                    eq.RO_Name__c = (enquiriesMap.get(wId).RO_Name__c);
                if(String.isNotBlank(enquiriesMap.get(wId).RO_Mobile__c))
                    eq.RO_Mobile__c = (enquiriesMap.get(wId).RO_Mobile__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Firm_BP__c))
                    eq.Firm_BP__c = (enquiriesMap.get(wId).Firm_BP__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Firm_Name__c))
                    eq.Firm_Name__c = (enquiriesMap.get(wId).Firm_Name__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Firm_Mobile__c))
                    eq.Firm_Mobile__c = (enquiriesMap.get(wId).Firm_Mobile__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Integration_Source__c))
                    eq.Integration_Source__c = (enquiriesMap.get(wId).Integration_Source__c);
                if(String.isNotBlank(enquiriesMap.get(wId).House__c))
                    eq.House__c = (enquiriesMap.get(wId).House__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Floor__c))
                    eq.Floor__c = (enquiriesMap.get(wId).Floor__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Budget__c))
                    eq.Budget__c = (enquiriesMap.get(wId).Budget__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Priority__c))
                    eq.Priority__c = (enquiriesMap.get(wId).Priority__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Project_Type__c))
                    eq.Project_Type__c = (enquiriesMap.get(wId).Project_Type__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Summary_of_Work__c))
                    eq.Summary_of_Work__c = (enquiriesMap.get(wId).Summary_of_Work__c);
                if(String.isNotBlank(enquiriesMap.get(wId).External_System_Lead_Id__c))
                    eq.External_System_Lead_Id__c = (enquiriesMap.get(wId).External_System_Lead_Id__c);
                eq.Skip_Calling__c = (enquiriesMap.get(wId).Skip_Calling__c);
                if(String.isNotBlank(enquiriesMap.get(wId).External_Lead_Creator_Position_Code__c))
                    eq.External_Lead_Creator_Position_Code__c = (enquiriesMap.get(wId).External_Lead_Creator_Position_Code__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Dealer__c))
                    eq.Dealer__c = (enquiriesMap.get(wId).Dealer__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Current_Owner_PositionID__c))
                    eq.Current_Owner_PositionID__c = (enquiriesMap.get(wId).Current_Owner_PositionID__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Referral_Type__c))
                    eq.Referral_Type__c = (enquiriesMap.get(wId).Referral_Type__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Referrer_Name__c))
                    eq.Referrer_Name__c = (enquiriesMap.get(wId).Referrer_Name__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Referrer_Mobile__c))
                    eq.Referrer_Mobile__c = (enquiriesMap.get(wId).Referrer_Mobile__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Referrer_Email__c))
                    eq.Referrer_Email__c = (enquiriesMap.get(wId).Referrer_Email__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Cross_Sell_By__c))
                    eq.Cross_Sell_By__c = (enquiriesMap.get(wId).Cross_Sell_By__c);
                if(String.isNotBlank(enquiriesMap.get(wId).Inter_Related_BU_1__c))
                    eq.Inter_Related_BU_1__c = (enquiriesMap.get(wId).Inter_Related_BU_1__c);
                if(enquiriesMap.get(wId).Probable_Conversion_Date__c != null)
                    eq.Probable_Conversion_Date__c = (enquiriesMap.get(wId).Probable_Conversion_Date__c);
                if(String.isNotBlank(enquiriesMap.get(wId).LeadSource))
                    eq.LeadSource__c = (enquiriesMap.get(wId).LeadSource);
                if(String.isNotBlank(enquiriesMap.get(wId).Skills__c))
                    eq.Skills__c = (enquiriesMap.get(wId).Skills__c);
                if((enquiriesMap.get(wId).Whatsapp_Notification__c !=NULL))
                    eq.Whatsapp_Notification__c = (enquiriesMap.get(wId).Whatsapp_Notification__c);
                
                if(wId.getSObjectType().getDescribe().getName() == 'Lead') {
                    eq.Lead__c = wId;
                    eq.Service__c = Schema.SObjectType.Lead.getRecordTypeInfosById().get(enquiriesMap.get(wId).RecordTypeId).getName();
                }
                enquiryList.add(eq);
                system.debug('enquiryList-->'+enquiryList);
            }
            
            try {
                Database.SaveResult[] srList = Database.insert(enquiryList, true);
                // Iterate through each returned result

                for(Database.SaveResult sr: srList) {
                    if(sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        enquiryIds.add(sr.getId());
                    } else {
                        // Operation failed, so get all errors  
                        List < String > customMsgList = new List < String > ();
                        for(Database.Error err: sr.getErrors()) {
                            String msg = 'Task Insert Failed :' + err.getMessage();
                            customMsgList.add(msg);
                        }
                        throw new GlobalException(customMsgList, '', className);
                    }
                }

                if(!enquiryIds.isEmpty()) {
                    retEnquiryList = [SELECT Id, Lead__c, Customer_Name__c, Mobile__c, Email__c from Enquiry__c where Id IN: enquiryIds];
                }

                for(Enquiry__c eq: retEnquiryList) {
                    taskWhoIdMap.put(eq.Lead__c, eq);
                }

            } catch (System.DmlException ex) {
                List < String > customMsgList = new List < String > ();
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    String msg = 'Task Insert Failed :' + ex.getMessage();
                    customMsgList.add(msg);
                }
                throw new GlobalException(customMsgList, '', className);
            }
        }
        return taskWhoIdMap;
    }
    
    public static Map<Boolean, String> leadProcessingBot(List<DupResultsDTO> dupList, List<Lead> leadList) {
    	Map<Boolean, String> resultMap = new Map<Boolean, String>();
        List<Lead> lList = new List<Lead>();
        Set<Id> leadId = new Set<Id>();
        Set<Id> accountId = new Set<Id>();
        
        for(DupResultsDTO d: dupList) {
            for(String key: d.duplicatesMap.keySet()) {
                if(key == 'Account') {
                    accountId = d.duplicatesMap.get(Key);
                }
                if(key == 'Lead') {
                    leadId = d.duplicatesMap.get(Key); 
                }
            }
        }
        
        if(!accountId.isEmpty()) {
            //Get Original Lead Record Type Name
            String recordTypeName = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosById().get(leadList[0].RecordTypeId).getName();
            system.debug('recordTypeName: '+recordTypeName);
            
            if(!leadId.isEmpty()) {
                lList = [Select Id, Name, MobilePhone, Email from Lead 
                         where Id IN: leadId AND RecordType.Name =: recordTypeName AND isConverted = false AND Active__c = true];
                system.debug('leadList: '+lList);
                
                if(!lList.isEmpty()) {
                    resultMap.put(FALSE, lList[0].Id);
                } else {
                    resultMap.put(TRUE, 'SUCCESS');
                }
            } else {
                resultMap.put(TRUE, 'SUCCESS');
            }
        } else if(!leadId.isEmpty()) {
            //Get Original Lead Record Type Name
            String recordTypeName = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosById().get(leadList[0].RecordTypeId).getName();
            system.debug('recordTypeName: '+recordTypeName);
            
            lList = [Select Id, Name, LastName, MobilePhone, Email from Lead 
                     where Id IN: leadId AND RecordType.Name =: recordTypeName AND isConverted = false AND Active__c = true];
            system.debug('lList : '+lList );
            
            if(!lList.isEmpty()) {
                resultMap.put(FALSE, lList[0].Id);
            } else {
                resultMap.put(TRUE, 'SUCCESS');
            }
        } else {
            resultMap.put(TRUE, 'SUCCESS');
            system.debug('Error: Duplicate Lead & Account Not Present.');
        }
        return resultMap;
    }
    
    public static Map<Boolean, String> leadProcessing(List <DupResultsDTO> dupList, List<Lead> originalLeadList, String ObjectType) {
        Map<Boolean, String> resultMap = new Map<Boolean, String>();
        Set<Id> leadId = new Set<Id>();
        Set<Id> accountId = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Lead> lList = new List<Lead>();
        
        for(DupResultsDTO d: dupList) {
            for(String key: d.duplicatesMap.keySet()) {
                if(key == 'Account') {
                    system.debug('In Duplicate Account: '+d.duplicatesMap.get(Key));
                    accountId = d.duplicatesMap.get(Key);
                }
                if(key == 'Lead') {
                    system.debug('In Duplicate Lead: '+d.duplicatesMap.get(Key));
                    leadId = d.duplicatesMap.get(Key); 
                }
            }
        }
        
        if(!accountId.isEmpty()) {
            if(ObjectType == 'Lead') {
                //Get Original Lead Record Type Name
                String recordTypeName = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosById().get(originalLeadList[0].RecordTypeId).getName();
                system.debug('recordTypeName: '+recordTypeName);
                
                //Inter Related Account Tagging on Original Lead//
                /*if(ExecutionType == 'Insert') {
                    for(Id aId: accountId) {
                        if(originalLeadList[0].Inter_Related_Account__c == null)
                            originalLeadList[0].Inter_Related_Account__c = aId;
                    }
                }*/
                //Inter Related Account Tagging on Original Lead//
                
                /*oppList = [Select Id, Name, AccountId, StageName, Is_Active__c from Opportunity 
                           where AccountId =: accountId  AND RecordType.Name =: recordTypeName
                           ORDER BY CreatedDate ASC];
                system.debug('Opportunity List: '+oppList);
                
                if(!oppList.isEmpty()) {
                    //Inter Related Opportunity Tagging on Original Lead//
                    if(ExecutionType == 'Insert') {
                        for(Opportunity op: oppList) {
                            if(op.Is_Active__c == true)
                                originalLeadList[0].Inter_Related_Opportunity__c = op.Id;
                        }
                    }
                    //Inter Related Opportunity Tagging on Original Lead//
                }*/
                
                if(!leadId.isEmpty()) {
                    lList = [Select Id, Name, MobilePhone, Email from Lead 
                             where Id IN: leadId AND RecordType.Name =: recordTypeName AND isConverted = false AND Active__c = true];
                    system.debug('leadList: '+lList);
                    
                    if(!lList.isEmpty()) {
                        resultMap.put(FALSE, 'Duplicate exist. You are not allow to create duplicates.');
                    } else {
                        //Inter Related Lead Tagging on Original Lead//
                        /*if(ExecutionType == 'Insert') {
                            for(Id lId: leadId) {
                                if(originalLeadList[0].Inter_Related_BU_1__c == null)
                                   originalLeadList[0].Inter_Related_BU_1__c = lId;
                                else if(originalLeadList[0].Inter_Related_BU_2__c == null)
                                   originalLeadList[0].Inter_Related_BU_2__c = lId;
                            }
                        }*/
                        //Inter Related Lead Tagging on Original Lead//
                        resultMap.put(TRUE, 'SUCCESS');
                    }
                } else {
                    resultMap.put(TRUE, 'SUCCESS');
                }
            } else if(ObjectType == 'Account') {
                resultMap.put(FALSE, 'Duplicate exist. You are not allow to create duplicates.');
            }
        } else if(!leadId.isEmpty()) {
            if(ObjectType == 'Lead') {
                //Get Original Lead Record Type Name
                String recordTypeName = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosById().get(originalLeadList[0].RecordTypeId).getName();
                system.debug('recordTypeName: '+recordTypeName);
                
                lList = [Select Id, Name, LastName, MobilePhone, Email from Lead 
                         where Id IN: leadId AND RecordType.Name =: recordTypeName AND isConverted = false AND Active__c = true];
                system.debug('lList : '+lList );
                
                if(!lList.isEmpty()) {
                    resultMap.put(FALSE, 'Duplicate exist. You are not allow to create duplicates.');
                } else {
                    //Inter Related Lead Tagging on Original Lead//
                    /*if(ExecutionType == 'Insert') {
                        for(Id lId: leadId) {
                            if(originalLeadList[0].Inter_Related_BU_1__c == null)
                               originalLeadList[0].Inter_Related_BU_1__c = lId;
                            else if(originalLeadList[0].Inter_Related_BU_2__c == null)
                               originalLeadList[0].Inter_Related_BU_2__c = lId;
                        }
                    }*/
                    //Inter Related Lead Tagging on Original Lead//
                    resultMap.put(TRUE, 'SUCCESS');
                }
            } else if(ObjectType == 'Account') {
                lList = [Select Id, Name, MobilePhone, Email from Lead 
                         where Id IN: leadId AND isConverted = false AND Active__c = true];
                system.debug('lList: '+lList);
                
                if(!lList.isEmpty()) {
                    //Inter Related Lead Tagging on Original Lead//
                    /*if(ExecutionType == 'Insert') {
                        for(Id lId: leadId) {
                            if(originalLeadList[0].Inter_Related_BU_1__c == null)
                                originalLeadList[0].Inter_Related_BU_1__c = lId;
                            else if(originalLeadList[0].Inter_Related_BU_2__c == null)
                                originalLeadList[0].Inter_Related_BU_2__c = lId;
                            else if(originalLeadList[0].Inter_Related_BU_3__c == null)
                                originalLeadList[0].Inter_Related_BU_3__c = lId;
                        }
                    }*/
                    //Inter Related Lead Tagging on Original Lead//
                    resultMap.put(TRUE, 'SUCCESS');
                }
            }
        } else {
            system.debug('Error: Duplicate Lead & Account Not Present.');
        }
        return resultMap;
    }
    
    /*public static void interRelatedInfoTagging(List <DupResultsDTO> dupList, List<Lead> originalLeadList, String ObjectType) {
        Set<Id> accountId = new Set<Id>();
        Set<Id> leadId = new Set<Id>();
        List<Account> duplicateAccountList = new List<Account>();
        List<Account> updateAccountList = new List<Account>();
        List<Lead> duplicateLeadList = new List<Lead>();
        List<Lead> updateLeadList = new List<Lead>();
        
        for(DupResultsDTO d: dupList) {
            for(String key: d.duplicatesMap.keySet()) {
                if(key == 'Account') {
                    system.debug('In Duplicate Account: '+d.duplicatesMap.get(Key));
                    accountId = d.duplicatesMap.get(Key);
                }
                if(key == 'Lead') {
                    system.debug('In Duplicate Lead: '+d.duplicatesMap.get(Key));
                    leadId = d.duplicatesMap.get(Key);
                }
            }
        }
        
        if(!accountId.isEmpty()) {
            duplicateAccountList = [Select Id, Inter_Related_BU_1__c, Inter_Related_BU_2__c, Inter_Related_BU_3__c from Account where Id IN: accountId
                                    AND isPersonAccount = true];
            system.debug('duplicateAccountList: '+duplicateAccountList);
            
            if(ObjectType == 'Lead') {
                if(!duplicateAccountList.isEmpty()) {
                    //Inter Related Lead Tagging on Account//
                    for(Account a: duplicateAccountList) {
                        if(a.Inter_Related_BU_1__c == null)
                            a.Inter_Related_BU_1__c = originalLeadList[0].Id;
                        else if(a.Inter_Related_BU_2__c == null)
                            a.Inter_Related_BU_2__c = originalLeadList[0].Id;
                        else if(a.Inter_Related_BU_3__c == null)
                            a.Inter_Related_BU_3__c = originalLeadList[0].Id;
                        
                        updateAccountList.add(a);
                    }
                    //Inter Related Lead Tagging on Account//
                }
            }
        } 
        
        if(!leadId.isEmpty()) {
            duplicateLeadList = [Select Id, Inter_Related_BU_1__c, Inter_Related_BU_2__c, Inter_Related_Account__c, Inter_Related_Opportunity__c from Lead
                                where Id =: leadId AND isConverted = false];
            system.debug('duplicateLeadList: '+duplicateLeadList);
            
            if(ObjectType == 'Lead') {
                if(!duplicateLeadList.isEmpty()) {
                    //Inter Related Lead Tagging on Lead//
                    for(Lead l: duplicateLeadList) {
                        if(l.Inter_Related_BU_1__c == null)
                            l.Inter_Related_BU_1__c = originalLeadList[0].Id;
                        else if(l.Inter_Related_BU_2__c == null)
                            l.Inter_Related_BU_2__c = originalLeadList[0].Id;
                            
                        updateLeadList.add(l);
                    }
                    //Inter Related Lead Tagging on Lead//
                }
            }
        }
        
        system.debug('updateAccountList: '+updateAccountList);
        if(!updateAccountList.isEmpty())
            update updateAccountList;
            
        system.debug('updateLeadList: '+updateLeadList);
        if(!updateLeadList.isEmpty())
            update updateLeadList;
    }*/
}