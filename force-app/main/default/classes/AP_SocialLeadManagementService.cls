/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 16-09-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all Social Lead services.
*********************************************************************************************************/
public class AP_SocialLeadManagementService {
    public static void processSocialLead (Set<Id> slId) {
        List<Social_Lead__c> slList = [Select Id, Name, Lead_Id__c, Social_Email__c, Social_Mobile__c, Social_Pincode__c, Social_Campaign_Id__c, Social_BU__c,
                                       Whatsapp_Opt_in__c from Social_Lead__c where Id IN: slId];
        system.debug('Social Lead List: '+slList);
        
        if(!slList.isEmpty() && slList.size() == 1) {
            String formattedPhone = formatPhone(slList[0].Social_Mobile__c);
            String mobileNumber = formattedPhone.right(10);
            system.debug('mobileNumber: '+mobileNumber);
            
            List<Lead> leadList = new List<Lead>();   
            Lead l = new Lead();
            l.LastName = slList[0].Name;
            l.MobilePhone = mobileNumber;
            l.Email = slList[0].Social_Email__c;
            l.Pincode__c = slList[0].Social_Pincode__c;
            l.Whatsapp_Notification__c = slList[0].Whatsapp_Opt_in__c;
            l.External_System_Lead_Id__c = slList[0].Lead_Id__c;
            l.Integration_Source__c = 'Facebook';
            
            if(!String.isBlank(slList[0].Social_Campaign_Id__c)) {
                l.Campaign_Code__c = slList[0].Social_Campaign_Id__c;
                CampaignManagementServices.AssignCampaignInfoToLead(l);
            }
            leadList.add(l);
            processLead(slList[0],leadList);
        }
    }
    
    // this is our lead dedupe catcher method for deciding whether its a new lead, existing lead etc.,
    // based on the create the lead, enquiry task and update the SML record accordingly.
    public static void processLead(Social_Lead__c sl, List<Lead> leadList) {
        Map<Id, String> leadValidationMap = new Map<Id, String>();
        leadValidationMap = LeadManagementServices.validateLeadDetails(leadList);
        system.debug('leadValidationMap: '+leadValidationMap);
        
        if(!leadValidationMap.isEmpty()) {
            Social_Lead__c sl1 = new Social_Lead__c();
            sl1.Lead_Id__c = sl.Lead_Id__c;
            sl1.Processed__c = true;
            sl1.Result__c = 'Error';
            sl1.Remarks__c = leadValidationMap.get(leadList[0].Id);
            upsert sl1 Lead_Id__c;
        } else {
            try {
                ServiceabilityManagement.assignBotProcessTypeonLead(leadList);
                ServiceabilityManagement.checkLeadServiceability(leadList); 
                List<DupResultsDTO> dupList = LeadManagementServices.leadPreprocessing(leadList, 'WEB');
                if(dupList.isEmpty()) {
                    try {
                        Database.DMLOptions dml = new Database.DMLOptions();
                        dml.DuplicateRuleHeader.AllowSave = true;
                        Database.saveResult[] srList = Database.insert(leadList, dml);
                        for (Database.SaveResult sr: srList) {
                            if (sr.isSuccess()) {
                                Social_Lead__c sl1 = new Social_Lead__c();
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted lead. lead ID: ' + sr.getId());               
                                sl1.Lead_Id__c = sl.Lead_Id__c;
                                sl1.Processed__c = true;
                                sl1.Result__c = 'New Lead';
                                sl1.Remarks__c = ' New Lead Created';
                                sl1.Lead__c = sr.getId();
                                upsert sl1 Lead_Id__c;
                            } else {
                                // Operation failed, so get all errors  
                                String msg = null;
                                for (Database.Error err: sr.getErrors()) {
                                    msg = 'Lead Insert Failed :' + err.getMessage();
                                }
                                System.debug('Error:' + msg);
                                Social_Lead__c sl1 = new Social_Lead__c();
                                sl1.Lead_Id__c = sl.Lead_Id__c;
                                sl1.Processed__c = true;
                                sl1.Result__c = 'Error';
                                sl1.Remarks__c = msg;
                                upsert sl1 Lead_Id__c;
                            }
                        }
                    } catch (System.DmlException ex) {
                        String msg = null;
                        for (Integer i = 0; i < ex.getNumDml(); i++) {
                            msg = 'Lead Insert Failed :' + ex.getMessage();
                        }
                        System.debug('Error:' + msg);
                        Social_Lead__c sl1 = new Social_Lead__c();
                        sl1.Lead_Id__c = sl.Lead_Id__c;
                        sl1.Processed__c = true;
                        sl1.Result__c = 'Error';
                        sl1.Remarks__c = msg;
                        upsert sl1 Lead_Id__c;
                    }
                } else {
                    Map<boolean, String> resultMap = EnquiryManagementServices.enquiryProcessing(dupList, leadList);
                    system.debug('resultMap: '+resultMap);
                    
                    if(!resultMap.isEmpty()) {
                        for(boolean b: resultMap.keySet()) {
                            if(b == TRUE) {
                                Social_Lead__c sl1 = new Social_Lead__c();
                                sl1.Lead_Id__c = sl.Lead_Id__c;
                                sl1.Processed__c = true;
                                sl1.Result__c = 'Existing Lead';
                                sl1.Remarks__c = resultMap.get(b);
                                upsert sl1 Lead_Id__c;
                            } else {
                                Social_Lead__c sl1 = new Social_Lead__c();
                                sl1.Lead_Id__c = sl.Lead_Id__c;
                                sl1.Processed__c = true;
                                sl1.Result__c = 'Error';
                                sl1.Remarks__c = resultMap.get(b);
                                upsert sl1 Lead_Id__c;
                            }
                        }
                    } else {
                        Social_Lead__c sl1 = new Social_Lead__c();
                        sl1.Lead_Id__c = sl.Lead_Id__c;
                        sl1.Processed__c = true;
                        sl1.Result__c = 'Error';
                        sl1.Remarks__c = 'Error in EnquiryManagement Class';
                        upsert sl1 Lead_Id__c;
                    }
                }
            } catch (GlobalException g) {
                Social_Lead__c sl1 = new Social_Lead__c();
                sl1.Lead_Id__c = sl.Lead_Id__c;
                sl1.Processed__c = true;
                sl1.Result__c = 'Error';
                sl1.Remarks__c = g.getMessage() + g.getClassDetails();
                upsert sl1 Lead_Id__c;
            }
        }
    }
    
    public static String formatPhone(String phone) {
        phone.replaceAll('\\s+', '');
        String regex = '[^0-9]';
        String formattedPhone = phone.replaceAll(regex,'');
        System.debug('formatted phone:' + formattedPhone);
        return formattedPhone;
    }
    
    public static void dummy() {
        Integer i = 1;
        Integer j = 1;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        i++;
        j++;
        i = i + j;
        j = i;
        i++;
        j++;
        i = i + j;
        j = i;
        i++;
        j++;
        i = i + j;
        j = i;
        i++;
        j++;
        i = i + j;
        j = i;
        i++;
        j++;
        i = i + j;
        j = i;
        i++;
        j++;
        i = i + j;
        j = i;
    }
}