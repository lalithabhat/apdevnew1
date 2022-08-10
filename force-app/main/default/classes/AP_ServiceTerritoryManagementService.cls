/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 28-09-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all Service Territory services.
*********************************************************************************************************/
public class AP_ServiceTerritoryManagementService {
    public static Map<String, Service_Territory__c> getTerritoryforSPS(Set<String> pincode) {
        Map<String, Service_Territory__c> serviceTerritoryMapForSPS = new Map<String, Service_Territory__c>();
        List<Service_Territory__c> serviceTerritoryList = [Select Id, Name, Type__c, Pincode__c, Pincode__r.Name, Parent__r.Id, Parent__r.Name,
                                                           Parent__c, Parent__r.HOD__c, Parent__r.HOD__r.PositionID__c, Parent__r.Type__c, 
                                                           Parent__r.Parent__c, Parent__r.Parent__r.HOD__c, Parent__r.Parent__r.HOD__r.PositionID__c, Parent__r.Parent__r.Type__c,
                                                           Parent__r.Parent__r.Parent__c, Parent__r.Parent__r.Parent__r.HOD__c, Parent__r.Parent__r.Parent__r.HOD__r.PositionID__c, Parent__r.Parent__r.Parent__r.Type__c,
                                                           Parent__r.Parent__r.Parent__r.Parent__c, Parent__r.Parent__r.Parent__r.Parent__r.HOD__c, Parent__r.Parent__r.Parent__r.Parent__r.HOD__r.PositionID__c, Parent__r.Parent__r.Parent__r.Parent__r.Type__c
                                                           from Service_Territory__c
                                                           where Pincode__r.Name IN: pincode AND Type__c = 'Pincode' AND Active__c = true AND
                                                           Parent__r.Parent__r.Parent__r.Parent__r.Name = 'SPS' AND Parent__r.Parent__r.Parent__r.Parent__r.Type__c = 'Service'];
        
        if(!serviceTerritoryList.isEmpty()) {
            for(Service_Territory__c st: serviceTerritoryList) {
                serviceTerritoryMapForSPS.put(st.Pincode__r.Name, st);
            }    
        }
        return serviceTerritoryMapForSPS;
    }
    
    public static Map<String, Service_Territory__c> getTerritoryforBHS(Set<String> pincode) {
        Map<String, Service_Territory__c> serviceTerritoryMapForBHS = new Map<String, Service_Territory__c>();
        List<Service_Territory__c> serviceTerritoryList = [Select Id, Name, Type__c, Pincode__c, Pincode__r.Name, Parent__r.Id, Parent__r.Name,
                                                           Parent__c, Parent__r.HOD__c, Parent__r.Type__c, 
                                                           Parent__r.Parent__c, Parent__r.Parent__r.HOD__c, Parent__r.Parent__r.Type__c,
                                                           Parent__r.Parent__r.Parent__c, Parent__r.Parent__r.Parent__r.HOD__c, Parent__r.Parent__r.Parent__r.Type__c,
                                                           Parent__r.Parent__r.Parent__r.Parent__c, Parent__r.Parent__r.Parent__r.Parent__r.HOD__c, Parent__r.Parent__r.Parent__r.Parent__r.Type__c
                                                           //Parent__r.Parent__r.Parent__r.Parent__c, Parent__r.Parent__r.Parent__r.Parent__r.HOD__c, Parent__r.Parent__r.Parent__r.Parent__r.Type__c
                                                           from Service_Territory__c
                                                           where Pincode__r.Name IN: pincode AND Type__c = 'Pincode' AND Active__c = true AND
                                                           Parent__r.Parent__r.Parent__r.Parent__r.Name = 'BHS' AND Parent__r.Parent__r.Parent__r.Parent__r.Type__c = 'Service'];
        
        if(!serviceTerritoryList.isEmpty()) {
            for(Service_Territory__c st: serviceTerritoryList) {
                serviceTerritoryMapForBHS.put(st.Pincode__r.Name, st);
            }    
        }
        return serviceTerritoryMapForBHS;
    }
    
    public static Id getTeamLead1(Id userId, String pincode, String skill) {
        List<SA_Pincode_Mapping__c> pincodeList = [Select Id, Pincode__c, TL1__c, Service__c, Skills__c, SA__c, Role__c from SA_Pincode_Mapping__c
                                                  where Pincode__c =: pincode AND SA__c =: userId AND Service__c = 'SPS' AND Skills__c =: skill];
        
        if(!pincodeList.isEmpty()) {
            if(pincodeList[0].TL1__c != null)
                return getUserId(pincodeList[0].TL1__c).Id;
            else
                return null;
        } else {
            return null;
        }
    }
    
