/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 08-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all Case services.
*********************************************************************************************************/
public class AP_CaseManagementService {
    //Update account details on case if not present
    /*public static void updateAccountDetailonCase(Map<String, Case> emailCaseMap) {
List<Case> updateCaseList = new List<Case>();
Map<String, Account> emailAccountMap = new Map<String, Account>();

if(emailCaseMap != null) {
emailAccountMap = getAccountDetails(emailCaseMap.keySet());

for(Case c: emailCaseMap.values()) {
if(emailAccountMap != null && emailAccountMap.containsKey(c.SuppliedEmail)) {
Case newCase = new Case();
newCase.Id = c.Id;
newCase.AccountId = emailAccountMap.get(c.SuppliedEmail).Id;
if(emailAccountMap.get(c.SuppliedEmail).PersonContactId != null)
newCase.ContactId = emailAccountMap.get(c.SuppliedEmail).PersonContactId;
updateCaseList.add(newCase);
}
}
}
if(!updateCaseList.isEmpty())
update updateCaseList;
}*/
    
    //Update opportunity details on case if not present
    /*public static void updateOpportunityDetailonCase(Map<String, Case> emailCaseAccMap) {
List<Case> updateCaseList = new List<Case>();
Map<String, Map<String, List<Opportunity>>> caseOpportunityMap = new Map<String, Map<String, List<Opportunity>>>();

if(emailCaseAccMap != null) {
caseOpportunityMap = getOpportunityDetails(emailCaseAccMap.keySet());

for(Case c: emailCaseAccMap.values()) {
if(caseOpportunityMap != null && caseOpportunityMap.containsKey(c.AccountId)) {
Map<String, List<Opportunity>> getOppMap = new Map<String, List<Opportunity>>();
getOppMap = caseOpportunityMap.get(c.AccountId);

if(getOppMap != null && getOppmap.containsKey(c.RecordType.Name)) {
if(getOppMap.get(c.RecordType.Name).size() == 1) {
Case newCase = new Case();
newCase.Id = c.Id;
newCase.Opportunity__c = getOppMap.get(c.RecordType.Name)[0].Id;
newCase.Pincode__c = getOppMap.get(c.RecordType.Name)[0].Pincode__c;
if(getOppMap.get(c.RecordType.Name)[0].Dealer__c != null)
newCase.Dealer__c = getOppMap.get(c.RecordType.Name)[0].Dealer__c;

updateCaseList.add(newCase);
}
}
}
}
if(!updateCaseList.isEmpty())
update updateCaseList;
}
}*/
    
