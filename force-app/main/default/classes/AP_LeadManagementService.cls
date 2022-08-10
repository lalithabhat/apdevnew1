/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 26-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all Lead services.
*********************************************************************************************************/
public class AP_LeadManagementService {
    //updateChildLeads method was created by raghu for counting the No of child leads field in the BH Store lead
    public static void updateChildLeads(List<Lead> leadslist){   
        Set<id> leadIds = new Set<id>();
        Map<id,AggregateResult> mapIds = new Map<id,AggregateResult>();
        Map<id,Lead> mapLeads = new Map<id,Lead>();
        for(Lead l : leadslist){
            // if((l.Record_Type_Name__c == 'BHS') || (l.Record_Type_Name__c == 'SPS') || (l.Record_Type_Name__c == 'TCS') || (l.Record_Type_Name__c == 'SLEEK')){
            leadIds.add(l.BH_Store_Lead__c);
            mapLeads.put(l.id,l);
            //}
        }
        List<lead> leadsToRollup = new List<lead>();
        
        for(AggregateResult ar : [SELECT BH_Store_Lead__c leadId, Count(Id) ChildLeadCount FROM Lead WHERE BH_Store_Lead__c in:leadIds GROUP BY BH_Store_Lead__c ]){
            Lead l = new Lead();
            l.id = (Id) ar.get('leadId');
            l.No_Of_Child_Leads__c = (Integer) ar.get('ChildLeadCount');
            leadsToRollup.add(l);
            /* Lead l = mapLeads.get((Id)(ar.get('leadId')));
l.No_Of_Child_Leads__c = (Integer) ar.get('ChildLeadCount');*/
        }
        Update leadsToRollup;
    }
    
    //Used for validate lead informaton like mobile, email, etc. 
    public static void runPrehook(List<Lead> leadList) {
        Map<Id, String> leadValidationMap = new Map<Id, String>();
        leadValidationMap = LeadManagementServices.validateLeadDetails(leadList);
        system.debug('leadValidationMap: '+leadValidationMap);
        
        if(leadValidationMap != null) {
            for(Lead l: leadList) {
                if(leadValidationMap.containsKey(l.Id)) {
                    l.addError(leadValidationMap.get(l.Id));
                }
            }
        }
    }
    
    public static void checkServiceability(List<Lead> leadList) {
        ServiceabilityManagement.assignBotProcessTypeonLead(leadList);
        ServiceabilityManagement.checkLeadServiceability(leadList);
    }
    
    public static void runDedupeCheck(List<Lead> leadList) {
        List<DupResultsDTO> dupResList = new List<DupResultsDTO>();
        Map<Boolean, String> resultMap = new Map<Boolean, String>();
        
        //check the user, if its batch user, only then call the preprocessing logic
        if(!(System.isBatch())) {
            dupResList = LeadManagementServices.leadPreProcessing(leadList, 'WEB');
            system.debug('dupResList:: '+dupResList);
            
            if (!dupResList.isEmpty()) {
                resultMap = EnquiryManagementServices.leadProcessing(dupResList, leadList, 'Lead');
                system.debug('resultMap:: '+resultMap);
                
                for(Lead l: leadList) {
                    System.debug('l:: ' +l);
                    
                    if(!Test.isRunningTest() && resultMap.containsKey(FALSE)) {
                        l.addError(resultMap.get(FALSE));
                    }                   
                }
            }
        }
    }
    
