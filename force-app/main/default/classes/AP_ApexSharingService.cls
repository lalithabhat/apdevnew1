/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 02-12-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all sharing services.
*********************************************************************************************************/
public class AP_ApexSharingService {
    public static  Map<Id,User> getUserMap(Map<Id, Set<Id>> apexShareUserMap){
        Set<Id> userIds = new Set<Id>();
        for(Id lId: apexShareUserMap.keySet()) {
            Set<Id> uIdSet = apexShareUserMap.get(lId);
            if(uIdSet != null) {
                for(Id uId: uIdSet) {
                    userIds.add(uId);
                }
            }
        }
        Map<Id,User> userMap =new Map<Id,User>([Select Id, isActive from user Where ID IN: userIds]); 
        system.debug(userMap);
        return userMap;
    }
    public static void leadApexShare(Map<Id, Set<Id>> apexShareUserMap) {
        List<LeadShare> insertShareList = new List<LeadShare>();
        List<LeadShare> deleteShareList = new List<LeadShare>();
        
        deleteShareList = [Select Id from LeadShare where LeadId IN: apexShareUserMap.keySet() AND RowCause = 'Manual'];
       
        if(!deleteShareList.isEmpty())
            delete deleteShareList;
        Map<Id,User> userMap = getUserMap(apexShareUserMap);
        for(Id lId: apexShareUserMap.keySet()) {
            Set<Id> uIdSet = apexShareUserMap.get(lId);
            if(uIdSet != null) {
                for(Id uId: uIdSet) {
                    system.debug(userMap.get(uId));
                    if(userMap.get(uID) !=null && userMap.get(uID).isActive){
                        LeadShare csShare = new LeadShare();
                        csShare.LeadAccessLevel = 'edit';
                        csShare.LeadId = lId;
                        csShare.UserOrGroupId = uId;
                        csShare.RowCause = 'Manual';
                        insertShareList.add(csShare);
                    }
                }
            }
        }
        if(!insertShareList.isEmpty())
            insert insertShareList;       
    }
    
    public static void opportunityApexShare(Map<Id, Set<Id>> apexShareUserMap) {
        List<OpportunityShare> insertShareList = new List<OpportunityShare>();
        List<OpportunityShare> deleteShareList = new List<OpportunityShare>();
        
        deleteShareList = [Select Id from OpportunityShare where OpportunityId IN: apexShareUserMap.keySet() AND RowCause = 'Manual'];
        if(!deleteShareList.isEmpty())
            delete deleteShareList;
        Map<Id,User> userMap = getUserMap(apexShareUserMap);
        for(Id lId: apexShareUserMap.keySet()) {
            Set<Id> uIdSet = apexShareUserMap.get(lId);
            if(uIdSet != null) {
                for(Id uId: uIdSet) {
                    if(userMap.get(uID) !=null && userMap.get(uID).isActive){
                        OpportunityShare csShare = new OpportunityShare();
                        csShare.OpportunityAccessLevel = 'edit';
                        csShare.OpportunityId = lId;
                        csShare.UserOrGroupId = uId;
                        csShare.RowCause = 'Manual';
                        insertShareList.add(csShare);
                    }
                }
            }
        }
        if(!insertShareList.isEmpty())
            insert insertShareList;       
    }
    
    public static void siteApexShare(Map<Id, Set<Id>> apexShareUserMap) {
        List<Milestone1_Project__Share> insertShareList = new List<Milestone1_Project__Share>();
        List<Milestone1_Project__Share> deleteShareList = new List<Milestone1_Project__Share>();
        
        deleteShareList = [Select Id from Milestone1_Project__Share where ParentId IN: apexShareUserMap.keySet() AND RowCause = 'Manual'];
        if(!deleteShareList.isEmpty())
            delete deleteShareList;
        Map<Id,User> userMap = getUserMap(apexShareUserMap);
        for(Id lId: apexShareUserMap.keySet()) {
            Set<Id> uIdSet = apexShareUserMap.get(lId);
            if(uIdSet != null) {
                for(Id uId: uIdSet) {
                    if(userMap.get(uID) !=null && userMap.get(uID).isActive){
                        Milestone1_Project__Share csShare = new Milestone1_Project__Share();
                        csShare.AccessLevel = 'edit';
                        csShare.ParentId = lId;
                        csShare.UserOrGroupId = uId;
                        csShare.RowCause = 'Manual';
                        insertShareList.add(csShare);
                    }
                }
            }
        }
        if(!insertShareList.isEmpty())
            insert insertShareList;       
    }
    
    public static void checklistHeaderApexShare(Map<Id, Set<Id>> apexShareUserMap) {
        List<Checklist_Header__Share> insertShareList = new List<Checklist_Header__Share>();
        List<Checklist_Header__Share> deleteShareList = new List<Checklist_Header__Share>();
        
        deleteShareList = [Select Id from Checklist_Header__Share where ParentId IN: apexShareUserMap.keySet() AND RowCause = 'Manual'];
        if(!deleteShareList.isEmpty())
            delete deleteShareList;
        Map<Id,User> userMap = getUserMap(apexShareUserMap);
        for(Id lId: apexShareUserMap.keySet()) {
            Set<Id> uIdSet = apexShareUserMap.get(lId);
            if(uIdSet != null) {
                for(Id uId: uIdSet) {
                    if(userMap.get(uID) !=null && userMap.get(uID).isActive){
                        Checklist_Header__Share csShare = new Checklist_Header__Share();
                        csShare.AccessLevel = 'edit';
                        csShare.ParentId = lId;
                        csShare.UserOrGroupId = uId;
                        csShare.RowCause = 'Manual';
                        insertShareList.add(csShare);
                    }
                }
            }
        }
        if(!insertShareList.isEmpty())
            insert insertShareList;       
    }
    
    public static void caseApexShare(Map<Id, Set<Id>> apexShareUserMap) {
        List<CaseShare> insertShareList = new List<CaseShare>();
        List<CaseShare> deleteShareList = new List<CaseShare>();
        
        deleteShareList = [Select Id from CaseShare where CaseId IN: apexShareUserMap.keySet() AND RowCause = 'Manual'];
        if(!deleteShareList.isEmpty())
            delete deleteShareList;
        Map<Id,User> userMap = getUserMap(apexShareUserMap);
        for(Id lId: apexShareUserMap.keySet()) {
            Set<Id> uIdSet = apexShareUserMap.get(lId);
            if(uIdSet != null) {
                for(Id uId: uIdSet) {
                    if(userMap.get(uID) !=null && userMap.get(uID).isActive){
                        CaseShare csShare = new CaseShare();
                        csShare.CaseAccessLevel = 'edit';
                        csShare.CaseId = lId;
                        csShare.UserOrGroupId = uId;
                        csShare.RowCause = 'Manual';
                        insertShareList.add(csShare);
                    }
                }
            }
        }
        if(!insertShareList.isEmpty())
            insert insertShareList;       
    }
}