    public static void tagServiceTerritoryDetail(Set<Id> caseSet) {
        List<Case> updateCaseList = new List<Case>();
        Map<String, Set<String>> servicePincodeMap = new Map<String, Set<String>>();
        Map<String, Service_Territory__c> serviceTerritoryMapForSPS = new Map<String, Service_Territory__c>();
        Map<String, Map<String, User>> pincodeHODMapForSPS = new Map<String, Map<String, User>>();
        Map<String, Service_Territory__c> serviceTerritoryMapForBHS = new Map<String, Service_Territory__c>();
        Map<String, Map<String, User>> pincodeHODMapForBHS = new Map<String, Map<String, User>>();
        Map<Id,Schema.RecordTypeInfo> rtMap = Case.sobjectType.getDescribe().getRecordTypeInfosById();
        
        List<Case> caseList = [Select Id, AccountId, RecordTypeId, Pincode__c, Service_Territory__c, Level_1_Escalation__c, Level_2_Escalation__c, Level_3_Escalation__c,
                               Level_4_Escalation__c, Level_5_Escalation__c, Level_1_Escalation_User__c, Level_2_Escalation_User__c, Level_3_Escalation_User__c, Level_4_Escalation_User__c,
                               Level_5_Escalation_User__c from Case where Id IN: caseSet];
        
        if(!caseList.isEmpty()) {
            for(Case c: caseList) {
                if(rtMap.get(c.RecordTypeId).getDeveloperName() == 'SPS' || rtMap.get(c.RecordTypeId).getDeveloperName() == 'BHS') {
                    if(!servicePincodeMap.containsKey(rtMap.get(c.RecordTypeId).getDeveloperName())) {
                        Set<String> pincodeSet = new Set<String>();
                        pincodeSet.add(c.Pincode__c);
                        servicePincodeMap.put(rtMap.get(c.RecordTypeId).getDeveloperName(), pincodeSet);
                    } else {
                        servicePincodeMap.get(rtMap.get(c.RecordTypeId).getDeveloperName()).add(c.Pincode__c);
                    }
                }
            }
            
            if(servicePincodeMap != null) {
                if(servicePincodeMap.containsKey('SPS')) {
                    
                    serviceTerritoryMapForSPS = AP_ServiceTerritoryManagementService.getTerritoryforSPS(servicePincodeMap.get('SPS'));
                    system.debug('############################### service pincode map '+servicePincodeMap.get('SPS'));
                    pincodeHODMapForSPS = AP_ServiceTerritoryManagementService.getHODForSPS(servicePincodeMap.get('SPS'));
                }
                if(servicePincodeMap.containsKey('BHS')) {
                    serviceTerritoryMapForBHS = AP_ServiceTerritoryManagementService.getTerritoryforBHS(servicePincodeMap.get('BHS'));
                    pincodeHODMapForBHS = AP_ServiceTerritoryManagementService.getHODForBHS(servicePincodeMap.get('BHS'));
                }
                
                for(Case c: caseList) {
                    if(rtMap.get(c.RecordTypeId).getDeveloperName() == 'SPS') {
                        if(serviceTerritoryMapForSPS.containsKey(c.Pincode__c) && serviceTerritoryMapForSPS.get(c.Pincode__c).Parent__r.Id != null) {
                            c.Service_Territory__c = serviceTerritoryMapForSPS.get(c.Pincode__c).Parent__r.Id;
                            c.Service_Territory_Name__c = serviceTerritoryMapForSPS.get(c.Pincode__c).Parent__r.Name;
                        }
                        system.debug('###################'+pincodeHODMapForSPS);
                        if(pincodeHODMapForSPS.containsKey(c.Pincode__c)) {
                            Map<String, User> HODMapForSPS = pincodeHODMapForSPS.get(c.Pincode__c);
                            
                            if(HODMapForSPS != null) {
                                for(String str: HODMapForSPS.keySet()) {
                                    if(HODMapForSPS.get(str) != null) {
                                        if(str.equalsIgnoreCase('Region')) {
                                            c.Level_2_Escalation__c = HODMapForSPS.get(str).ContactId;
                                            c.Level_2_Escalation_User__c = HODMapForSPS.get(str).Id;
                                        }
                                        if(str.equalsIgnoreCase('Unit')) {
                                            c.Level_3_Escalation__c = HODMapForSPS.get(str).ContactId;
                                            c.Level_3_Escalation_User__c = HODMapForSPS.get(str).Id;
                                        }
                                        if(str.equalsIgnoreCase('Division')) {
                                            c.Level_4_Escalation__c = HODMapForSPS.get(str).ContactId;
                                            c.Level_4_Escalation_User__c = HODMapForSPS.get(str).Id;
                                        }
                                    }
                                }
                            }
                        }
                        updateCaseList.add(c);
                    } else if(rtMap.get(c.RecordTypeId).getDeveloperName() == 'BHS') {
                        if(serviceTerritoryMapForBHS.containsKey(c.Pincode__c) && serviceTerritoryMapForBHS.get(c.Pincode__c).Parent__r.Id != null) {
                            c.Service_Territory__c = serviceTerritoryMapForBHS.get(c.Pincode__c).Parent__r.Id;
                            c.Service_Territory_Name__c = serviceTerritoryMapForBHS.get(c.Pincode__c).Parent__r.Name;
                        }
                        if(pincodeHODMapForBHS.containsKey(c.Pincode__c)) {
                            Map<String, User> HODMapForBHS = pincodeHODMapForBHS.get(c.Pincode__c);
                            
                            if(HODMapForBHS != null) {
                                for(String str: HODMapForBHS.keySet()) {
                                    if(HODMapForBHS.get(str) != null) {
                                        if(str.equalsIgnoreCase('Territory')) {
                                            c.Level_2_Escalation__c = HODMapForBHS.get(str).ContactId;
                                            c.Level_2_Escalation_User__c = HODMapForBHS.get(str).Id;
                                        }
                                        if(str.equalsIgnoreCase('City')) {
                                            c.Level_3_Escalation__c = HODMapForBHS.get(str).ContactId;
                                            c.Level_3_Escalation_User__c = HODMapForBHS.get(str).Id;
                                        }
                                        if(str.equalsIgnoreCase('Unit')) {
                                            c.Level_4_Escalation__c = HODMapForBHS.get(str).ContactId;
                                            c.Level_4_Escalation_User__c = HODMapForBHS.get(str).Id;
                                        }
                                        if(str.equalsIgnoreCase('Division')) {
                                            c.Level_5_Escalation__c = HODMapForBHS.get(str).ContactId;
                                            c.Level_5_Escalation_User__c = HODMapForBHS.get(str).Id;
                                        }
                                    }
                                }
                            }
                        }
                        updateCaseList.add(c);
                    }
                }
            }
        }
        if(!updateCaseList.isEmpty())
            update updateCaseList;
    }
    