    public static void tagServiceTerritoryDetail(List<Lead> leadList) {
        Set<String> pincodeSet = new Set<String>();
        Map<String, Pincode__c> pincodeMap = new Map<String, Pincode__c>();
        Map<String, Set<String>> servicePincodeMap = new Map<String, Set<String>>();
        Map<Id,Schema.RecordTypeInfo> rtMap = Lead.sobjectType.getDescribe().getRecordTypeInfosById();
        Map<String, Service_Territory__c> serviceTerritoryMapForSPS = new Map<String, Service_Territory__c>();
        Map<String, Map<String, User>> pincodeHODMapForSPS = new Map<String, Map<String, User>>();
        Map<String, Service_Territory__c> serviceTerritoryMapForBHS = new Map<String, Service_Territory__c>();
        Map<String, Map<String, User>> pincodeHODMapForBHS = new Map<String, Map<String, User>>();
        
        for(Lead l: leadList) {
            pincodeSet.add(l.Pincode__c);
            if(rtMap.get(l.RecordTypeId).getDeveloperName() == 'SPS' || rtMap.get(l.RecordTypeId).getDeveloperName() == 'BHS') {
                if(!servicePincodeMap.containsKey(rtMap.get(l.RecordTypeId).getDeveloperName())) {
                    Set<String> pincode = new Set<String>();
                    pincode.add(l.Pincode__c);
                    servicePincodeMap.put(rtMap.get(l.RecordTypeId).getDeveloperName(), pincode);
                } else {
                    servicePincodeMap.get(rtMap.get(l.RecordTypeId).getDeveloperName()).add(l.Pincode__c);
                }
            }
        }
        
        if(servicePincodeMap != null) {
            if(!pincodeSet.isEmpty())
                pincodeMap = AP_ServiceTerritoryManagementService.getPincodeRelatedDetails(pincodeSet);
            if(servicePincodeMap.containsKey('SPS')) {
                serviceTerritoryMapForSPS = AP_ServiceTerritoryManagementService.getTerritoryforSPS(servicePincodeMap.get('SPS'));
                pincodeHODMapForSPS = AP_ServiceTerritoryManagementService.getHODForSPS(servicePincodeMap.get('SPS'));
            }
            if(servicePincodeMap.containsKey('BHS')) {
                serviceTerritoryMapForBHS = AP_ServiceTerritoryManagementService.getTerritoryforBHS(servicePincodeMap.get('BHS'));
                pincodeHODMapForBHS = AP_ServiceTerritoryManagementService.getHODForBHS(servicePincodeMap.get('BHS'));
            }
            
            for(Lead l: leadList) {
                if(pincodeMap.containsKey(l.Pincode__c))
                    l.Pincode_lookup__c = pincodeMap.get(l.Pincode__c).Id;
                if(rtMap.get(l.RecordTypeId).getDeveloperName() == 'SPS') {
                    if(serviceTerritoryMapForSPS.containsKey(l.Pincode__c) && serviceTerritoryMapForSPS.get(l.Pincode__c).Parent__r.Id != null) {
                        l.Service_Territory__c = serviceTerritoryMapForSPS.get(l.Pincode__c).Parent__r.Id;
                        l.Service_Territory_Name__c = serviceTerritoryMapForSPS.get(l.Pincode__c).Parent__r.Name;
                    }
                    if(pincodeHODMapForSPS.containsKey(l.Pincode__c)) {
                        Map<String, User> HODMapForSPS = pincodeHODMapForSPS.get(l.Pincode__c);
                        
                        if(HODMapForSPS != null) {
                            for(String str: HODMapForSPS.keySet()) {
                                if(HODMapForSPS.get(str) != null) {
                                    if(str.equalsIgnoreCase('Region'))
                                        l.SSO__c = HODMapForSPS.get(str).Id;
                                    if(str.equalsIgnoreCase('Unit'))
                                        l.UH__c = HODMapForSPS.get(str).Id;
                                    if(str.equalsIgnoreCase('Division'))
                                        l.DH__c = HODMapForSPS.get(str).Id;
                                }
                            }
                        }
                    }
                } else if(rtMap.get(l.RecordTypeId).getDeveloperName() == 'BHS') {
                    if(serviceTerritoryMapForBHS.containsKey(l.Pincode__c) && serviceTerritoryMapForBHS.get(l.Pincode__c).Parent__r.Id != null) {
                        l.Service_Territory__c = serviceTerritoryMapForBHS.get(l.Pincode__c).Parent__r.Id;
                        l.Service_Territory_Name__c = serviceTerritoryMapForBHS.get(l.Pincode__c).Parent__r.Name;
                    }
                    if(pincodeHODMapForBHS.containsKey(l.Pincode__c)) {
                        Map<String, User> HODMapForBHS = pincodeHODMapForBHS.get(l.Pincode__c);
                        
                        if(HODMapForBHS != null) {
                            for(String str: HODMapForBHS.keySet()) {
                                if(HODMapForBHS.get(str) != null) {
                                    if(str.equalsIgnoreCase('Territory'))
                                        l.SSO__c = HODMapForBHS.get(str).Id;
                                    //if(str.equalsIgnoreCase('City'))
                                    //l.SSO__c = HODMapForBHS.get(str).Id;
                                    if(str.equalsIgnoreCase('Unit'))
                                        l.UH__c = HODMapForBHS.get(str).Id;
                                    if(str.equalsIgnoreCase('Region'))
                                        l.DH__c = HODMapForBHS.get(str).Id;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void tagCampaignLead(List<Lead> leadList) {
        try {
            CampaignManagementServices.AddCampaignToLead(leadList);
        } catch (GlobalException ex) {
            System.debug('Global Exception:' + ex.getErrorMsg() + ex.getClassDetails());
        }
    }
    
    public static void makeAllocationforC4CBHSLead(List<Lead> leadListC4CBHS) {
        for(Lead l: leadListC4CBHS) {
            ScheduleAppointmentServices.UserWrapper contactWrap = Get_SA_Available_Slot.getContactList(l.Id);
            if(contactWrap != null && !contactWrap.userList.isEmpty()) {
                String result = Get_SA_Available_Slot.Bot_assignCAWithoutAppointmentApex(l.Id, contactWrap.userList[0].SA__c, null);
                
                if(result.equalsIgnoreCase('Fail'))
                    l.addError('Error occured while lead allocation.');
            } 
        }
    }
    
    public static void updateAssignmentDateTime(Set<Id> ownerId, List<Lead> leadList, Boolean isLocal) {
        Map<Id, User> userProfileMap = new Map<Id, User>();
        Set<Id> userIdSet = new Set<Id>();
        Set<String> pincodeSet = new Set<String>();
        Set<String> skillSet = new Set<String>();
        Map<String, Id> teamLeadMap = new Map<String, Id>();
        Map<String, Id> teamLeadMapfromContact = new Map<String,Id>();  //Holding TL1 & TL2 from CA contact 
        Map<Id,Id> userContactMap = new Map<Id,Id>();  //contactId, userId
        List<User> userList = [Select Id, Name, Profile.Name, ContactId,Contact.Team_Lead_1__c, Contact.Team_Lead_2__c, Contact.AccountId from User where Id IN: ownerId AND IsActive = true];
        system.debug('userList: '+userList);
        
        if(!userList.isEmpty()) {
            for(User u: userList) {
                userProfileMap.put(u.Id, u);
                if(u.Contact.Team_Lead_1__c !=null) 
                {
                    userContactMap.put(u.Contact.Team_Lead_1__c, null);
                    teamLeadmapfromContact.put(u.Id + 'TL1', u.Contact.Team_Lead_1__c);
                }
                if(u.Contact.Team_Lead_2__c !=null) {
                    userContactMap.put(u.Contact.Team_Lead_2__c, null);
                    teamLeadmapfromContact.put(u.Id + 'TL2', u.Contact.Team_Lead_2__c);
                }
            }
        }
        for(User tlUser : [Select Id,ContactId from User Where ContactId IN : userContactMap.keyset()]){
            userContactMap.put(tlUser.contactId, tlUser.Id);
        }
        for(Lead l: leadList) {
            if(userProfileMap.get(l.OwnerId).Profile.Name == 'Sales Associate (SA)' || userProfileMap.get(l.OwnerId).Profile.Name == 'Customer Associate (CA)') {
                l.Assigned_DateTime__c = system.now();
                if(!String.isBlank(l.Pincode__c) && !String.isBlank(l.Skills__c)) {
                    userIdSet.add(userProfileMap.get(l.OwnerId).ContactId);
                    pincodeSet.add(l.Pincode__c);
                    skillSet.add(l.Skills__c);
                }
                if(isLocal && !l.Legacy_Upload__c) {
                    l.Is_Local__c = true;
                    l.Status = 'Allocation Done';
                }
                if(userProfileMap.get(l.OwnerId).Profile.Name == 'Customer Associate (CA)') {
                    if(userProfileMap.get(l.OwnerId).Contact.AccountId != null)
                        l.Dealer__c = userProfileMap.get(l.OwnerId).Contact.AccountId;
                }
            }
        }
        
        if(!userIdSet.isEmpty() && !pincodeSet.isEmpty() && !skillSet.isEmpty())
            teamLeadMap = AP_ServiceTerritoryManagementService.getTeamLeadInfo(userIdSet, pincodeSet, skillSet);
        
        if(!teamLeadMap.isEmpty() && teamLeadMap != null) {
            for(Lead l: leadList) {
                if(!String.isBlank(l.Pincode__c) && !String.isBlank(l.Skills__c)) {
                    if(teamLeadMap.containsKey(userProfileMap.get(l.OwnerId).ContactId+''+l.Pincode__c+''+l.Skills__c+'TL1'))
                        l.TL1__c = teamLeadMap.get(userProfileMap.get(l.OwnerId).ContactId+''+l.Pincode__c+''+l.Skills__c+'TL1');
                    if(teamLeadMap.containsKey(userProfileMap.get(l.OwnerId).ContactId+''+l.Pincode__c+''+l.Skills__c+'TL2'))
                        l.TL2__c = teamLeadMap.get(userProfileMap.get(l.OwnerId).ContactId+''+l.Pincode__c+''+l.Skills__c+'TL2');
                }
            }
        }
        
        //////////////////////////If TL1 & TL2 not found basis pincode - populate from CA contact
        if(!teamLeadMapfromContact.isEmpty() && teamLeadMapfromContact != null) {
            for(Lead l: leadList) {
                if(l.TL1__c == null){
                    if(teamLeadMapfromContact.containsKey(l.OwnerId+'TL1'))
                        l.TL1__c = userContactMap.get(teamLeadMapfromContact.get(l.OwnerId+'TL1'));
                }
                if(l.TL2__c == null) {
                    if(teamLeadMapfromContact.containsKey(l.OwnerId+'TL2'))
                        l.TL2__c = userContactMap.get(teamLeadMapfromContact.get(l.OwnerId+'TL2'));
                }
            }
        } 
        
    }
    
    public static void calculateLeadOpporunityInfo(Set<Id> userIdSet) {
        Set<Id> dealerIdSet = new Set<Id>();
        List<User> userList = new List<User>();
        List<Account> updateDealerList = new List<Account>();
        List<Contact> updateCAContactList = new List<Contact>();
        Map<Id, Account> dealerMap = new Map<Id, Account>();
        Map<Id, Integer> dealerPipelineLeadMap = new Map<Id, Integer>();
        Map<Id, Integer> dealerLastSevenDayLeadCountMap = new Map<Id, Integer>();
        Map<Id, DateTime> CALastAssignedLeadMap = new Map<Id, DateTime>();
        Map<Id, DateTime> CALastAssignedOpportunityMap = new Map<Id, DateTime>();
        Map<Id, DateTime> dealerLastAssignmentFinal = new Map<Id, DateTime>();
        Map<Id, DateTime> CALastAssignmentFinal = new Map<Id, DateTime>();
        Map<Id, Id> CADealerMap = new Map<Id, Id>();
        Map<Id, Contact> CAContactMap = new Map<Id, Contact>();
        
        if(!userIdSet.isEmpty() && userIdSet != null) {
            userList = [SELECT Id, ContactId, Contact.AccountId, Name From User Where Id IN: userIdSet];
            system.debug('userList: '+userList);
        }
        if(!userList.isEmpty() && userList != null) {
            for(User u : userList) {
                dealerIdSet.add(u.Contact.AccountId);
                CADealerMap.put(u.Id, u.Contact.AccountId);
            }
            CAContactMap = DealerManagementServices.getCAContact(userList);
        }
        if(!dealerIdSet.isEmpty() && dealerIdSet != null) {
            dealerMap = DealerManagementServices.getDealerMap(dealerIdSet);
            dealerPipelineLeadMap = DealerManagementServices.getPipelineLead(dealerIdSet);
            dealerLastSevenDayLeadCountMap = DealerManagementServices.getLastSevenDaysLeadCount(dealerIdSet);
        }
        if(!CADealerMap.isEmpty() && CADealerMap != null) {
            //Get CA Wise Last Assignment DateTime (Lead)
            CALastAssignedLeadMap = DealerManagementServices.getCALastAssignedLead(CADealerMap.keySet());
            //Get CA Wise Last Assignment DateTime (Opportunity)
            CALastAssignedOpportunityMap = DealerManagementServices.getCALastAssignedOpportunity(CADealerMap.keySet());
            
            //Get Dealer Wise Last Assignment DateTime (Lead/Opportunity)
            dealerLastAssignmentFinal = DealerManagementServices.getDealerLastAssigmentFinal(CADealerMap, CALastAssignedLeadMap, CALastAssignedOpportunityMap);
            //Get CA Wise Last Assignment DateTime(Lead/ Opportunity)
            CALastAssignmentFinal = DealerManagementServices.getCALastAssigmentFinal(CADealerMap, CALastAssignedLeadMap, CALastAssignedOpportunityMap);
        }
        if(!dealerMap.isEmpty() && dealerMap != null) {
            for(Id dId: dealerMap.keySet()) {
                if(dealerPipelineLeadMap.containsKey(dId)) {
                    Account dealer = dealerMap.get(dId);
                    dealer.Open_Lead__c = dealerPipelineLeadMap.get(dId);
                    if(dealerLastSevenDayLeadCountMap.containsKey(dId))
                        dealer.Last_7_Day_Count__c = dealerLastSevenDayLeadCountMap.get(dId);
                    if(dealerLastAssignmentFinal.containsKey(dId))
                        dealer.Latest_Assigned_DateTime__c = dealerLastAssignmentFinal.get(dId);
                    updateDealerList.add(dealer);
                }
            }
        }
        if(!CAContactMap.isEmpty() && CAContactMap != null) {
            for(Id uId: CAContactMap.keySet()) {
                if(CALastAssignmentFinal.containsKey(uId)) {
                    Contact userContact = CAContactMap.get(uId);
                    userContact.Latest_Assigned_DateTime__c = CALastAssignmentFinal.get(uId);
                    updateCAContactList.add(userContact);
                }
            }
        }
        if(!updateDealerList.isEmpty() && updateDealerList != null)
            update updateDealerList;
        if(!updateCAContactList.isEmpty() && updateCAContactList != null)
            update updateCAContactList;
    }
    
    public static void pincodeChangeImplementation(List<Lead> leadList) {
        //Firstly assign recordtype based on Campaign Code. If not present, then use Campaign Lookup field to decide recordtype
        //If both are not present then use default recordtype as BHS
        Map<String, List<Lead>> campaignLeadMap = new Map<String, List<Lead>>();
        Map<String, Campaign> campaignMap = new Map<String, Campaign>();
        List<Campaign> cList = new List<Campaign>();
        
        for(Lead l: leadList) {
            if(l.Campaign_Code__c != null && l.Campaign_Code__c != '') {
                String tempCode = l.Campaign_Code__c.toLowerCase();
                if(campaignLeadMap.containsKey(tempCode)) {
                    campaignLeadMap.get(tempCode).add(l);
                } else {
                    List<Lead> newLeadList = new List<Lead>();
                    newLeadList.add(l);
                    campaignLeadMap.put(tempCode, newLeadList);
                }
            } else if(l.CampaignName__c != null) {
                if(campaignLeadMap.containsKey(l.CampaignName__c)) {
                    campaignLeadMap.get(l.CampaignName__c).add(l);
                } else {
                    List<Lead> newLeadList = new List<Lead>();
                    newLeadList.add(l);
                    campaignLeadMap.put(l.CampaignName__c, newLeadList);
                }
            } else {
                l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('BHS').getRecordTypeId();
                l.Skills__c = 'BHS';
            }
        }
        system.debug('campaignLeadMap: '+campaignLeadMap);
        if(campaignLeadMap != null) {
            cList = [Select Id, Name, BU__c, Sub_Service__c, Source__c, Digital_Marketing_Campaign_Code__c From Campaign 
                     where (Digital_Marketing_Campaign_Code__c =: campaignLeadMap.keySet() OR Id =: campaignLeadMap.keySet())];
            
            if(!cList.isEmpty() && cList != null) {
                for(Campaign c: cList) {
                    String tempCode = c.Digital_Marketing_Campaign_Code__c.toLowerCase();
                    campaignMap.put(tempCode, c);
                    campaignMap.put(c.Id, c);
                }
            }
            system.debug('campaignMap: '+campaignMap);
            for(String cId: campaignLeadMap.keySet()) {
                List<Lead> getLeadList = campaignLeadMap.get(cId);
                
                if(getLeadList != null) {
                    for(Lead l: getLeadList) {
                        if(l.Campaign_Code__c != null && l.Campaign_Code__c != '') {
                            String tempCode = l.Campaign_Code__c.toLowerCase();
                            l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get(campaignMap.get(tempCode).BU__c).getRecordTypeId();
                            l.Skills__c = campaignMap.get(tempCode).Sub_Service__c;
                        } else if(l.CampaignName__c != null) {
                            l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get(campaignMap.get(l.CampaignName__c).BU__c).getRecordTypeId();
                            l.Skills__c = campaignMap.get(l.CampaignName__c).Sub_Service__c;
                        }
                    }
                }
            }
        }
        checkServiceability(leadList);
        runDedupeCheck(leadList);
        tagServiceTerritoryDetail(leadList);
    }
}