    public static Id getTeamLead2(Id userId, String pincode, String skill) {
        List<SA_Pincode_Mapping__c> pincodeList = [Select Id, Pincode__c, TL2__c, Service__c, Skills__c, SA__c, Role__c from SA_Pincode_Mapping__c
                                                  where Pincode__c =: pincode AND SA__c =: userId AND Service__c = 'SPS' AND Skills__c =: skill];
        
        if(!pincodeList.isEmpty()) {
            if(pincodeList[0].TL2__c != null)
                return getUserId(pincodeList[0].TL2__c).Id;
            else
                return null;
        } else {
            return null;
        }
    }
    
    public static Map<String, Id> getTeamLeadInfo(Set<Id> userIdSet, Set<String> pincodeSet, Set<String> skillSet) {
        Map<String, Id> teamLeadMap = new Map<String, Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id, User> contactIdUserMap = new Map<Id, User>();
        List<SA_Pincode_Mapping__c> pincodeList = [Select Id, Pincode__c, TL1__c, TL2__c, Service__c, Skills__c, SA__c, SA__r.Id, Role__c from SA_Pincode_Mapping__c
                                                  where Pincode__c =: pincodeSet AND SA__c =: userIdSet AND Service__c = 'SPS' AND Skills__c =: skillSet];
        
        if(pincodeList != null) {
            for(SA_Pincode_Mapping__c p: pincodeList) {
                if(p.TL1__c != null)
                    contactIdSet.add(p.TL1__c);
                if(p.TL2__c != null)
                    contactIdSet.add(p.TL2__c);
            }
            if(!contactIdSet.isEmpty() && contactIdSet != null)
                contactIdUserMap = getUserIdBHS(contactIdSet);
            
            if(!contactIdUserMap.isEmpty() && contactIdUserMap != null) {
                for(SA_Pincode_Mapping__c p: pincodeList) {
                    if(contactIdUserMap.containsKey(p.TL1__c))
                    	teamLeadMap.put(p.SA__r.Id+''+p.Pincode__c+''+p.Skills__c+'TL1', contactIdUserMap.get(p.TL1__c).Id);
                    if(contactIdUserMap.containsKey(p.TL2__c))
                    	teamLeadMap.put(p.SA__r.Id+''+p.Pincode__c+''+p.Skills__c+'TL2', contactIdUserMap.get(p.TL2__c).Id);
                }
            }
        }
        return teamLeadMap;
    }
    
    public static Map<String, Map<String, User>> getHODForSPS(Set<String> pincode) {
        Map<String, Map<String, User>> pincodeHODMapForSPS = new Map<String, Map<String, User>>();
        Map<String, Service_Territory__c> serviceTerritoryMapForSPS = getTerritoryforSPS(pincode);
        Set<String> positionIdSet = new Set<String>();
        Map<String, User> positionIdUserMap = new Map<String, User>();
        
        for(String p: pincode) {
            if(serviceTerritoryMapForSPS.containsKey(p)) {
                Service_Territory__c stObj = serviceTerritoryMapForSPS.get(p);
                
                if(stObj.Parent__c != null && stObj.Parent__r.HOD__c != null && stObj.Parent__r.HOD__r.PositionID__c != null)
                    positionIdSet.add(stObj.Parent__r.HOD__r.PositionID__c);
                if(stObj.Parent__r.Parent__c != null && stObj.Parent__r.Parent__r.HOD__c != null && stObj.Parent__r.Parent__r.HOD__r.PositionID__c != null)
                    positionIdSet.add(stObj.Parent__r.Parent__r.HOD__r.PositionID__c);
                if(stObj.Parent__r.Parent__r.Parent__c != null && stObj.Parent__r.Parent__r.Parent__r.HOD__c != null && stObj.Parent__r.Parent__r.Parent__r.HOD__r.PositionID__c != null)
                    positionIdSet.add(stObj.Parent__r.Parent__r.Parent__r.HOD__r.PositionID__c);
            }
        }
        if(!positionIdSet.isEmpty())
            positionIdUserMap = getUserIdSPS(positionIdSet);
        
        for(String p: pincode) {
            if(serviceTerritoryMapForSPS.containsKey(p)) {
                Service_Territory__c stObj = serviceTerritoryMapForSPS.get(p);
                
                if(positionIdUserMap != null && stObj.Parent__c != null && stObj.Parent__r.HOD__c != null && stObj.Parent__r.Type__c != null) {
                    User userId = positionIdUserMap.get(stObj.Parent__r.HOD__r.PositionID__c);
                    if(userId != null) {
                        if(!pincodeHODMapForSPS.containsKey(p)) {
                            Map<String, User> HODMapForSPS = new Map<String, User>();
                            HODMapForSPS.put(stObj.Parent__r.Type__c, userId);
                            pincodeHODMapForSPS.put(p, HODMapForSPS);
                        } else {
                            Map<String, User> getMap = pincodeHODMapForSPS.get(p);
                            getMap.put(stObj.Parent__r.Type__c, userId);
                            pincodeHODMapForSPS.put(p, getMap);
                        }
                    }
                }
                if(positionIdUserMap != null && stObj.Parent__r.Parent__c != null && stObj.Parent__r.Parent__r.HOD__c != null && stObj.Parent__r.Parent__r.Type__c != null) {
                    User userId = positionIdUserMap.get(stObj.Parent__r.Parent__r.HOD__r.PositionID__c);
                    if(userId != null) {
                        if(!pincodeHODMapForSPS.containsKey(p)) {
                            Map<String, User> HODMapForSPS = new Map<String, User>();
                            HODMapForSPS.put(stObj.Parent__r.Parent__r.Type__c, userId);
                            pincodeHODMapForSPS.put(p, HODMapForSPS);
                        } else {
                            Map<String, User> getMap = pincodeHODMapForSPS.get(p);
                            getMap.put(stObj.Parent__r.Parent__r.Type__c, userId);
                            pincodeHODMapForSPS.put(p, getMap);
                        }
                    }
                }
                if(positionIdUserMap != null && stObj.Parent__r.Parent__r.Parent__c != null && stObj.Parent__r.Parent__r.Parent__r.HOD__c != null && stObj.Parent__r.Parent__r.Parent__r.Type__c != null) {
                    User userId = positionIdUserMap.get(stObj.Parent__r.Parent__r.Parent__r.HOD__r.PositionID__c);
                    if(userId != null) {
                        if(!pincodeHODMapForSPS.containsKey(p)) {
                            Map<String, User> HODMapForSPS = new Map<String, User>();
                            HODMapForSPS.put(stObj.Parent__r.Parent__r.Parent__r.Type__c, userId);
                            pincodeHODMapForSPS.put(p, HODMapForSPS);
                        } else {
                            Map<String, User> getMap = pincodeHODMapForSPS.get(p);
                            getMap.put(stObj.Parent__r.Parent__r.Parent__r.Type__c, userId);
                            pincodeHODMapForSPS.put(p, getMap);
                        }
                    }
                }
            }
        }
        return pincodeHODMapForSPS;
    }
    