    /*public static Map<String, Account> getAccountDetails(Set<String> emailSet) {
Map<String, Account> emailAccountMap = new Map<String, Account>();
List<Account> accList = [Select Id, Name, PersonEmail, PersonContactId from Account where PersonEmail IN: emailSet AND IsPersonAccount = true];

if(accList != null) {
for(Account a: accList) {
emailAccountMap.put(a.PersonEmail, a);
}
}
return emailAccountMap;
}*/
    
    /*public static Map<String, Map<String, List<Opportunity>>> getOpportunityDetails(Set<String> accountId) {
Map<String, Map<String, List<Opportunity>>> caseOpportunityMap = new Map<String, Map<String, List<Opportunity>>>();
List<Opportunity> oppList = [Select Id, Name, AccountId, OwnerId, Owner.Profile.Name, RecordType.Name, Pincode__c, Dealer__c, Primary_Contractor__c from Opportunity where AccountId IN: accountId];

if(!oppList.isEmpty()) {
for(Opportunity op: oppList) {
if(!caseOpportunityMap.containsKey(op.AccountId)) {
Map<String, List<Opportunity>> newMap = new Map<String, List<Opportunity>>();
List<Opportunity> newList = new List<Opportunity>();
newList.add(op);
newMap.put(op.RecordType.Name, newList);
caseOpportunityMap.put(op.AccountId, newMap);
} else {
Map<String, List<Opportunity>> getMap = caseOpportunityMap.get(op.AccountId);

if(!getMap.containsKey(op.RecordType.Name)) {
List<Opportunity> newList = new List<Opportunity>();
newList.add(op);
getMap.put(op.RecordType.Name, newList);
} else {
getMap.get(op.RecordType.Name).add(op);
}
caseOpportunityMap.get(op.AccountId).putAll(getMap);
}
}
}
return caseOpportunityMap;
}*/
    
    public static void updateTeamLeadDetail(Set<Id> ownerId, List<Case> caseList) {
        Map<Id, User> userProfileMap = new Map<Id, User>();
        Map<Id, String> parentSkillMap = new Map<Id, String>();
        Map<String, Id> teamLeadMapfromContact = new Map<String,Id>();  //Holding TL1 & TL2 from CA contact 
        Map<Id,Id> userContactMap = new Map<Id,Id>();  //contactId, userId
        
        List<User> userList = [Select Id, Name, Profile.Name, Contact.Id,Contact.Team_Lead_1__c, Contact.Team_Lead_2__c from User where Id IN: ownerId AND IsActive = true];
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
        parentSkillMap = getParentSkillMap(caseList);
        
        for(Case c: caseList) {
            if( !userProfileMap.isEmpty()) {  
                if(userProfileMap.containskey(c.ownerId)) { 
                    if ( userProfileMap.get(c.OwnerId).Profile.Name == 'Sales Associate (SA)' || userProfileMap.get(c.OwnerId).Profile.Name == 'Customer Associate (CA)' ){                Id tl1Id;
                                                                                                                                                                           Id tl2Id;
                                                                                                                                                                           if(!String.isBlank(c.Pincode__c) && c.Site__c != null) {
                                                                                                                                                                               tl1Id = AP_ServiceTerritoryManagementService.getTeamLead1(userProfileMap.get(c.OwnerId).ContactId, c.Pincode__c, parentSkillMap.get(c.Site__c));
                                                                                                                                                                               tl2Id = AP_ServiceTerritoryManagementService.getTeamLead2(userProfileMap.get(c.OwnerId).ContactId, c.Pincode__c, parentSkillMap.get(c.Site__c));
                                                                                                                                                                           } else if(!String.isBlank(c.Pincode__c) && c.Opportunity__c != null) {
                                                                                                                                                                               tl1Id = AP_ServiceTerritoryManagementService.getTeamLead1(userProfileMap.get(c.OwnerId).Contact.Id, c.Pincode__c, parentSkillMap.get(c.Opportunity__c));
                                                                                                                                                                               tl2Id = AP_ServiceTerritoryManagementService.getTeamLead2(userProfileMap.get(c.OwnerId).Contact.Id, c.Pincode__c, parentSkillMap.get(c.Opportunity__c));
                                                                                                                                                                           } else if(!String.isBlank(c.Pincode__c) && c.Lead__c != null) {
                                                                                                                                                                               tl1Id = AP_ServiceTerritoryManagementService.getTeamLead1(userProfileMap.get(c.OwnerId).ContactId, c.Pincode__c, parentSkillMap.get(c.Lead__c));
                                                                                                                                                                               tl2Id = AP_ServiceTerritoryManagementService.getTeamLead2(userProfileMap.get(c.OwnerId).ContactId, c.Pincode__c, parentSkillMap.get(c.Lead__c));
                                                                                                                                                                           }
                                                                                                                                                                           if(tl1Id != null)
                                                                                                                                                                               c.Team_Lead_1_TL1__c = tl1Id;
                                                                                                                                                                           if(tl2Id != null)
                                                                                                                                                                               c.Team_Lead_2_TL2__c = tl2Id;
                                                                                                                                                                          }
                }
            }
            //////////////////////////If TL1 & TL2 not found basis pincode - populate from CA contact
            if(!teamLeadMapfromContact.isEmpty() && teamLeadMapfromContact != null) {
                for(Case l: caseList) {
                    if(l.Team_Lead_1_TL1__c == null){
                        if(teamLeadMapfromContact.containsKey(l.OwnerId+'TL1'))
                            l.Team_Lead_1_TL1__c = userContactMap.get(teamLeadMapfromContact.get(l.OwnerId+'TL1'));
                    }
                    if(l.Team_Lead_2_TL2__c == null) {
                        if(teamLeadMapfromContact.containsKey(l.OwnerId+'TL2'))
                            l.Team_Lead_2_TL2__c = userContactMap.get(teamLeadMapfromContact.get(l.OwnerId+'TL2'));
                    }
                }
            } 
        }
    }
    
