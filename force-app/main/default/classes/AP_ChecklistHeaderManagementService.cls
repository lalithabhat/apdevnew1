/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 03-12-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all Checklist Header services.
*********************************************************************************************************/
public class AP_ChecklistHeaderManagementService {
	public static void updateTeamLeadDetails(Set<Id> ownerId, List<Checklist_Header__c> chList) {
        Map<Id, User> userProfileMap = new Map<Id, User>();
        Map<Id, String> checkListSkillMap = new Map<Id, String>();
        
        List<User> userList = [Select Id, Name, Profile.Name, ContactId from User where Id IN: ownerId AND IsActive = true];
        system.debug('userList: '+userList);
        
        if(!userList.isEmpty()) {
            for(User u: userList) {
            	userProfileMap.put(u.Id, u);
            }
        }
        checkListSkillMap = getSkillMap(chList);
        
        for(Checklist_Header__c ch: chList) {
            if(userProfileMap.get(ch.OwnerId).Profile.Name == 'Sales Associate (SA)' || userProfileMap.get(ch.OwnerId).Profile.Name == 'Customer Associate (CA)') {
                if(ch.Project__c != null) {
                    Id tl1Id = AP_ServiceTerritoryManagementService.getTeamLead1(userProfileMap.get(ch.OwnerId).ContactId, ch.Project__r.PincodeLookup__r.Name, checkListSkillMap.get(ch.Project__c));
                    Id tl2Id = AP_ServiceTerritoryManagementService.getTeamLead2(userProfileMap.get(ch.OwnerId).ContactId, ch.Project__r.PincodeLookup__r.Name, checkListSkillMap.get(ch.Project__c));
                    
                    if(tl1Id != null)
                        ch.Team_Lead_1_TL1__c = tl1Id;
                    if(tl2Id != null)
                        ch.Team_Lead_2_TL2__c = tl2Id;
                }
            }
        }
    }
    
    public static Map<Id, String> getSkillMap(List<Checklist_Header__c> chList) {
        Map<Id, String> checkListSkillMap = new Map<Id, String>();
        List<Opportunity> oppList = new List<Opportunity>();
        Map<Id, String> oppSkillMap = new Map<Id, String>();
        Set<Id> sIdSet = new Set<Id>();
        
        for(Checklist_Header__c ch: chList) {
            sIdSet.add(ch.Project__c);
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
        
        for(Checklist_Header__c ch: chList) {
            if(oppSkillMap.containsKey(ch.Project__c))
                checkListSkillMap.put(ch.Project__c, oppSkillMap.get(ch.Project__c));
            else
                checkListSkillMap.put(ch.Project__c, 'SPS');
        }
        return checkListSkillMap;
    }
}