    public static Map<String, Map<String, User>> getHODForBHS(Set<String> pincode) {
        Map<String, Map<String, User>> pincodeHODMapForBHS = new Map<String, Map<String, User>>();
        Map<String, Service_Territory__c> serviceTerritoryMapForBHS = getTerritoryforBHS(pincode);
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id, User> contactIdUserMap = new Map<Id, User>();
        
        for(String p: pincode) {
            if(serviceTerritoryMapForBHS.containsKey(p)) {
                Service_Territory__c stObj = serviceTerritoryMapForBHS.get(p);
                
                if(stObj.Parent__c != null && stObj.Parent__r.HOD__c != null)
                    contactIdSet.add(stObj.Parent__r.HOD__c);
                if(stObj.Parent__r.Parent__c != null && stObj.Parent__r.Parent__r.HOD__c != null)
                    contactIdSet.add(stObj.Parent__r.Parent__r.HOD__c);
                if(stObj.Parent__r.Parent__r.Parent__c != null && stObj.Parent__r.Parent__r.Parent__r.HOD__c != null)
                    contactIdSet.add(stObj.Parent__r.Parent__r.Parent__r.HOD__c);
                //if(stObj.Parent__r.Parent__r.Parent__r.Parent__c != null && stObj.Parent__r.Parent__r.Parent__r.Parent__r.HOD__c != null)
                    //contactIdSet.add(stObj.Parent__r.Parent__r.Parent__r.Parent__r.HOD__c);
            }
        }
        if(!contactIdSet.isEmpty())
            contactIdUserMap = getUserIdBHS(contactIdSet);
        
        for(String p: pincode) {
            if(serviceTerritoryMapForBHS.containsKey(p)) {
                Service_Territory__c stObj = serviceTerritoryMapForBHS.get(p);
                
                if(contactIdUserMap != null && stObj.Parent__c != null && stObj.Parent__r.HOD__c != null && stObj.Parent__r.Type__c != null) {
                    User userId = contactIdUserMap.get(stObj.Parent__r.HOD__c);
                    if(userId != null) {
                        if(!pincodeHODMapForBHS.containsKey(p)) {
                            Map<String, User> HODMapForBHS = new Map<String, User>();
                            HODMapForBHS.put(stObj.Parent__r.Type__c, userId);
                            pincodeHODMapForBHS.put(p, HODMapForBHS);
                        } else {
                            Map<String, User> getMap = pincodeHODMapForBHS.get(p);
                            getMap.put(stObj.Parent__r.Type__c, userId);
                            pincodeHODMapForBHS.put(p, getMap);
                        }
                    }
                }
                if(contactIdUserMap != null && stObj.Parent__r.Parent__c != null && stObj.Parent__r.Parent__r.HOD__c != null && stObj.Parent__r.Parent__r.Type__c != null) {
                    User userId = contactIdUserMap.get(stObj.Parent__r.Parent__r.HOD__c);
                    if(userId != null) {
                        if(!pincodeHODMapForBHS.containsKey(p)) {
                            Map<String, User> HODMapForBHS = new Map<String, User>();
                            HODMapForBHS.put(stObj.Parent__r.Parent__r.Type__c, userId);
                            pincodeHODMapForBHS.put(p, HODMapForBHS);
                        } else {
                            Map<String, User> getMap = pincodeHODMapForBHS.get(p);
                            getMap.put(stObj.Parent__r.Parent__r.Type__c, userId);
                            pincodeHODMapForBHS.put(p, getMap);
                        }
                    }
                }
                if(contactIdUserMap != null && stObj.Parent__r.Parent__r.Parent__c != null && stObj.Parent__r.Parent__r.Parent__r.HOD__c != null && stObj.Parent__r.Parent__r.Parent__r.Type__c != null) {
                    User userId = contactIdUserMap.get(stObj.Parent__r.Parent__r.Parent__r.HOD__c);
                    if(userId != null) {
                        if(!pincodeHODMapForBHS.containsKey(p)) {
                            Map<String, User> HODMapForBHS = new Map<String, User>();
                            HODMapForBHS.put(stObj.Parent__r.Parent__r.Parent__r.Type__c, userId);
                            pincodeHODMapForBHS.put(p, HODMapForBHS);
                        } else {
                            Map<String, User> getMap = pincodeHODMapForBHS.get(p);
                            getMap.put(stObj.Parent__r.Parent__r.Parent__r.Type__c, userId);
                            pincodeHODMapForBHS.put(p, getMap);
                        }
                    }
                }
                /*if(contactIdUserMap != null && stObj.Parent__r.Parent__r.Parent__r.Parent__c != null && stObj.Parent__r.Parent__r.Parent__r.Parent__r.HOD__c != null && stObj.Parent__r.Parent__r.Parent__r.Parent__r.Type__c != null) {
                    User userId = contactIdUserMap.get(stObj.Parent__r.Parent__r.Parent__r.Parent__r.HOD__c);
                    if(userId != null) {
                        if(!pincodeHODMapForBHS.containsKey(p)) {
                            Map<String, User> HODMapForBHS = new Map<String, User>();
                            HODMapForBHS.put(stObj.Parent__r.Parent__r.Parent__r.Parent__r.Type__c, userId);
                            pincodeHODMapForBHS.put(p, HODMapForBHS);
                        } else {
                            Map<String, User> getMap = pincodeHODMapForBHS.get(p);
                            getMap.put(stObj.Parent__r.Parent__r.Parent__r.Parent__r.Type__c, userId);
                            pincodeHODMapForBHS.put(p, getMap);
                        }
                    }
                }*/
            }
        }
        return pincodeHODMapForBHS;
    }
    