    public static Map<Id, String> getParentSkillMap(List<Case> caseList) {
        Map<Id, String> parentSkillMap = new Map<Id, String>();
        Map<String, Set<Id>> caseParentMap = new Map<String, Set<Id>>();
        Map<Id, String> skillMap = new Map<Id, String>();
        
        for(Case c: caseList) {
            if(c.Site__c != null) {
                if(caseParentMap.containsKey('Site')) {
                    caseParentMap.get('Site').add(c.Site__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(c.Site__c);
                    caseParentMap.put('Site', idSet);
                }
            } else if(c.Opportunity__c != null) {
                if(caseParentMap.containsKey('Opportunity')) {
                    caseParentMap.get('Opportunity').add(c.Opportunity__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(c.Opportunity__c);
                    caseParentMap.put('Opportunity', idSet);
                }
            } else if(c.Lead__c != null) {
                if(caseParentMap.containsKey('Lead')) {
                    caseParentMap.get('Lead').add(c.Lead__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(c.Lead__c);
                    caseParentMap.put('Lead', idSet);
                }
            }
        }
        
        if(caseParentMap != null) {
            if(caseParentMap.containsKey('Site')) {
                List<Opportunity> oppList = [Select Id, Skills__c, Site__c from Opportunity where Site__c IN: caseParentMap.get('Site') AND 
                                             Skills__c != null ORDER BY CreatedDate ASC];
                
                if(oppList != null) {
                    for(Opportunity op: oppList) {
                        if(skillMap.containsKey(op.Site__c))
                            skillMap.put(op.Site__c, op.Skills__c);
                        else
                            skillMap.put(op.Site__c, op.Skills__c);
                    }
                }
            }
            if(caseParentMap.containsKey('Opportunity')) {
                List<Opportunity> oppList = [Select Id, Skills__c, Site__c from Opportunity where Id IN: caseParentMap.get('Opportunity') AND 
                                             Skills__c != null ORDER BY CreatedDate ASC];
                
                if(oppList != null) {
                    for(Opportunity op: oppList) {
                        if(skillMap.containsKey(op.Id))
                            skillMap.put(op.Id, op.Skills__c);
                        else
                            skillMap.put(op.Id, op.Skills__c);
                    }
                }
            }
            if(caseParentMap.containsKey('Lead')) {
                List<Lead> leadList = [Select Id, Skills__c from Lead where Id IN: caseParentMap.get('Lead') AND 
                                       Skills__c != null ORDER BY CreatedDate ASC];
                
                if(leadList != null) {
                    for(Lead l: leadList) {
                        if(skillMap.containsKey(l.Id))
                            skillMap.put(l.Id, l.Skills__c);
                        else
                            skillMap.put(l.Id, l.Skills__c);
                    }
                }
            }
        }
        
        for(Case c: caseList) {
            if(c.Site__c != null) {
                if(skillMap.containsKey(c.Site__c))
                    parentSkillMap.put(c.Site__c, skillMap.get(c.Site__c));
                else
                    parentSkillMap.put(c.Site__c, 'SPS');
            } else if(c.Opportunity__c != null) {
                if(skillMap.containsKey(c.Opportunity__c))
                    parentSkillMap.put(c.Opportunity__c, skillMap.get(c.Opportunity__c));
                else
                    parentSkillMap.put(c.Opportunity__c, 'SPS');
            } else if(c.Lead__c != null) {
                if(skillMap.containsKey(c.Lead__c))
                    parentSkillMap.put(c.Lead__c, skillMap.get(c.Lead__c));
                else
                    parentSkillMap.put(c.Lead__c, 'SPS');
            }
        }
        return parentSkillMap;
    }
}