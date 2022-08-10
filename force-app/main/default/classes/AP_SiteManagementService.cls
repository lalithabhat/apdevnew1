/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 03-12-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all Site services.
*********************************************************************************************************/
public class AP_SiteManagementService {
	public static void updateTeamLeadDetails(Set<Id> ownerId, List<Milestone1_Project__c> siteList) {
        Map<Id, User> userProfileMap = new Map<Id, User>();
        Map<Id, String> siteSkillMap = new Map<Id, String>();
        
        List<User> userList = [Select Id, Name, Profile.Name, ContactId from User where Id IN: ownerId AND IsActive = true];
        system.debug('userList: '+userList);
        
        if(!userList.isEmpty()) {
            for(User u: userList) {
            	userProfileMap.put(u.Id, u);
            }
        }
        siteSkillMap = getSkillMap(siteList);
        
        for(Milestone1_Project__c site: siteList) {
            if(userProfileMap.get(site.OwnerId).Profile.Name == 'Sales Associate (SA)' || userProfileMap.get(site.OwnerId).Profile.Name == 'Customer Associate (CA)') {
                if(!String.isBlank(site.PincodeLookup__c)) {
                    Id tl1Id = AP_ServiceTerritoryManagementService.getTeamLead1(userProfileMap.get(site.OwnerId).ContactId, site.PincodeLookup__r.Name, siteSkillMap.get(site.Id));
                    Id tl2Id = AP_ServiceTerritoryManagementService.getTeamLead2(userProfileMap.get(site.OwnerId).ContactId, site.PincodeLookup__r.Name, siteSkillMap.get(site.Id));
                    
                    if(tl1Id != null)
                        site.Team_Lead_1_TL1__c = tl1Id;
                    if(tl2Id != null)
                        site.Team_Lead_2_TL2__c = tl2Id;
                }
            }
        }
    }
    
    public static Map<Id, String> getSkillMap(List<Milestone1_Project__c> siteList) {
        Map<Id, String> siteSkillMap = new Map<Id, String>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, String> oppSkillMap = new Map<Id, String>();
        Set<Id> sIdSet = new Set<Id>();
        
        for(Milestone1_Project__c s: siteList) {
            sIdSet.add(s.Id);
        }
        
        if(!sIdSet.isEmpty()) {
            oppList = [Select Id, Skills__c, Site__c from Opportunity where Site__c IN: sIdSet AND Skills__c != null ORDER BY CreatedDate ASC];
            system.debug('oppList: '+oppList);
            
            if(!oppList.isEmpty()) {
                for(Opportunity op: oppList) {
                    if(oppSkillMap.containsKey(op.Site__c))
                        oppSkillMap.put(op.Site__c, op.Skills__c);
                    else
                        oppSkillMap.put(op.Site__c, op.Skills__c);
                }
            }
        }
        
        for(Milestone1_Project__c s: siteList) {
            if(oppSkillMap.containsKey(s.Id))
                siteSkillMap.put(s.Id, oppSkillMap.get(s.Id));
            else
                siteSkillMap.put(s.Id, 'SPS');
        }
        return siteSkillMap;
    }
}