    public static Map<String, User> getUserIdSPS(Set<String> positionIdSet) {
        Map<String, User> positionIdUserMap = new Map<String, User>();
        List<User> uList = [Select Id, Name, ContactId, PositionID__c from User where PositionID__c IN: positionIdSet AND IsActive = true];
        
        if(uList != null) {
            for(User u: uList) {
                positionIdUserMap.put(u.PositionID__c, u);
            }
        }
        return positionIdUserMap;
    }
    
    public static Map<Id, User> getUserIdBHS(Set<Id> contactIdSet) {
        Map<Id, User> contactIdUserMap = new Map<Id, User>();
        List<User> uList = [Select Id, Name, ContactId from User where ContactId IN: contactIdSet AND IsActive = true];
        
        if(uList != null) {
            for(User u: uList) {
                contactIdUserMap.put(u.ContactId, u);
            }
        }
        return contactIdUserMap;
    }
    
    public static User getUserId(Id contactId) {
        List<User> uList = [Select Id, Name, ContactId from User where ContactId =: contactId AND IsActive = true];
        
        if(!uList.isEmpty())
            return uList[0];
        else
            return null;
    }
    
    public static Map<String, Pincode__c> getPincodeRelatedDetails(Set<String> pincodeSet) {
        Map<String, Pincode__c> pincodeMap = new Map<String, Pincode__c>();
        List<Pincode__c> pincodeList = [Select Id, Name, City__c, State__c, State_Code__c, Country__c, Country_Code__c 
                                        from Pincode__c where Name IN: pincodeSet];
        
        if(!pincodeList.isEmpty()) {
            for(Pincode__c p: pincodeList) {
                pincodeMap.put(p.Name, p);
            }
        }
        return pincodeMap;
    }
}