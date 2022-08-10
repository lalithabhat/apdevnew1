/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 03-12-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and filter all the Checklist Header based on the trigger actions.
*********************************************************************************************************/
public class AP_ChecklistHeaderTriggerHandler {
	public static void onAfterInsert(Map<Id, Checklist_Header__c> newCHMap) {
        Map<Id, Set<Id>> apexShareUserMap = new Map<Id, Set<Id>>();
        
        for(Checklist_Header__c ch: newCHMap.values()) {
            // Create Apex Sharing With TL1 & TL2 //
            if(ch.Team_Lead_1_TL1__c != null) {
                if(apexShareUserMap.containsKey(ch.Id)) {
                    apexShareUserMap.get(ch.Id).add(ch.Team_Lead_1_TL1__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(ch.Team_Lead_1_TL1__c);
                    apexShareUserMap.put(ch.Id, idSet);
                }
            }
            if(ch.Team_Lead_2_TL2__c != null) {
                if(apexShareUserMap.containsKey(ch.Id)) {
                    apexShareUserMap.get(ch.Id).add(ch.Team_Lead_2_TL2__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(ch.Team_Lead_2_TL2__c);
                    apexShareUserMap.put(ch.Id, idSet);
                }
            }
        }
        if(apexShareUserMap != null)
            AP_ApexSharingService.checklistHeaderApexShare(apexShareUserMap);
    }
    
	public static void onBeforeUpdate(Map<Id, Checklist_Header__c> oldCHMap, Map<Id, Checklist_Header__c> newCHMap) {
        List<Checklist_Header__c> chList = new List<Checklist_Header__c>();
        Set<Id> ownerId = new Set<Id>();
        
        for(Checklist_Header__c ch : newCHMap.values()) {
            Checklist_Header__c oldCH = oldCHMap.get(ch.Id);
            if(ch.OwnerId != oldCH.OwnerId) {
                ownerId.add(ch.OwnerId);
                chList.add(ch);
            }
        }
        if(!ownerId.isEmpty() && !chList.isEmpty())
            AP_ChecklistHeaderManagementService.updateTeamLeadDetails(ownerId, chList);
    }
    
    public static void onAfterUpdate(Map<Id, Checklist_Header__c> oldCHMap, Map<Id, Checklist_Header__c> newCHMap) {
        List<Checklist_Header__c> chList = new List<Checklist_Header__c>();
        Map<Id, Set<Id>> apexShareUserMap = new Map<Id, Set<Id>>();
        
        chList = [Select Id, Name, Team_Lead_1_TL1__c, Team_Lead_2_TL2__c
                    from Checklist_Header__c where Id IN: newCHMap.keySet()];
        system.debug('chList: '+chList);
        
        if(!chList.isEmpty()) {
            for(Checklist_Header__c ch : chList) {
            	Checklist_Header__c oldCH = oldCHMap.get(ch.Id);
                // Create Apex Sharing With TL1 & TL2 //
                if(ch.Team_Lead_1_TL1__c != oldCH.Team_Lead_1_TL1__c) {
                    if(apexShareUserMap.containsKey(ch.Id)) {
                        apexShareUserMap.get(ch.Id).add(ch.Team_Lead_1_TL1__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(ch.Team_Lead_1_TL1__c);
                        apexShareUserMap.put(ch.Id, idSet);
                    }
                }
                if(ch.Team_Lead_2_TL2__c != oldCH.Team_Lead_2_TL2__c) {
                    if(apexShareUserMap.containsKey(ch.Id)) {
                        apexShareUserMap.get(ch.Id).add(ch.Team_Lead_2_TL2__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(ch.Team_Lead_2_TL2__c);
                        apexShareUserMap.put(ch.Id, idSet);
                    }
                }
            }
        }
        if(apexShareUserMap != null)
            AP_ApexSharingService.checklistHeaderApexShare(apexShareUserMap);
    }
}