/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 03-12-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and filter all the Site based on the trigger actions.
*********************************************************************************************************/
public class AP_SiteTriggerHandler {
    public static void onAfterInsert(Map<Id, Milestone1_Project__c> newSiteMap) {
        Map<Id, Set<Id>> apexShareUserMap = new Map<Id, Set<Id>>();
        
        for(Milestone1_Project__c site: newSiteMap.values()) {
            // Create Apex Sharing With TL1 & TL2 //
            if(site.Team_Lead_1_TL1__c != null) {
                if(apexShareUserMap.containsKey(site.Id)) {
                    apexShareUserMap.get(site.Id).add(site.Team_Lead_1_TL1__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(site.Team_Lead_1_TL1__c);
                    apexShareUserMap.put(site.Id, idSet);
                }
            }
            if(site.Team_Lead_2_TL2__c != null) {
                if(apexShareUserMap.containsKey(site.Id)) {
                    apexShareUserMap.get(site.Id).add(site.Team_Lead_2_TL2__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(site.Team_Lead_2_TL2__c);
                    apexShareUserMap.put(site.Id, idSet);
                }
            }
        }
        if(apexShareUserMap != null)
            AP_ApexSharingService.siteApexShare(apexShareUserMap);
    }
    
	public static void onBeforeUpdate(Map<Id, Milestone1_Project__c> oldSiteMap, Map<Id, Milestone1_Project__c> newSiteMap) {
        List<Milestone1_Project__c> siteList = new List<Milestone1_Project__c>();
        Set<Id> ownerId = new Set<Id>();
        
        for(Milestone1_Project__c site : newSiteMap.values()) {
            Milestone1_Project__c oldSite = oldSiteMap.get(site.Id);
            if(site.OwnerId != oldSite.OwnerId) {
                ownerId.add(site.OwnerId);
                siteList.add(site);
            }
        }
        if(!ownerId.isEmpty() && !siteList.isEmpty())
            AP_SiteManagementService.updateTeamLeadDetails(ownerId, siteList);
    }
    
    public static void onAfterUpdate(Map<Id, Milestone1_Project__c> oldSiteMap, Map<Id, Milestone1_Project__c> newSiteMap) {
        List<Milestone1_Project__c> siteList = new List<Milestone1_Project__c>();
        Map<Id, Set<Id>> apexShareUserMap = new Map<Id, Set<Id>>();
        
        siteList = [Select Id, Name, Team_Lead_1_TL1__c, Team_Lead_2_TL2__c
                    from Milestone1_Project__c where Id IN: newSiteMap.keySet()];
        system.debug('siteList: '+siteList);
        
        if(!siteList.isEmpty()) {
            for(Milestone1_Project__c site : siteList) {
            	Milestone1_Project__c oldSite = oldSiteMap.get(site.Id);
                // Create Apex Sharing With TL1 & TL2 //
                if(site.Team_Lead_1_TL1__c != oldSite.Team_Lead_1_TL1__c) {
                    if(apexShareUserMap.containsKey(site.Id)) {
                        apexShareUserMap.get(site.Id).add(site.Team_Lead_1_TL1__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(site.Team_Lead_1_TL1__c);
                        apexShareUserMap.put(site.Id, idSet);
                    }
                }
                if(site.Team_Lead_2_TL2__c != oldSite.Team_Lead_2_TL2__c) {
                    if(apexShareUserMap.containsKey(site.Id)) {
                        apexShareUserMap.get(site.Id).add(site.Team_Lead_2_TL2__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(site.Team_Lead_2_TL2__c);
                        apexShareUserMap.put(site.Id, idSet);
                    }
                }
            }
        }
        if(apexShareUserMap != null)
            AP_ApexSharingService.siteApexShare(apexShareUserMap);
    }
}