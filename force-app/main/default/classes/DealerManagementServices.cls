public class DealerManagementServices {
    public List<DealerSequenceWrapper> dswList {get;set;}
    public Set<String> skillSet {get;set;}
    public String pincode {get;set;}
    public String selectedSkill1 {get;set;}
    public String selectedSkill2 {get;set;}
    public String selectedSkill3 {get;set;}
    
    public List<SelectOption> getSkills {
        get{
            Schema.sObjectType sobject_type = Lead.getSObjectType();  
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('Skills__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>(); 
            options.add(new selectOption('', '--Please Select--'));
            for (Schema.PicklistEntry a : pick_list_values) {
                options.add(new selectOption(a.getLabel(), a.getValue()));
            }
            return options;
        }
        set;
    }
    
    public DealerManagementServices() {
        dswList = new List<DealerSequenceWrapper>();
        skillSet = new Set<String>();
        pincode = '';
        selectedSkill1 = '';
        selectedSkill2 = '';
        selectedSkill3 = '';
    }
    
    public void getDealer() {
        if(selectedSkill1 != '')
            skillSet.add(selectedSkill1);
        if(selectedSkill2 != '')
            skillSet.add(selectedSkill2);
        if(selectedSkill3 != '')
            skillSet.add(selectedSkill3);
        dswList = getDealers(pinCode, skillSet);
    }
    
    public static Map<Id, CADetailWrapper> getCAInfo(String pinCode, Set<String> skillSet, Map<Id, CADetailWrapper> getCADealerMap) {
        system.debug('pinCode::'+pinCode);
        system.debug('skillSet::'+skillSet);
        system.debug('getCADealerMap::'+getCADealerMap);
        Map<Id, CADetailWrapper> CADealerMap = new Map<Id, CADetailWrapper>();
        List<DealerSequenceWrapper> dswList = new List<DealerSequenceWrapper>();
        List<User> userList = new List<User>();
        Map<Id, Contact> CAContactMap = new Map<Id, Contact>();
        
        if(!String.isBlank(pinCode)) {
            dswList = getDealers(pinCode, skillSet);
            system.debug('dswList: '+dswList);
        }
        if(!dswList.isEmpty()) {
            for(DealerSequenceWrapper d: dswList) {
                if(!d.CADetailWrapperList.isEmpty()) {
                    for(CADetailWrapper cdw: d.CADetailWrapperList) {
                    	if(CADealerMap.isEmpty()) {
                            if(getCADealerMap == null) {
                                CADetailWrapper cdWrap = new CADetailWrapper(cdw.CA, d.dealer, cdw.lastLeadAssigned, d.remarksBody);
                                CADealerMap.put(cdw.CA.Id, cdWrap); 
                            } else {
                                if(!getCADealerMap.containsKey(cdw.CA.Id)) {
                                    CADetailWrapper cdWrap = new CADetailWrapper(cdw.CA, d.dealer, cdw.lastLeadAssigned, d.remarksBody);
                                    CADealerMap.put(cdw.CA.Id, cdWrap);
                                }
                            }
                        } else {
                            break;
                        }
                	}
                } else {
                    system.debug('NO CA');
                }
                /*if(CADealerMap.isEmpty()) {
                    system.debug('In If::'+d.CADetailWrapperList);
                    if(!d.CADetailWrapperList.isEmpty() && d.CADetailWrapperList.size() >= 1 ) {
                        if(getCADealerMap == null) {
                            CADetailWrapper cdw = new CADetailWrapper(d.CADetailWrapperList[0].CA, d.dealer, d.CADetailWrapperList[0].lastLeadAssigned, d.remarksBody);
                            CADealerMap.put(d.CADetailWrapperList[0].CA.Id, cdw); 
                        } else {
                            if(!getCADealerMap.containsKey(d.CADetailWrapperList[0].CA.Id)) {
                                CADetailWrapper cdw = new CADetailWrapper(d.CADetailWrapperList[0].CA, d.dealer, d.CADetailWrapperList[0].lastLeadAssigned, d.remarksBody);
                                CADealerMap.put(d.CADetailWrapperList[0].CA.Id, cdw);
                            }
                        }
                    } else {
                        system.debug('NO CA');
                    }
                } else {
                    break;
                }*/
            }
        }
        system.debug('CADealerMap: '+CADealerMap);
        return CADealerMap;
    }
    
    public static List<DealerSequenceWrapper> getDealers(String pinCode, Set<String> skillSet) {
        List<DealerSequenceWrapper> dswList = new List<DealerSequenceWrapper>();
        List<Lead_Serviceability__c> leadServiceList = new List<Lead_Serviceability__c>();
        Map<Id, List<User>> serviceableDealerCAMap = new Map<Id, List<User>>();
        Map<Id, Account> dealerMap = new Map<Id, Account>();
        Map<Id, String> dealerSkillMap = new Map<Id, String>();
        Map<Id, List<User>> dealerCAMap = new Map<Id, List<User>>();
        Map<Id, List<Dealer_Contractor_Mapping__c>> dealerContractorMap = new Map<Id, List<Dealer_Contractor_Mapping__c>>();
        Map<Id, Integer> dealerTotalCapacityMap = new Map<Id, Integer>();
        Map<Id, Integer> dealerWeeklyLimitMap = new Map<Id, Integer>();
        Map<Id, Integer> dealerLastSevenDayLeadCountMap = new Map<Id, Integer>();
        Map<Id, Integer> dealerBlockedCapacitytMap = new Map<Id, Integer>();
        Map<Id, Integer> dealerPipelineLeadMap = new Map<Id, Integer>();
        Map<Id, Integer> dealerPipelineOpportunityMap = new Map<Id, Integer>();
        Map<Id, Integer> dealerSkillBasedScoreMap = new Map<Id, Integer>();
        Map<Id, DateTime> CALastAssignedLeadMap = new Map<Id, DateTime>();
        Map<Id, DateTime> CALastAssignedOpportunityMap = new Map<Id, DateTime>();
        Map<Id, DateTime> dealerLastAssignmentFinal = new Map<Id, DateTime>();
        Map<Id, DateTime> CALastAssignmentFinal = new Map<Id, DateTime>();
        Map<Id, Id> CADealerMap = new Map<Id, Id>();
        List<Dealer_Scoring_Weightage__c> scoreWeightageList = new List<Dealer_Scoring_Weightage__c>();
        
        if(!String.isBlank(pinCode)) {
            serviceableDealerCAMap = getServiceableDealer(pinCode, skillSet);
            
            if(serviceableDealerCAMap != null) {
                dealerMap = getDealerMap(serviceableDealerCAMap.keySet());
                dealerCAMap = serviceableDealerCAMap;
                dealerSkillMap = getDealerSkills(serviceableDealerCAMap.keySet());
                dealerContractorMap = getDealerAllContractors(serviceableDealerCAMap.keySet());
                dealerTotalCapacityMap = getTotalCapacity(serviceableDealerCAMap.keySet());
                dealerLastSevenDayLeadCountMap = getLastSevenDaysLeadCount(serviceableDealerCAMap.keySet());
                dealerWeeklyLimitMap = getWeeklyLimit(serviceableDealerCAMap.keySet());
                dealerBlockedCapacitytMap = getBlockedCapacity(serviceableDealerCAMap.keySet());
                dealerPipelineLeadMap = getPipelineLead(serviceableDealerCAMap.keySet());
                dealerPipelineOpportunityMap = getPipelineOpportunity(serviceableDealerCAMap.keySet());
                dealerSkillBasedScoreMap = getSkillBasedScore(serviceableDealerCAMap.keySet());
                scoreWeightageList = getDealerScoringWeightage();
                
                //Get Last Lead Assignment DateTime//
                if(!dealerCAMap.isEmpty()) {
                    for(Id dealerId: dealerCAMap.keySet()) {
                        List<User> CAList = dealerCAMap.get(dealerId);
                        
                        if(!CAList.isEmpty()) {
                            for(User u: CAList) {
                                CADealerMap.put(u.Id, dealerId);
                            }
                        }
                    }
                    system.debug('CADealerMap: '+CADealerMap);
                    
                    if(!CADealerMap.isEmpty()) {
                        //Get CA Wise Last Assignment DateTime (Lead)
                        CALastAssignedLeadMap = getCALastAssignedLead(CADealerMap.keySet());
                        //Get CA Wise Last Assignment DateTime (Opportunity)
                        CALastAssignedOpportunityMap = getCALastAssignedOpportunity(CADealerMap.keySet());
                        
                        //Get Dealer Wise Last Assignment DateTime (Lead/Opportunity)
                        dealerLastAssignmentFinal = getDealerLastAssigmentFinal(CADealerMap, CALastAssignedLeadMap, CALastAssignedOpportunityMap);
                        //Get CA Wise Last Assignment DateTime(Lead/ Opportunity)
                        CALastAssignmentFinal = getCALastAssigmentFinal(CADealerMap, CALastAssignedLeadMap, CALastAssignedOpportunityMap);
                    }
                }
                
                for(Id dId: serviceableDealerCAMap.keySet()) {
                    if(!dealerMap.isEmpty() && dealerMap.containsKey(dId)) {
                        String skills = '';
                        Integer totalCA = 0;
                        Integer totalContrctor = 0;
                        Integer openLeadCount = 0;
                        Integer openOppCount = 0;
                        Integer lastSevenDayCount = 0;
                        Integer weeklyLimit = 0;
                        Decimal totalCapacity = 0;
                        Decimal openCapacity = 0;
                        Decimal availableCapacity = 0;
                        Decimal CIBoost = 1;
                        Decimal skillBoost = 1;
                        //Decimal calculatedScore = 0;
                        DateTime lastLeadAssigned;
                        List<CADetailWrapper> dealerCAWrapperList = new List<CADetailWrapper>();  
                        
                        if(!dealerSkillMap.isEmpty() && dealerSkillMap.containsKey(dId))
                            skills = dealerSkillMap.get(dId);
                        if(!dealerCAMap.isEmpty() && dealerCAMap.containsKey(dId)) {
                            totalCA = dealerCAMap.get(dId).size();
                            
                            List<User> userList = dealerCAMap.get(dId);
                            if(!userList.isEmpty()) {
                                for(User u: userList) {
                                    DateTime lastCALeadAssigned;
                                    
                                    if(!CALastAssignmentFinal.isEmpty() && CALastAssignmentFinal.containsKey(u.Id))
                                        lastCALeadAssigned = CALastAssignmentFinal.get(u.Id);
                                    
                                    //Add In Wrapper List
                                    dealerCAWrapperList.add(new CADetailWrapper(u, lastCALeadAssigned));
                                }
                                dealerCAWrapperList = getOrderofCA(dealerCAWrapperList);
                            }
                        }
                        if(!dealerContractorMap.isEmpty() && dealerContractorMap.containsKey(dId))
                            totalContrctor = dealerContractorMap.get(dId).size();
                        if(!dealerPipelineLeadMap.isEmpty() && dealerPipelineLeadMap.containsKey(dId))
                            openLeadCount = dealerPipelineLeadMap.get(dId);
                        if(!dealerPipelineOpportunityMap.isEmpty() && dealerPipelineOpportunityMap.containsKey(dId))
                            openOppCount = dealerPipelineOpportunityMap.get(dId);
                        if(!dealerLastSevenDayLeadCountMap.isEmpty() && dealerLastSevenDayLeadCountMap.containsKey(dId))
                            lastSevenDayCount = dealerLastSevenDayLeadCountMap.get(dId);
                        if(!dealerWeeklyLimitMap.isEmpty() && dealerWeeklyLimitMap.containsKey(dId))
                            weeklyLimit = dealerWeeklyLimitMap.get(dId);
                        if(!dealerTotalCapacityMap.isEmpty() && dealerTotalCapacityMap.containsKey(dId))
                            totalCapacity = dealerTotalCapacityMap.get(dId);
                        if(openLeadCount > 0 || openOppCount > 0)
                            openCapacity = (openLeadCount * 0.05) + openOppCount;
                        if(totalCapacity > openCapacity)
                            availableCapacity = totalCapacity - openCapacity;
                        if(!dealerMap.isEmpty() && dealerMap.containsKey(dId))
                            CIBoost = dealerMap.get(dId).Type_Boost__c;
                        if(!dealerSkillBasedScoreMap.isEmpty() && dealerSkillBasedScoreMap.containsKey(dId))
                            skillBoost = skillBoost * (dealerSkillBasedScoreMap.get(dId) * 1);
                        //calculatedScore = availableCapacity + CIBoost + skillBoost;
                        if(!dealerLastAssignmentFinal.isEmpty() && dealerLastAssignmentFinal.containsKey(dId))
                            lastLeadAssigned = dealerLastAssignmentFinal.get(dId);
                        
                        DealerSequenceWrapper dsw = new DealerSequenceWrapper(dealerMap.get(dId), skills, totalCA, totalContrctor, openLeadCount, openOppCount, lastSevenDayCount, weeklyLimit, totalCapacity, openCapacity, availableCapacity, CIBoost, skillBoost, /*calculatedScore,*/ lastLeadAssigned, dealerCAWrapperList, scoreWeightageList);
                        dswList.add(dsw);
                    }
                }
                //Get Ranking based on score
                dswList = getRanking(dswList);
                dswList = getRevisedRanking(dswList);
                dswList.sort();  // let the magic of Comparable do the work
                dswList = getRemarks(dswList);
            } else {
                system.debug('No Dealer');
            }
        } else {
            system.debug('PinCode is Blank');
        }
        return dswList;
    }
    
    /*public static Set<Id> getServiceableDealer(String pinCode, Set<String> skillset) {
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> dealerIdSet = new Set<Id>();
        string ss = '';
        for(string st : skillset){
            ss += st + ';';
        }
        if(string.isNotBlank(ss))
        {
            ss = ss.removeEnd(';');
        }
        //system.debug('ss:'+ss.removeEnd(';'));
        List<SA_Pincode_Mapping__c> pincodeServiceableList = [Select Id, Name, SA__c, Service__c, Skills__c, Pincode__c, Role__c from SA_Pincode_Mapping__c 
                                                              where Pincode__c =: pincode AND Service__c = 'SPS' AND Role__c = 'CA' AND Skills__c IN: skillSet];
        system.debug('pincodeServiceableList: '+pincodeServiceableList);
        
        if(!pincodeServiceableList.isEmpty()) {
            for(SA_Pincode_Mapping__c p: pincodeServiceableList) {
                contactIdSet.add(p.SA__c);
            }
        }
        system.debug('contactIdSet: '+contactIdSet);
        
        if(!contactIdSet.isEmpty()) {
            List<Contact> CAList = [Select Id, Name, AccountId,MobilePhone from Contact
                                    where Id IN: contactIdSet AND Active__c = true];
            system.debug('CAList: '+CAList);
            if(!CAList.isEmpty()) {
                for(Contact c: CAList) {
                    dealerIdSet.add(c.AccountId);
                }
                system.debug('dealerIdSet: '+dealerIdSet);
            }
        }
        return dealerIdSet;
    }*/
    
    public static Map<Id, List<User>> getServiceableDealer(String pinCode, Set<String> skillset) {
        Map<Id, List<User>> serviceableDealerCAMap = new Map<Id, List<User>>();
        Map<Id, Id> CADealerMap = new Map<Id, Id>();
        String ss = '';
        
        for(string st : skillset) {
            ss += st + ';';
        }
        if(string.isNotBlank(ss)) {
            ss = ss.removeEnd(';');
        }
        
        List<SA_Pincode_Mapping__c> pincodeServiceableList = [Select Id, Name, SA__c, SA__r.AccountId, Service__c, Skills__c, Pincode__c, Role__c from SA_Pincode_Mapping__c 
                                                              where Pincode__c =: pincode AND Service__c = 'SPS' AND Role__c = 'CA' AND Skills__c IN: skillSet AND SA__r.Active__c =true];
        
        if(pincodeServiceableList != null) {
            for(SA_Pincode_Mapping__c p: pincodeServiceableList) {
                CADealerMap.put(p.SA__c, p.SA__r.AccountId);
            }
        }
        
        if(CADealerMap != null) {
            List<User> userList = [SELECT Id, ContactId, Name From User Where ContactId IN: CADealerMap.keySet() AND ISActive =True];
            
            if(userList != null) {
                for(User u: userList) {
                    if(!serviceableDealerCAMap.containsKey(CADealerMap.get(u.ContactId))) {
                        List<User> uList = new List<User>();
                        uList.add(u);
                        serviceableDealerCAMap.put(CADealerMap.get(u.ContactId), uList);
                    } else {
                        serviceableDealerCAMap.get(CADealerMap.get(u.ContactId)).add(u);
                    }
                }
            }
        }
        return serviceableDealerCAMap;
    }
    
    /*public static List<Lead_Serviceability__c> getDealers(String pinCode) {
        List<Lead_Serviceability__c> leadServiceList = new List<Lead_Serviceability__c>();
        
        leadServiceList = [Select Id, Name, Dealer__c, Pincode__c from Lead_Serviceability__c
                           where Pincode__c =: pinCode ORDER BY Name ASC];
        
        if(!leadServiceList.isEmpty())
            return leadServiceList;
        else
            return null;
    }*/
    
    public static Map<Id, Account> getDealerMap(Set<Id> dealerIdSet) {
        Map<Id, Account> dealerMap = new Map<Id, Account>();
        Id recId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        system.debug('recId: '+recId);
        
        List<Account> dealerList = [Select Id, Name, Type__c, Number_of_CAs__c, Weekly_Limit_Max__c, Contractors__c, Total_Capacity__c, Type_Boost__c, 
                                    Blocked_Capacity__c, Latest_Assigned_DateTime__c from Account where Id IN: dealerIdSet AND RecordTypeId =: recId];
        system.debug('dealerList: '+dealerList);
        
        if(!dealerList.isEmpty()) {
            for(Account a: dealerList) {
                dealerMap.put(a.Id, a);
            }
            system.debug('dealerMap: '+dealerMap);
        }
        return dealerMap;
    }
    
    public static Map<Id, String> getDealerSkillsNew(Map<Id, List<User>> dealerCAMap, String pincode) {
        Map<Id, String> dealerSkillMap = new Map<Id, String>();
        Map<Id, Id> contactDealerMap = new Map<Id, Id>();
        Set<Id> contactId = new Set<Id>();
        
        for(Id dId: dealerCAMap.keySet()) {
            List<User> uList = dealerCAMap.get(dId);
            
            if(!uList.isEmpty()) {
                for(User u: uList) {
                    contactDealerMap.put(u.ContactId, dId);
                }
            }
        }
        
        if(contactDealerMap != null) {
            List<SA_Pincode_Mapping__c> pincodeServiceableList = [Select Id, Name, Skills__c /*, Sub_Service__c*/ from SA_Pincode_Mapping__c 
                                                                  where SA__c IN: contactDealerMap.keySet() AND Pincode__c =: pincode AND Service__c = 'SPS' AND Role__c = 'CA' AND SA__r.Active__c =true];
            system.debug('pincodeServiceableList: '+pincodeServiceableList);
            
            if(!pincodeServiceableList.isEmpty()) {
                for(SA_Pincode_Mapping__c p :pincodeServiceableList) {
                    if(!dealerSkillMap.containsKey(contactDealerMap.get(p.SA__c))) {
                        dealerSkillMap.put(contactDealerMap.get(p.SA__c), p.Skills__c /*p.Sub_Service__c*/);
                    } else {
                        dealerSkillMap.put(contactDealerMap.get(p.SA__c), contactDealerMap.get(p.SA__c) +', '+ p.Skills__c /*p.Sub_Service__c*/);
                    }
                }
            }
        }
        return dealerSkillMap;
    }
    
    public static Map<Id, String> getDealerSkills(Set<Id> dealerIdSet) {
        Map<Id, String> dealerSkillMap = new Map<Id, String>();
        
        List<Dealer_Service_Mapping__c> dealerServiceList = [Select Id, Name, Dealer__c, Service_ID__c, Service__c, Skills__c from Dealer_Service_Mapping__c
                                                             where Dealer__c IN: dealerIdSet];
        system.debug('dealerServiceList: '+dealerServiceList);
        
        if(!dealerServiceList.isEmpty()) {
            for(Dealer_Service_Mapping__c dsm: dealerServiceList) {
                if(!dealerSkillMap.containsKey(dsm.Dealer__c)) {
                    dealerSkillMap.put(dsm.Dealer__c, dsm.Skills__c);
                } else {
                    dealerSkillMap.put(dsm.Dealer__c, dealerSkillMap.get(dsm.Dealer__c) +', '+ dsm.Skills__c);
                }
            }
            system.debug('dealerSkillMap: '+dealerSkillMap);
        }
        return dealerSkillMap;
    }
    
    public static Map<Id, List<User>> getDealerAllCAs(Set<Id> dealerIdSet) {
        Map<Id, List<User>> dealerCAMap = new Map<Id, List<User>>();
        Map<Id, Id> CADealerMap = new Map<Id, Id>();
        system.debug('in dealer management class get all CAs');
        List<Contact> CAList = [Select Id, Name, AccountId from Contact
                                 where AccountId IN: dealerIdSet AND Active__c = true];
        system.debug('CAList: '+CAList);
        
        if(!CAList.isEmpty()) {
            for(Contact c: CAList) {
                CADealerMap.put(c.Id, c.AccountId);
            }
            system.debug('CADealerMap: '+CADealerMap);
        }
        
        if(!CADealerMap.isEmpty()) {
            List<User> userList = [SELECT Id, ContactId, Name From User Where ContactId IN: CADealerMap.keySet() AND IsActive = true];
            system.debug('userList: '+userList);
            
            if(!userList.isEmpty()) {
                for(User u: userList) {
                    if(!dealerCAMap.containsKey(CADealerMap.get(u.ContactId))) {
                        List<User> uList = new List<User>();
                        uList.add(u);
                        dealerCAMap.put(CADealerMap.get(u.ContactId), uList);
                    } else {
                        dealerCAMap.get(CADealerMap.get(u.ContactId)).add(u);
                    }
                }
                system.debug('dealerCAMap: '+dealerCAMap);
            }
        }
        return dealerCAMap;
    }
    
    public static Map<Id, List<Dealer_Contractor_Mapping__c>> getDealerAllContractors(Set<Id> dealerIdSet) {
        Map<Id, List<Dealer_Contractor_Mapping__c>> dealerContractorMap = new Map<Id, List<Dealer_Contractor_Mapping__c>>();
        Id recId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Contractors').getRecordTypeId();
        
        List<Dealer_Contractor_Mapping__c> dealerContractorList = [Select Id, Dealer__c, Contractor_Capacity__c from Dealer_Contractor_Mapping__c 
                                                                  where Dealer__c IN: dealerIdSet AND Contractor__r.Active__c = true AND Contractor__r.RecordTypeId =: recId
                                                                  AND Relation_Status__c = 'Active'];
        system.debug('dealerContractorList: '+dealerContractorList);
        
        if(!dealerContractorList.isEmpty()) {
            for(Dealer_Contractor_Mapping__c dcm: dealerContractorList) {
                if(!dealerContractorMap.containsKey(dcm.Dealer__c)) {
                    List<Dealer_Contractor_Mapping__c> dcmList = new List<Dealer_Contractor_Mapping__c>();
                    dcmList.add(dcm);
                    dealerContractorMap.put(dcm.Dealer__c, dcmList);
                } else {
                    dealerContractorMap.get(dcm.Dealer__c).add(dcm);
                }
            }
            system.debug('dealerContractorMap: '+dealerContractorMap);
        }
        return dealerContractorMap;
    }
    
    public static Map<Id, Integer> getTotalCapacity(Set<Id> dealerIdSet) {
        Map<Id, Integer> dealerTotalCapacityMap = new Map<Id, Integer>();
        Id recId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Contractors').getRecordTypeId();
        
        List<Dealer_Contractor_Mapping__c> dealerContractorList = [Select Id, Dealer__c, Contractor__r.Capacity__c from Dealer_Contractor_Mapping__c 
                                                                  where Dealer__c IN: dealerIdSet AND Contractor__r.Active__c = true AND Contractor__r.RecordTypeId =: recId
                                                                  AND Relation_Status__c = 'Active'];
        system.debug('dealerContractorList: '+dealerContractorList);
        
        if(!dealerContractorList.isEmpty()) {
            for(Dealer_Contractor_Mapping__c dcm: dealerContractorList) {
                if(!dealerTotalCapacityMap.containsKey(dcm.Dealer__c)) {
                    dealerTotalCapacityMap.put(dcm.Dealer__c, (Integer)dcm.Contractor__r.Capacity__c);
                } else {
                    dealerTotalCapacityMap.put(dcm.Dealer__c, dealerTotalCapacityMap.get(dcm.Dealer__c) + (Integer)dcm.Contractor__r.Capacity__c);
                }
            }
            system.debug('dealerTotalCapacityMap: '+dealerTotalCapacityMap );
        }
        return dealerTotalCapacityMap;
    }
    
    public static Map<Id, Integer> getWeeklyLimit(Set<Id> dealerIdSet) {
        Map<Id, Integer> dealerWeeklyLimitMap = new Map<Id, Integer>();
        
        List<Contact> CAList = [Select Id, Name, AccountId, Weekly_Limit_Max__c from Contact
                                 where AccountId IN: dealerIdSet AND Active__c = true];
        system.debug('CAList: '+CAList);
        
        if(!CAList.isEmpty()) {
            for(Contact c: CAList) {
                if(!dealerWeeklyLimitMap.containsKey(c.AccountId)) {
                    dealerWeeklyLimitMap.put(c.AccountId, (Integer)c.Weekly_Limit_Max__c);
                } else {
                    dealerWeeklyLimitMap.put(c.AccountId, dealerWeeklyLimitMap.get(c.AccountId) + (Integer)c.Weekly_Limit_Max__c);
                }
            }
            system.debug('dealerWeeklyLimitMap: '+dealerWeeklyLimitMap);
        }
        return dealerWeeklyLimitMap;
    }
    
    public static Map<Id, Integer> getLastSevenDaysLeadCount(Set<Id> dealerIdSet) {
        Map<Id, Integer> dealerLastSevenDayLeadCountMap = new Map<Id, Integer>();
        Map<Id, Id> CADealerMap = new Map<Id, Id>();
        Map<Id, Id> userCAMap = new Map<Id, Id>();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Id recOppId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        List<Contact> CAList = [Select Id, Name, AccountId from Contact
                                 where AccountId IN: dealerIdSet AND Active__c = true];
        system.debug('CAList: '+CAList);
        
        if(!CAList.isEmpty()) {
            for(Contact c: CAList) {
                CADealerMap.put(c.Id, c.AccountId);
            }
            system.debug('CADealerMap: '+CADealerMap);
        }
        
        if(!CADealerMap.isEmpty()) {
            List<User> userList = [SELECT Id, Contact.Id, Name From User Where ContactId IN: CADealerMap.keySet()];
            system.debug('userList: '+userList);
            
            if(!userList.isEmpty()) {
                for(User u: userList) {
                    userCAMap.put(u.Id, u.ContactId);
                }
                system.debug('userCAMap: '+userCAMap);
            }
        }
        
        if(!userCAMap.isEmpty()) {
            List<AggregateResult> leadList = [Select OwnerId, Count(Id) leadCount from Lead where OwnerId IN: userCAMap.keySet() AND Owner.ISActive =true
                                              AND RecordTypeId =: recId AND Assigned_DateTime__c = LAST_N_DAYS:6 AND IsConverted = false AND Legacy_Upload__c = false GROUP BY OwnerId];
            system.debug('leadList: '+leadList);
            
            List<AggregateResult> oppList = [Select OwnerId, Count(Id) oppCount from Opportunity where OwnerId IN: userCAMap.keySet() AND Owner.ISActive =true
                                             AND RecordTypeId =: recOppId AND Assigned_DateTime__c = LAST_N_DAYS:6 AND Legacy_Upload__c = false GROUP BY OwnerId];
            system.debug('oppList: '+oppList);
            
            if(!leadList.isEmpty()) {
                for(AggregateResult ag: leadList) {
                    if(!dealerLastSevenDayLeadCountMap.containsKey(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))))) {
                        dealerLastSevenDayLeadCountMap.put(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))), (Integer)ag.get('leadCount'));
                    } else {
                        dealerLastSevenDayLeadCountMap.put(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))), dealerLastSevenDayLeadCountMap.get(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId')))) + (Integer)ag.get('leadCount'));
                    }
                }
            }
            
            if(!oppList.isEmpty()) {
                for(AggregateResult ag: oppList) {
                    if(!dealerLastSevenDayLeadCountMap.containsKey(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))))) {
                        dealerLastSevenDayLeadCountMap.put(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))), (Integer)ag.get('oppCount'));
                    } else {
                        dealerLastSevenDayLeadCountMap.put(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))), dealerLastSevenDayLeadCountMap.get(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId')))) + (Integer)ag.get('oppCount'));
                    }
                }
            }
        }
        return dealerLastSevenDayLeadCountMap;
    }
    
    public static Map<Id, Integer> getBlockedCapacity(Set<Id> dealerIdSet) {
        Map<Id, Integer> dealerBlockedCapacitytMap = new Map<Id, Integer>();
        Map<Id, Id> contractorDealerMap = new Map<Id, Id>();
        Id recId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        List<Dealer_Contractor_Mapping__c> dealerContractorList = [Select Id, Dealer__c, Contractor__c from Dealer_Contractor_Mapping__c where Dealer__c IN: dealerIdSet
                                                                   AND Contractor__r.Active__c = true AND Relation_Status__c = 'Active'];
        system.debug('dealerContractorList: '+dealerContractorList);
        
        if(!dealerContractorList.isEmpty()) {
            for(Dealer_Contractor_Mapping__c dcm: dealerContractorList) {
                contractorDealerMap.put(dcm.Contractor__c, dcm.Dealer__c);
            }
            system.debug('contractorDealerMap: '+contractorDealerMap);
        }
        
        if(!contractorDealerMap.isEmpty()) {
            List<AggregateResult> oppList = [Select Primary_Contractor__c, Count(Id) oppCount from Opportunity where Primary_Contractor__c IN: contractorDealerMap.keySet()
                                              AND RecordTypeId =: recId AND Is_Active__c = true AND Legacy_Upload__c = false GROUP BY Primary_Contractor__c];
            system.debug('oppList: '+oppList);
            
            if(!oppList.isEmpty()) {
                for(AggregateResult ag: oppList) {
                    if(!dealerBlockedCapacitytMap.containsKey(contractorDealerMap.get((Id)ag.get('Primary_Contractor__c')))) {
                        dealerBlockedCapacitytMap.put(contractorDealerMap.get((Id)ag.get('Primary_Contractor__c')), (Integer)ag.get('oppCount'));
                    } else {
                        dealerBlockedCapacitytMap.put(contractorDealerMap.get((Id)ag.get('Primary_Contractor__c')), dealerBlockedCapacitytMap.get(contractorDealerMap.get((Id)ag.get('Primary_Contractor__c'))) + (Integer)ag.get('oppCount'));
                    }
                }
            }
        }
        return dealerBlockedCapacitytMap;
    }
    
    public static Map<Id, Integer> getPipelineLead(Set<Id> dealerIdSet) {
        Map<Id, Integer> dealerPipelineLeadMap = new Map<Id, Integer>();
        Map<Id, Id> CADealerMap = new Map<Id, Id>();
        Map<Id, Id> userCAMap = new Map<Id, Id>();
        Id recId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        List<Contact> CAList = [Select Id, Name, AccountId from Contact
                                 where AccountId IN: dealerIdSet AND Active__c = true];
        system.debug('CAList: '+CAList);
        
        if(!CAList.isEmpty()) {
            for(Contact c: CAList) {
                CADealerMap.put(c.Id, c.AccountId);
            }
            system.debug('CADealerMap: '+CADealerMap);
        }
        
        if(!CADealerMap.isEmpty()) {
            List<User> userList = [SELECT Id, Contact.Id, Name From User Where ContactId IN: CADealerMap.keySet()];
            system.debug('userList: '+userList);
            
            if(!userList.isEmpty()) {
                for(User u: userList) {
                    userCAMap.put(u.Id, u.ContactId);
                }
                system.debug('userCAMap: '+userCAMap);
            }
        }
        
        if(!userCAMap.isEmpty()) {
            List<AggregateResult> leadList = [Select OwnerId, Count(Id) leadCount from Lead where OwnerId IN: userCAMap.keySet() AND Owner.ISActive =true
                                              AND RecordTypeId =: recId AND Status != 'Lost' AND IsConverted = false AND Legacy_Upload__c = false GROUP BY OwnerId];
            system.debug('leadList: '+leadList);
            
            if(!leadList.isEmpty()) {
                for(AggregateResult ag: leadList) {
                    if(!dealerPipelineLeadMap.containsKey(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))))) {
                        dealerPipelineLeadMap.put(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))), (Integer)ag.get('leadCount'));
                    } else {
                        dealerPipelineLeadMap.put(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))), dealerPipelineLeadMap.get(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId')))) + (Integer)ag.get('leadCount'));
                    }
                }
            }
        }
        return dealerPipelineLeadMap;
    }
    
    public static Map<Id, Integer> getPipelineOpportunity(Set<Id> dealerIdSet) {
        Map<Id, Integer> dealerPipelineOpportunityMap = new Map<Id, Integer>();
        Map<Id, Id> CADealerMap = new Map<Id, Id>();
        Map<Id, Id> userCAMap = new Map<Id, Id>();
        Id recId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        List<Contact> CAList = [Select Id, Name, AccountId from Contact
                                 where AccountId IN: dealerIdSet AND Active__c = true];
        system.debug('CAList: '+CAList);
        
        if(!CAList.isEmpty()) {
            for(Contact c: CAList) {
                CADealerMap.put(c.Id, c.AccountId);
            }
            system.debug('CADealerMap: '+CADealerMap);
        }
        
        if(!CADealerMap.isEmpty()) {
            List<User> userList = [SELECT Id, Contact.Id, Name From User Where ContactId IN: CADealerMap.keySet()];
            system.debug('userList: '+userList);
            
            if(!userList.isEmpty()) {
                for(User u: userList) {
                    userCAMap.put(u.Id, u.ContactId);
                }
                system.debug('userCAMap: '+userCAMap);
            }
        }
        
        if(!userCAMap.isEmpty()) {
            List<AggregateResult> oppList = [Select OwnerId, Count(Id) oppCount from Opportunity where OwnerId IN: userCAMap.keySet() AND Owner.ISActive =true
                                              AND RecordTypeId =: recId AND Is_Active__c = true AND Legacy_Upload__c = false GROUP BY OwnerId];
            system.debug('oppList: '+oppList);
            
            if(!oppList.isEmpty()) {
                for(AggregateResult ag: oppList) {
                    if(!dealerPipelineOpportunityMap.containsKey(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))))) {
                        dealerPipelineOpportunityMap.put(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))), (Integer)ag.get('oppCount'));
                    } else {
                        dealerPipelineOpportunityMap.put(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId'))), dealerPipelineOpportunityMap.get(CADealerMap.get(userCAMap.get((Id)ag.get('OwnerId')))) + (Integer)ag.get('oppCount'));
                    }
                }
            }
        }
        return dealerPipelineOpportunityMap;
    }
    
    public static Map<Id, Integer> getSkillBasedScore(Set<Id> dealerSetId) {
        Map<Id, Integer> dealerSkillBasedScoreMap = new Map<Id, Integer>();
        
        for(Id dId: dealerSetId) {
            dealerSkillBasedScoreMap.put(dId, 1);
        }
        /*List<Dealer_Service_Mapping__c> dealerServiceList = [Select Id, Name, Dealer__c, Service_ID__c, Service_ID__r.Service__c, Service_ID__r.Skills__c from Dealer_Service_Mapping__c
                                                             where Dealer__c IN: dealerSetId AND Service_ID__r.Skills__c IN: skillSet];
        system.debug('dealerServiceList: '+dealerServiceList);
        
        if(!dealerServiceList.isEmpty()) {
            for(Dealer_Service_Mapping__c dsm: dealerServiceList) {
                if(!dealerSkillBasedScoreMap.containsKey(dsm.Dealer__c)) {
                    dealerSkillBasedScoreMap.put(dsm.Dealer__c, 1);
                } else {
                    dealerSkillBasedScoreMap.put(dsm.Dealer__c, dealerSkillBasedScoreMap.get(dsm.Dealer__c) + 1);
                }
            }
        }*/
        return dealerSkillBasedScoreMap;
    }
    
    public static Map<Id, DateTime> getCALastAssignedLead(Set<Id> uIdSet) {
        Map<Id, DateTime> CALastAssignedLeadMap = new Map<Id, DateTime>();
        
        List<AggregateResult> leadList = [Select OwnerId, MAX(Assigned_DateTime__c) lastLeadDate from Lead
                                         where OwnerId IN: uIdSet AND Owner.ISActive =true AND IsConverted = false AND Legacy_Upload__c = false GROUP BY OwnerId];
        system.debug('leadList: '+leadList);
        
        if(!leadList.isEmpty()) {
            for(AggregateResult ag: leadList) {
                if(!CALastAssignedLeadMap.containsKey((Id)ag.get('OwnerId'))) {
                    CALastAssignedLeadMap.put((Id)ag.get('OwnerId'), (DateTime)ag.get('lastLeadDate'));
                } else {
                    CALastAssignedLeadMap.put((Id)ag.get('OwnerId'), (DateTime)ag.get('lastLeadDate'));
                }
            }
            system.debug('CALastAssignedLeadMap: '+CALastAssignedLeadMap);
        }
        return CALastAssignedLeadMap;
    }
    
    public static Map<Id, DateTime> getCALastAssignedOpportunity(Set<Id> uIdSet) {
        Map<Id, DateTime> CALastAssignedOpportunityMap = new Map<Id, DateTime>();
        
        List<AggregateResult> oppList = [Select OwnerId, MAX(Assigned_DateTime__c) lastOpportunityDate from Opportunity
                                         where OwnerId IN: uIdSet AND Owner.ISActive =true AND Legacy_Upload__c = false GROUP BY OwnerId];
        system.debug('oppList: '+oppList);
        
        if(!oppList.isEmpty()) {
            for(AggregateResult ag: oppList) {
                if(!CALastAssignedOpportunityMap.containsKey((Id)ag.get('OwnerId'))) {
                    CALastAssignedOpportunityMap.put((Id)ag.get('OwnerId'), (DateTime)ag.get('lastOpportunityDate'));
                } else {
                    CALastAssignedOpportunityMap.put((Id)ag.get('OwnerId'), (DateTime)ag.get('lastOpportunityDate'));
                }
            }
            system.debug('CALastAssignedOpportunityMap: '+CALastAssignedOpportunityMap);
        }
        return CALastAssignedOpportunityMap;
    }
    
    public static Map<Id, DateTime> getDealerLastAssigmentFinal(Map<Id, Id> CADealerMap, Map<Id, DateTime> CALastAssignedLeadMap, Map<Id, DateTime> CALastAssignedOpportunityMap) {
        Map<Id, DateTime> dealerLastAssignmentFinal = new Map<Id, DateTime>();
        
        for(Id uId: CADealerMap.keySet()) {
            if(CALastAssignedLeadMap.containsKey(uId)) {
                if(!dealerLastAssignmentFinal.containsKey(CADealerMap.get(uId))) {
                    dealerLastAssignmentFinal.put(CADealerMap.get(uId), CALastAssignedLeadMap.get(uId));
                } else {
                    DateTime prevDateTime = dealerLastAssignmentFinal.get(CADealerMap.get(uId));
                    if(prevDateTime < CALastAssignedLeadMap.get(uId))
                        dealerLastAssignmentFinal.put(CADealerMap.get(uId), CALastAssignedLeadMap.get(uId));
                }
            }
            if(CALastAssignedOpportunityMap.containsKey(uId)) {
                if(!dealerLastAssignmentFinal.containsKey(CADealerMap.get(uId))) {
                    dealerLastAssignmentFinal.put(CADealerMap.get(uId), CALastAssignedOpportunityMap.get(uId));
                } else {
                    DateTime prevDateTime = dealerLastAssignmentFinal.get(CADealerMap.get(uId));
                    if(prevDateTime < CALastAssignedOpportunityMap.get(uId))
                        dealerLastAssignmentFinal.put(CADealerMap.get(uId), CALastAssignedOpportunityMap.get(uId));
                }
            }
        }
        system.debug('dealerLastAssignmentFinal: '+dealerLastAssignmentFinal);
        return dealerLastAssignmentFinal;
    }
    
     public static Map<Id, DateTime> getCALastAssigmentFinal(Map<Id, Id> CADealerMap, Map<Id, DateTime> CALastAssignedLeadMap, Map<Id, DateTime> CALastAssignedOpportunityMap) {
        Map<Id, DateTime> CALastAssignmentFinal = new Map<Id, DateTime>();
        
        for(Id uId: CADealerMap.keySet()) {
            if(CALastAssignedLeadMap.containsKey(uId)) {
                if(!CALastAssignmentFinal.containsKey(uId)) {
                    CALastAssignmentFinal.put(uId, CALastAssignedLeadMap.get(uId));
                } else {
                    DateTime prevDateTime = CALastAssignmentFinal.get(uId);
                    if(prevDateTime < CALastAssignedLeadMap.get(uId))
                        CALastAssignmentFinal.put(uId, CALastAssignedLeadMap.get(uId));
                }
            }
            if(CALastAssignedOpportunityMap.containsKey(uId)) {
                if(!CALastAssignmentFinal.containsKey(uId)) {
                    CALastAssignmentFinal.put(uId, CALastAssignedOpportunityMap.get(uId));
                } else {
                    DateTime prevDateTime = CALastAssignmentFinal.get(uId);
                    if(prevDateTime < CALastAssignedOpportunityMap.get(uId))
                        CALastAssignmentFinal.put(uId, CALastAssignedOpportunityMap.get(uId));
                }
            }
        }
        system.debug('CALastAssignmentFinal: '+CALastAssignmentFinal);
        return CALastAssignmentFinal;
    }
    
    public static Map<Id, Contact> getCAContact(List<User> userList) {
        Map<Id, Contact> CAContactMap = new Map<Id, Contact>();
        Map<Id, contact> contactMap = new Map<Id, Contact>();
        List<Contact> contactList = new List<Contact>();
        Set<Id> contactIdSet = new Set<Id>();
        
        if(!userList.isEmpty() && userList != null) {
            for(User u: userList) {
                contactIdSet.add(u.ContactId);
            }
        }
        if(!contactIdSet.isEmpty() && contactIdSet != null) {
            contactList = [Select Id, Name, AccountId, Latest_Assigned_DateTime__c, Active__c, PositionID__c, Employee_Code__c from Contact where Id IN: contactIdSet AND Active__c = true];
            system.debug('contactList: '+contactList);
            
            if(!contactList.isEmpty() && contactList != null) {
                for(Contact c: contactList) {
                    contactMap.put(c.Id, c);
                }
            }
            
            for(User u: userList) {
                if(contactMap.containsKey(u.ContactId))
                    CAContactMap.put(u.Id, contactMap.get(u.ContactId));
            }
        }
        return CAContactMap;
    }
    
    public static List<DealerSequenceWrapper> getRanking(List<DealerSequenceWrapper> dswList) {
        Integer n = dswList.size();
        DealerSequenceWrapper dswTemp = new DealerSequenceWrapper();
        
        if(n > 1) {
            for (Integer i = 0; i < n; i++) {
                for (Integer j = 1; j < (n-i); j++) {   
                    // Sort by totalScore of dealer
                    
                    if(dswList[j-1].totalScore == dswList[j].totalScore) {
                        // Changes for Same Score //
                        if(dswList[j-1].secondsLastLeadAssigned < dswList[j].secondsLastLeadAssigned) {
                            dswList[j-1].rank = j;
                            dswList[j].rank = j+1;
                        } else if(dswList[j-1].secondsLastLeadAssigned > dswList[j].secondsLastLeadAssigned) {
                            dswList[j-1].rank = j+1;
                            dswList[j].rank = j;
                            
                            //swap elements  
                            /*dswTemp = dswList[j-1];  
                            dswList[j-1] = dswList[j];  
                            dswList[j] = dswTemp;*/
                        } else {
                            dswList[j-1].rank = j;
                            dswList[j].rank = j;
                        }
                        // Changes for Same Score //
                    } else if(dswList[j-1].totalScore < dswList[j].totalScore) {
                        dswList[j-1].rank = j+1;
                        dswList[j].rank = j;
                        
                        //swap elements  
                        /*dswTemp = dswList[j-1];  
                        dswList[j-1] = dswList[j];  
                        dswList[j] = dswTemp;*/
                    } else {
                        dswList[j-1].rank = j;
                        dswList[j].rank = j+1;
                    }
                }
            }
        } else {
            dswList[0].rank = n;
        }
        
        //Change the ranking for max lead limit reached dealer
        for (Integer i = 0; i < n; i++) {
            if(dswList[i].maxLeadLimit == true) {
                system.debug('Dealer: '+dswList[i].dealer.Name);
                dswList[i].rank = dswList[i].rank + n;
            }
        }
        return dswList;
    }
    
    public static List<DealerSequenceWrapper> getRevisedRanking(List<DealerSequenceWrapper> dswList) {
        Integer n = dswList.size();
        DealerSequenceWrapper dswTemp = new DealerSequenceWrapper();
        
        if(n > 1) {
            for (Integer i = 0; i < n; i++) {
                for (Integer j = 1; j < (n-i); j++) {
                    //Sorting by revisedTotalScore of dealer
                    if(dswList[j-1].revisedTotalScore == dswList[j].revisedTotalScore) {
                        // Changes for Same Score //
                        if(dswList[j-1].secondsLastLeadAssigned < dswList[j].secondsLastLeadAssigned) {
                            dswList[j-1].revisedRank = j;
                            dswList[j].revisedRank = j+1;
                        } else if(dswList[j-1].secondsLastLeadAssigned > dswList[j].secondsLastLeadAssigned) {
                            dswList[j-1].revisedRank = j+1;
                            dswList[j].revisedRank = j;
                            
                            //swap elements  
                            dswTemp = dswList[j-1];  
                            dswList[j-1] = dswList[j];  
                            dswList[j] = dswTemp;
                        } else {
                            dswList[j-1].revisedRank = j;
                            dswList[j].revisedRank = j;
                        }
                        // Changes for Same Score //
                    } else if(dswList[j-1].revisedTotalScore < dswList[j].revisedTotalScore) {
                        dswList[j-1].revisedRank = j+1;
                        dswList[j].revisedRank = j;
                        
                        //swap elements  
                        dswTemp = dswList[j-1];  
                        dswList[j-1] = dswList[j];  
                        dswList[j] = dswTemp;
                    } else {
                        dswList[j-1].revisedRank = j;
                        dswList[j].revisedRank = j+1;
                    }
                }
            }
        } else {
            dswList[0].revisedRank = n;
        }
        
        //Change the ranking for max lead limit reached dealer
        for (Integer i = 0; i < n; i++) {
            if(dswList[i].maxLeadLimit == true) {
                system.debug('Dealer: '+dswList[i].dealer.Name);
                dswList[i].revisedRank = dswList[i].revisedRank + n;
            }
        }
        return dswList;
    }
    
    public static List<DealerSequenceWrapper> getRemarks(List<DealerSequenceWrapper> dswList) {
        String htmlBody = '';
        htmlBody = '<table border="1" style="border-collapse: collapse">'+
                 + '<tr>'+
                 + '<th>Dealer</th>'+
                 + '<th>Type</th>'+
                 + '<th>No. of CA</th>'+
                 + '<th>Contractor</th>'+
                 + '<th>Open Leads</th>'+
                 + '<th>Open Opportunities</th>'+
                 + '<th>Last 7 Day Count</th>'+
                 + '<th>Max Lead Count</th>'+
                 + '<th>Total Capacity</th>'+
                 + '<th>Open + Pipeline</th>'+
                 + '<th>Available Capacity</th>'+
                 + '<th>CI Boost</th>'+
                 + '<th>Skill Boost</th>'+
                 + '<th>Days Since Last Recived (Days)</th>'+
                 + '<th>Seconds</th>'+
                 + '<th>Last Assignment DateTime</th>'+
                 + '<th>Rank with Max Limit</th>'+
                 + '<th>Revised Total Score Without Limit + Weightage Added</th>'+
                 + '<th>Revised Rank</th>'+
                 + '</tr>';
        
        for(DealerSequenceWrapper d: dswList) {
            htmlBody += '<tr>'+
                      + '<td>'+ d.dealer.Name +'</td>'+
                      + '<td>'+ d.dealer.Type__c +'</td>'+
                      + '<td>'+ d.totalCA +'</td>'+
                      + '<td>'+ d.totalContractors +'</td>'+
                      + '<td>'+ d.openLeads +'</td>'+
                      + '<td>'+ d.openOpportunities +'</td>'+
                      + '<td>'+ d.lastSevenDayCount +'</td>'+
                      + '<td>'+ d.maxLeadLimit +'</td>'+
                      + '<td>'+ d.totalCapacity +'</td>'+
                      + '<td>'+ d.openPipeline +'</td>'+
                      + '<td>'+ d.availableCapacity +'</td>'+
                      + '<td>'+ d.CIBoost +'</td>'+
                      + '<td>'+ d.skillBoost +'</td>'+
                      + '<td>'+ d.daysLastLeadAssigned +'</td>'+
                      + '<td>'+ d.secondsLastLeadAssigned +'</td>'+
                      + '<td>'+ d.lastLeadAssignedFormat +'</td>'+
                      + '<td>'+ d.Rank +'</td>'+
                      + '<td>'+ d.revisedTotalScore +'</td>'+
                      + '<td>'+ d.revisedRank +'</td>'+
                      + '</tr>';
        }
        htmlBody += '</table>';
        
        for(DealerSequenceWrapper d: dswList) {
            d.remarksBody = htmlBody;
        }
        return dswList;
    }
    
    public static List<CADetailWrapper> getOrderofCA(List<CADetailWrapper> dealerCAWrapperList) {
        Integer n = dealerCAWrapperList.size();
        CADetailWrapper dswTemp = new CADetailWrapper();
        
        for (Integer i = 0; i < n; i++) {
            for (Integer j = 1; j < (n-i); j++) {
                //Sorting by revisedTotalScore of dealer
                if(dealerCAWrapperList[j-1].lastLeadAssigned > dealerCAWrapperList[j].lastLeadAssigned || dealerCAWrapperList[j].lastLeadAssigned == null) {
                    //swap elements  
                    dswTemp = dealerCAWrapperList[j-1];  
                    dealerCAWrapperList[j-1] = dealerCAWrapperList[j];  
                    dealerCAWrapperList[j] = dswTemp;
                }
            }
        }
        return dealerCAWrapperList;
    }
    
    public static Account getDealer(String Dealer_Code) {
        Id recId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        
        List<Account> dealerList = [Select Id, Name, Type__c, Number_of_CAs__c, Weekly_Limit_Max__c, Contractors__c, Total_Capacity__c, Type_Boost__c, 
                                    Blocked_Capacity__c, Latest_Assigned_DateTime__c from Account where Dealer_Code__c =: Dealer_Code AND RecordTypeId =: recId];
        system.debug('dealerList: '+dealerList);
        
        if(!dealerList.isEmpty())
            return dealerList[0];
        else
            return null;
    }
    
    public static List<Dealer_Scoring_Weightage__c> getDealerScoringWeightage() {
        List<Dealer_Scoring_Weightage__c> scoreWeightageList = [Select Id, Name, Available_Capacity__c, CI_Boost__c, Seconds_Since_Last_Received__c, Active__c 
                                                                from Dealer_Scoring_Weightage__c where Active__c = true];
        
        if(scoreWeightageList != null)
            return scoreWeightageList;
        else
            return null;
    }
    
    public class DealerSequenceWrapper implements Comparable {
        public Account dealer {get;set;}
        public String skills {get;set;} 
        public Integer totalCA {get;set;}
        public Integer totalContractors {get;set;}
        public Integer openLeads {get;set;}
        public Integer openOpportunities {get;set;}
        public Integer lastSevenDayCount {get;set;}
        public Integer weeklyLeadLimit {get;set;}
        public Boolean maxLeadLimit {get;set;}
        public Decimal totalCapacity {get;set;}
        public Decimal openPipeline {get;set;}
        public Decimal availableCapacity {get;set;}
        public Decimal CIBoost {get;set;}
        public Decimal skillBoost {get;set;}
        public Integer daysLastLeadAssigned {get;set;}
        public Long secondsLastLeadAssigned {get;set;}
        public Decimal totalScore {get;set;}
        public DateTime lastLeadAssigned {get;set;}
        public String lastLeadAssignedFormat {get;set;}
        public List<CADetailWrapper> CADetailWrapperList {get;set;}
        public Integer rank {get;set;}
        public Decimal revisedTotalScore {get;set;}
        public Integer revisedRank {get;set;}
        public String remarksBody {get;set;}
        
        public DealerSequenceWrapper() {}
        
        public DealerSequenceWrapper(Account d, String skills, Integer totalCA, Integer totalCont, Integer leadCount, Integer oppCount, Integer lastSevenDayCount, Integer weeklyLimit, Decimal totalCap, Decimal openPipe, Decimal availableCap, Decimal isCI, Decimal isSkill, /*Decimal total,*/ DateTime lastLeadAssigned, List<CADetailWrapper> CAList, List<Dealer_Scoring_Weightage__c> scoreWeightageList) {
            this.dealer = d;
            this.skills = skills;
            this.totalCA = totalCA;
            this.totalContractors = totalCont;
            this.openLeads = leadCount;
            this.openOpportunities = oppCount;
            this.lastSevenDayCount = lastSevenDayCount;
            this.weeklyLeadLimit = weeklyLimit; 
            if(lastSevenDayCount > weeklyLeadLimit)
                this.maxLeadLimit = true;
            else
                this.maxLeadLimit = false;
            this.totalCapacity = totalCap;
            this.openPipeline = openPipe;
            this.availableCapacity = availableCap;
            this.CIBoost = isCI; 
            this.skillBoost = isSkill;
            //this.totalScore = total;
            this.lastLeadAssigned = lastLeadAssigned;
            if(lastLeadAssigned != null) {
                this.daysLastLeadAssigned = lastLeadAssigned.date().daysBetween(system.today());
                this.lastLeadAssignedFormat = lastLeadAssigned.Format();
                this.secondsLastLeadAssigned = ((system.now().getTime() - lastLeadAssigned.getTime()) / 1000);
            } else {
                this.daysLastLeadAssigned = 0;
                this.lastLeadAssignedFormat = 'NA';
                this.secondsLastLeadAssigned = 100000000; //Default Value for New Dealer
            }
            this.CADetailWrapperList = CAList;
            this.totalScore = availableCapacity * CIBoost * secondsLastLeadAssigned;
            if(!scoreWeightageList.isEmpty())
                this.revisedTotalScore = ((availableCapacity * (scoreWeightageList[0].Available_Capacity__c/100)) + (CIBoost * (scoreWeightageList[0].CI_Boost__c/100)) + (secondsLastLeadAssigned * (scoreWeightageList[0].Seconds_Since_Last_Received__c/100))); //+ (skillBoost * 0.4)
            else
                this.revisedTotalScore = (availableCapacity + CIBoost + secondsLastLeadAssigned);
        }
        
        public Integer compareTo(Object other) {
            DealerSequenceWrapper o = (DealerSequenceWrapper)other;
            if ( this.revisedRank == o.revisedRank) {
                return 0;
            }
            return (this.revisedRank < o.revisedRank) ? -1 : 1;
        }
    }
    
    public class CADetailWrapper {
        public User CA {get;set;}
        public Account Dealer {get;set;}
        public DateTime lastLeadAssigned {get;set;}
        public String lastLeadAssignedFormat {get;set;}
        public String dealerAllocationRemarks {get;set;}
        
        public CADetailWrapper() {}
        
        public CADetailWrapper(User u, DateTime lastLeadAssigned) {
            this.CA = u;
            this.lastLeadAssigned = lastLeadAssigned;
            if(lastLeadAssigned != null)
                this.lastLeadAssignedFormat = lastLeadAssigned.Format();
            else
                this.lastLeadAssignedFormat = 'NA';
        }
        
        public CADetailWrapper(User u, Account d, DateTime lastLeadAssigned, String remarks) {
            this.CA = u;
            this.Dealer = d;
            this.lastLeadAssigned = lastLeadAssigned;
            this.dealerAllocationRemarks = remarks;
        }
        public CADetailWrapper(User u, Account d, String remarks) {
            this.CA = u;
            this.Dealer = d;
            this.dealerAllocationRemarks = remarks;
        }
    }
}