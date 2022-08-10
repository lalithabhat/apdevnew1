/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 26-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all Opportunity services.
*********************************************************************************************************/
public class AP_OpportunityManagementService {
     public static void updateChildOpportunities(List<Opportunity> OpportunitiesList){   
        Set<id> OpptIds = new Set<id>();
        Map<id,AggregateResult> mapIds = new Map<id,AggregateResult>();
     //   Map<id,Opportunity> mapOpportunities = new Map<id,Opportunity>();
        for(Opportunity opp : OpportunitiesList){
            // if((opp.Record_Type_Name__c == 'BHS') || (opp.Record_Type_Name__c == 'SPS') || (opp.Record_Type_Name__c == 'TCS') || (opp.Record_Type_Name__c == 'SLEEK')){
            OpptIds.add(opp.BH_Store_Opportunity__c);
         //   OpptIds.add(opp.Amount);
           // mapOpportunities.put(opp.id,opp);
            //}
        }
        List<Opportunity> opportunitiesToRollup = new List<Opportunity>();
        
        for(AggregateResult ar : [SELECT BH_Store_Opportunity__c OpportunityId, Count(Id) ChildOpportunityCount,Sum(Amount) AmountSum FROM Opportunity WHERE BH_Store_Opportunity__c in:OpptIds GROUP BY BH_Store_Opportunity__c]){
            Opportunity opp = new Opportunity();
            opp.id = (Id) ar.get('OpportunityId');
            opp.No_of_Child_Opportunities__c = (Integer) ar.get('ChildOpportunityCount');
            opp.Amount = (Decimal) ar.get('AmountSum');
            opportunitiesToRollup.add(opp);
            /* Opportunity opp = mapOpportunities.get((Id)(ar.get('OpportunityId')));
opp.No_of_Child_Opportunities__c = (Integer) ar.get('ChildOpportunityCount');*/
        }
        Update opportunitiesToRollup;
    }

    
    public static void tagServiceTerritoryDetail(List<Opportunity> opportunityList) {
        Set<String> pincodeSet = new Set<String>();
        Map<String, Pincode__c> pincodeMap = new Map<String, Pincode__c>();
        Map<String, Set<String>> servicePincodeMap = new Map<String, Set<String>>();
        Map<Id,Schema.RecordTypeInfo> rtMap = Opportunity.sobjectType.getDescribe().getRecordTypeInfosById();
        Map<String, Service_Territory__c> serviceTerritoryMapForSPS = new Map<String, Service_Territory__c>();
        Map<String, Map<String, User>> pincodeHODMapForSPS = new Map<String, Map<String, User>>();
        Map<String, Service_Territory__c> serviceTerritoryMapForBHS = new Map<String, Service_Territory__c>();
        Map<String, Map<String, User>> pincodeHODMapForBHS = new Map<String, Map<String, User>>();
        
        for(Opportunity op: opportunityList) {
            pincodeSet.add(op.Pincode__c);
            if(rtMap.get(op.RecordTypeId).getDeveloperName() == 'SPS' || rtMap.get(op.RecordTypeId).getDeveloperName() == 'BHS') {
                if(!servicePincodeMap.containsKey(rtMap.get(op.RecordTypeId).getDeveloperName())) {
                    Set<String> pincode = new Set<String>();
                    pincode.add(op.Pincode__c);
                    servicePincodeMap.put(rtMap.get(op.RecordTypeId).getDeveloperName(), pincode);
                } else {
                    servicePincodeMap.get(rtMap.get(op.RecordTypeId).getDeveloperName()).add(op.Pincode__c);
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
            
            for(Opportunity op: opportunityList) {
                if(pincodeMap.containsKey(op.Pincode__c))
                    op.Pincode_lookup__c = pincodeMap.get(op.Pincode__c).Id;
                if(rtMap.get(op.RecordTypeId).getDeveloperName() == 'SPS') {
                    if(serviceTerritoryMapForSPS.containsKey(op.Pincode__c) && serviceTerritoryMapForSPS.get(op.Pincode__c).Parent__r.Id != null) {
                        op.Service_Territory__c = serviceTerritoryMapForSPS.get(op.Pincode__c).Parent__r.Id;
                        op.Service_Territory_Name__c = serviceTerritoryMapForSPS.get(op.Pincode__c).Parent__r.Name;
                    }
                    if(pincodeHODMapForSPS.containsKey(op.Pincode__c)) {
                        Map<String, User> HODMapForSPS = pincodeHODMapForSPS.get(op.Pincode__c);
                        
                        if(HODMapForSPS != null) {
                            for(String str: HODMapForSPS.keySet()) {
                                if(HODMapForSPS.get(str) != null) {
                                    if(str.equalsIgnoreCase('Region'))
                                        op.SSO__c = HODMapForSPS.get(str).Id;
                                    if(str.equalsIgnoreCase('Unit'))
                                        op.Unit_Head_UH__c = HODMapForSPS.get(str).Id;
                                    if(str.equalsIgnoreCase('Division'))
                                        op.Division_Head_DH__c = HODMapForSPS.get(str).Id;
                                }
                            }
                        }
                    }
                } else if(rtMap.get(op.RecordTypeId).getDeveloperName() == 'BHS') {
                    if(serviceTerritoryMapForBHS.containsKey(op.Pincode__c) && serviceTerritoryMapForBHS.get(op.Pincode__c).Parent__r.Id != null) {
                        op.Service_Territory__c = serviceTerritoryMapForBHS.get(op.Pincode__c).Parent__r.Id;
                    	op.Service_Territory_Name__c = serviceTerritoryMapForBHS.get(op.Pincode__c).Parent__r.Name;
                    }
                    if(pincodeHODMapForBHS.containsKey(op.Pincode__c)) {
                        Map<String, User> HODMapForBHS = pincodeHODMapForBHS.get(op.Pincode__c);
                        
                        if(HODMapForBHS != null) {
                            for(String str: HODMapForBHS.keySet()) {
                                if(HODMapForBHS.get(str) != null) {
                                    if(str.equalsIgnoreCase('Territory'))
                                        op.SSO__c = HODMapForBHS.get(str).Id;
                                    //if(str.equalsIgnoreCase('City'))
                                        //op.SSO__c = HODMapForBHS.get(str).Id;
                                    if(str.equalsIgnoreCase('Unit'))
                                        op.Unit_Head_UH__c = HODMapForBHS.get(str).Id;
                                    if(str.equalsIgnoreCase('Region'))
                                        op.Division_Head_DH__c = HODMapForBHS.get(str).Id;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    public static void updateAssignmentDateTime(Set<Id> ownerId, List<Opportunity> opportunityList) {
        Map<Id, User> userProfileMap = new Map<Id, User>();
        Set<Id> userIdSet = new Set<Id>();
        Set<String> pincodeSet = new Set<String>();
        Set<String> skillSet = new Set<String>();
        Map<String, Id> teamLeadMap = new Map<String, Id>();
            
        List<User> userList = [Select Id, Name, Profile.Name, ContactId, Contact.AccountId from User where Id IN: ownerId AND IsActive = true];
        system.debug('userList: '+userList);
        
        if(!userList.isEmpty()) {
            for(User u: userList) {
            	userProfileMap.put(u.Id, u);
            }
        }
        
        for(Opportunity op: opportunityList) {
            if(userProfileMap.get(op.OwnerId).Profile.Name == 'Sales Associate (SA)' || userProfileMap.get(op.OwnerId).Profile.Name == 'Customer Associate (CA)') {
                op.Assigned_DateTime__c = system.now();
                if(!String.isBlank(op.Pincode__c) && !String.isBlank(op.Skills__c)) {
                    userIdSet.add(userProfileMap.get(op.OwnerId).ContactId);
                    pincodeSet.add(op.Pincode__c);
                    skillSet.add(op.Skills__c);
                }
                if(userProfileMap.get(op.OwnerId).Profile.Name == 'Customer Associate (CA)') {
                    if(userProfileMap.get(op.OwnerId).Contact.AccountId != null)
                        op.Dealer__c = userProfileMap.get(op.OwnerId).Contact.AccountId;
                }
            }
        }
        
        if(!userIdSet.isEmpty() && !pincodeSet.isEmpty() && !skillSet.isEmpty())
            teamLeadMap = AP_ServiceTerritoryManagementService.getTeamLeadInfo(userIdSet, pincodeSet, skillSet);
        
        if(!teamLeadMap.isEmpty() && teamLeadMap != null) {
            for(Opportunity op: opportunityList) {
                if(!String.isBlank(op.Pincode__c) && !String.isBlank(op.Skills__c)) {
                    if(teamLeadMap.containsKey(userProfileMap.get(op.OwnerId).ContactId+''+op.Pincode__c+''+op.Skills__c+'TL1'))
                        op.Team_Lead_1_TL1__c = teamLeadMap.get(userProfileMap.get(op.OwnerId).ContactId+''+op.Pincode__c+''+op.Skills__c+'TL1');
                    if(teamLeadMap.containsKey(userProfileMap.get(op.OwnerId).ContactId+''+op.Pincode__c+''+op.Skills__c+'TL2'))
                        op.Team_Lead_2_TL2__c = teamLeadMap.get(userProfileMap.get(op.OwnerId).ContactId+''+op.Pincode__c+''+op.Skills__c+'TL2');
                }
            }
        }
    }
    
	public static void updateDealerBlockedCapacity(Set<Id> contractorIdSet) {
        Set<Id> dealerIdSet = new Set<Id>();
        List<Dealer_Contractor_Mapping__c> dealerContractorList = new List<Dealer_Contractor_Mapping__c>();
        List<Account> updateDealerList = new List<Account>();
        Map<Id, Account> dealerMap = new Map<Id, Account>();
        Map<Id, Integer> dealerBlockedCapacitytMap = new Map<Id, Integer>();
        Id recId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Contractors').getRecordTypeId();
        
        if(!contractorIdSet.isEmpty() && contractorIdSet != null) {
        	dealerContractorList = [Select Id, Dealer__c, Contractor__c, Contractor__r.Active__c, Contractor__r.RecordTypeId from Dealer_Contractor_Mapping__c 
                                   where Contractor__c IN: contractorIdSet AND Contractor__r.RecordTypeId =: recId AND Dealer__c != null];
        }
        if(!dealerContractorList.isEmpty() && dealerContractorList != null) {
            for(Dealer_Contractor_Mapping__c dcm: dealerContractorList) {
                dealerIdSet.add(dcm.Dealer__c);
            }
        }
        if(!dealerIdSet.isEmpty() && dealerIdSet != null) {
            dealerMap = DealerManagementServices.getDealerMap(dealerIdSet);
            dealerBlockedCapacitytMap = DealerManagementServices.getBlockedCapacity(dealerIdSet);
        }
        if(!dealerMap.isEmpty() && dealerMap != null) {
            for(Id dId: dealerMap.keySet()) {
                if(dealerBlockedCapacitytMap.containsKey(dId)) {
                    Account dealer = dealerMap.get(dId);
                    dealer.Blocked_Capacity__c = dealerBlockedCapacitytMap.get(dId);
                    updateDealerList.add(dealer);
                }
            }
        }
        if(!updateDealerList.isEmpty() && updateDealerList != null)
            update updateDealerList;
    }
    
    public static void calculateLeadOpporunityInfo(Set<Id> contactIdSet) {
        Set<Id> dealerIdSet = new Set<Id>();
        List<Contact> CAList = new List<Contact>();
        List<Account> updateDealerList = new List<Account>();
        Map<Id, Account> dealerMap = new Map<Id, Account>();
        Map<Id, Integer> dealerPipelineOpportunityMap = new Map<Id, Integer>();
        Map<Id, Integer> dealerLastSevenDayLeadCountMap = new Map<Id, Integer>();
        
        if(!contactIdSet.isEmpty() && contactIdSet != null) {
            CAList = [Select Id, Name, AccountId from Contact where Id IN: contactIdSet AND Active__c = true];
        	system.debug('CAList: '+CAList);
        }
        if(!CAList.isEmpty() && CAList != null) {
            for(Contact c: CAList) {
                dealerIdSet.add(c.AccountId);
            }
        }
        if(!dealerIdSet.isEmpty() && dealerIdSet != null) {
            dealerMap = DealerManagementServices.getDealerMap(dealerIdSet);
            dealerPipelineOpportunityMap = DealerManagementServices.getPipelineOpportunity(dealerIdSet);
            dealerLastSevenDayLeadCountMap = DealerManagementServices.getLastSevenDaysLeadCount(dealerIdSet);
        }
        if(!dealerMap.isEmpty() && dealerMap != null) {
            for(Id dId: dealerMap.keySet()) {
                if(dealerPipelineOpportunityMap.containsKey(dId)) {
                    Account dealer = dealerMap.get(dId);
                    dealer.Open_Opportunity__c = dealerPipelineOpportunityMap.get(dId);
                    if(dealerLastSevenDayLeadCountMap.containsKey(dId))
                        dealer.Last_7_Day_Count__c = dealerLastSevenDayLeadCountMap.get(dId);
                    updateDealerList.add(dealer);
                }
            }
        }
        if(!updateDealerList.isEmpty() && updateDealerList != null)
            update updateDealerList;
    }
    
    public static void updateDealerAndCALastAssignment(Set<Id> userId) {
        Set<Id> dealerIdSet = new Set<Id>();
        List<User> userList = new List<User>();
        List<Account> updateDealerList = new List<Account>();
        List<Contact> updateCAContactList = new List<Contact>();
        Map<Id, Account> dealerMap = new Map<Id, Account>();
        Map<Id, DateTime> CALastAssignedLeadMap = new Map<Id, DateTime>();
        Map<Id, DateTime> CALastAssignedOpportunityMap = new Map<Id, DateTime>();
        Map<Id, DateTime> dealerLastAssignmentFinal = new Map<Id, DateTime>();
        Map<Id, DateTime> CALastAssignmentFinal = new Map<Id, DateTime>();
        Map<Id, Id> CADealerMap = new Map<Id, Id>();
        Map<Id, Contact> CAContactMap = new Map<Id, Contact>();
        
        if(!userId.isEmpty() && userId != null) {
            userList = [Select Id, ContactId, Contact.AccountId from User where Id IN: userId];
            system.debug('userList: '+userList);
        }
        if(!userList.isEmpty() && userList != null) {
            for(User u: userList) {
                dealerIdSet.add(u.Contact.AccountId);
                CADealerMap.put(u.Id, u.Contact.AccountId);
            }
            CAContactMap = DealerManagementServices.getCAContact(userList);
        }
        if(!CADealerMap.isEmpty() && CADealerMap != null) {
            dealerMap = DealerManagementServices.getDealerMap(dealerIdSet);
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
                if(dealerLastAssignmentFinal.containsKey(dId)) {
                    Account dealer = dealerMap.get(dId);
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
}