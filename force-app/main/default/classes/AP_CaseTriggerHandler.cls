/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 08-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and filter all the Case based on the trigger actions.
*********************************************************************************************************/
public class AP_CaseTriggerHandler {
    public static void onAfterInsert(Map<Id, Case> caseMap) {
        /*Map<String, Case> emailCaseMap = new Map<String, Case>();
        Map<String, Case> emailCaseAccMap = new Map<String, Case>();
        
        for(Case c: caseMap.values()) {
            if(c.Origin == 'Email' && !String.isBlank(c.SuppliedEmail) && c.AccountId == null)
                emailCaseMap.put(c.SuppliedEmail, c);
            if(c.Origin == 'Email' && !String.isBlank(c.SuppliedEmail) && c.AccountId != null && c.Opportunity__c == null)
                emailCaseAccMap.put(c.AccountId, c);
        }
        if(emailCaseMap != null)
            AP_CaseManagementService.updateAccountDetailonCase(emailCaseMap);
        if(emailCaseAccMap != null)
            AP_CaseManagementService.updateOpportunityDetailonCase(emailCaseAccMap);*/
        
        Map<Id, Set<Id>> apexShareUserMap = new Map<Id, Set<Id>>();
        
        for(Case c: caseMap.values()) {
            // Create Apex Sharing With TL1 & TL2 //
            if(c.Team_Lead_1_TL1__c != null) {
                if(apexShareUserMap.containsKey(c.Id)) {
                    apexShareUserMap.get(c.Id).add(c.Team_Lead_1_TL1__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(c.Team_Lead_1_TL1__c);
                    apexShareUserMap.put(c.Id, idSet);
                }
            }
            if(c.Team_Lead_2_TL2__c != null) {
                if(apexShareUserMap.containsKey(c.Id)) {
                    apexShareUserMap.get(c.Id).add(c.Team_Lead_2_TL2__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(c.Team_Lead_2_TL2__c);
                    apexShareUserMap.put(c.Id, idSet);
                }
            }
        }
        if(apexShareUserMap != null)
            AP_ApexSharingService.caseApexShare(apexShareUserMap);
    }
    
    public static void onBeforeUpdate(Map<Id, Case> oldCaseMap, Map<Id, Case> newCaseMap) {
        Map<Id,Schema.RecordTypeInfo> rtMap = Case.sobjectType.getDescribe().getRecordTypeInfosById();
        Set<Id> ownerId = new Set<Id>();
        List<Case> caseList = new List<Case>();
        
        for(Case c: newCaseMap.values()) {
            Case oldCase = oldCaseMap.get(c.Id);
            if(rtMap.get(c.RecordTypeId).getDeveloperName() == 'SPS' && c.OwnerId != oldCase.OwnerId) {
                ownerId.add(c.OwnerId);
            	caseList.add(c);
            }
        }
        if(!ownerId.isEmpty() && !caseList.isEmpty())
            AP_CaseManagementService.updateTeamLeadDetail(ownerId, caseList);
    }
    
    public static void onAfterUpdate(Map<Id, Case> oldCaseMap, Map<Id, Case> newCaseMap) {
        Map<Id,Schema.RecordTypeInfo> rtMap = Case.sobjectType.getDescribe().getRecordTypeInfosById();
        //Map<String, Case> emailCaseAccMap = new Map<String, Case>();
        Set<Id> caseSet = new Set<Id>();
        Set<Id> cIdBHSSet = new Set<Id>();
        Set<Id> cIdPushUpdateBHSSet = new Set<Id>();
        Map<Id, Set<Id>> apexShareUserMap = new Map<Id, Set<Id>>();
        
        for(Case newCase: newCaseMap.values()) {
            Case oldCase = oldCaseMap.get(newCase.Id);
            /*if(newCase.AccountId != oldCase.AccountId && newCase.Origin == 'Email' && newCase.Opportunity__c == null)
                emailCaseAccMap.put(newCase.AccountId, newCase);*/
            if(newCase.Pincode__c != oldCase.Pincode__c && newCase.Pincode__c != null)
                caseSet.add(newCase.Id);
            if(newCase.Status != oldCase.Status && newCase.Status == 'Assign to CSO' && rtMap.get(newCase.RecordTypeId).getDeveloperName() == 'BHS')
                cIdBHSSet.add(newCase.Id);
            if(newCase.Status != oldCase.Status && newCase.Status == 'CAC Completed' && rtMap.get(newCase.RecordTypeId).getDeveloperName() == 'BHS')
                cIdPushUpdateBHSSet.add(newCase.Id);
            // Create Apex Sharing With TL1 & TL2 //
            if(newCase.Team_Lead_1_TL1__c!=null && (newCase.OwnerId != oldCase.OwnerId || newCase.Team_Lead_1_TL1__c != oldCase.Team_Lead_1_TL1__c)) {
                if(apexShareUserMap.containsKey(newCase.Id)) {
                    apexShareUserMap.get(newCase.Id).add(newCase.Team_Lead_1_TL1__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(newCase.Team_Lead_1_TL1__c);
                    apexShareUserMap.put(newCase.Id, idSet);
                }
            }
            if(newCase.Team_Lead_2_TL2__c!=null && (newCase.OwnerId != oldCase.OwnerId || newCase.Team_Lead_2_TL2__c != oldCase.Team_Lead_2_TL2__c)) {
                if(apexShareUserMap.containsKey(newCase.Id)) {
                    apexShareUserMap.get(newCase.Id).add(newCase.Team_Lead_2_TL2__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(newCase.Team_Lead_2_TL2__c);
                    apexShareUserMap.put(newCase.Id, idSet);
                }
            }
        }
        /*if(emailCaseAccMap != null)
            AP_CaseManagementService.updateOpportunityDetailonCase(emailCaseAccMap);*/
        if(!caseSet.isEmpty())
            AP_CaseManagementService.tagServiceTerritoryDetail(caseSet);
        if(!cIdBHSSet.isEmpty())
            AP_ExternalSystemAPIManagementServices.createCaseInBHSExternalSystem(cIdBHSSet);
        if(!cIdPushUpdateBHSSet.isEmpty())
            AP_ExternalSystemAPIManagementServices.sendUpdateCaseInBHSExternalSystem(cIdPushUpdateBHSSet);
        if(apexShareUserMap != null)
            AP_ApexSharingService.caseApexShare(apexShareUserMap);
    }
}