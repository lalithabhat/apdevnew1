/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 20-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide all Task services.
*********************************************************************************************************/
public class AP_TaskManagementService {
    public static void latestTaskRollup(Set<Id> taskId) {
        List<Task> taskList = new List<Task>();
        List<Lead> leadList = new List<Lead>();
        List<Lead> updateLeadList = new List<Lead>();
        Map<Id, Task> leadTaskMap = new Map<Id, Task>();
        
        taskList = [Select Id, WhoId, WhatId, Disposition__c, toLabel(Sub_Disposition__c), Follow_Up_DateTime__c, CreatedDate, Language__c from Task 
                    where Id IN: taskId];
        if(!taskList.isEmpty()) {
            for(Task t: TaskList) {
                if(t.whoId != null && t.whoId.getSObjectType().getDescribe().getName() == 'Lead') {
                    if(leadTaskMap.containsKey(t.whoId)) {
                        if(leadTaskMap.get(t.whoId).createdDate < t.createdDate) {
                            leadTaskMap.put(t.whoId, t);
                        }
                    } else {
                        leadTaskMap.put(t.whoId, t);
                    }
                }
            }
            leadList = [Select Id, Call_Disposition__c, Sub_Disposition_in_Last_Call__c, FollowUp_DateTime_in_Last_Call__c, Is_Serviced__c, Language__c from Lead 
                    where Id IN: leadTaskMap.keySet() AND IsConverted = false];
            
            if(!leadList.isEmpty()) {
                for(Lead l: leadList) {
                    if(leadTaskMap.containsKey(l.Id)) {
                    	l.Call_Disposition__c = leadTaskMap.get(l.Id).Disposition__c;
                        l.Sub_Disposition_in_Last_Call__c = leadTaskMap.get(l.Id).Sub_Disposition__c;
                        l.FollowUp_DateTime_in_Last_Call__c = leadTaskMap.get(l.Id).Follow_Up_DateTime__c;
                        l.Is_Serviced__c = true;
                        l.Language__c = leadTaskMap.get(l.Id).Language__c;
                        updateLeadList.add(l);
                    }
                }
            }
        }
        if(!updateLeadList.isEmpty())
            update updateLeadList;
    }
    
    public static void updateNCTCountParentDetails(Set<Id> taskId) {
        List<Task> taskList = new List<Task>();
        List<Lead> leadList = new List<Lead>();
        List<Lead> updateLeadList = new List<Lead>();
        Map<Id, List<Task>> mapLeadTask = new Map<Id, List<Task>>();
        
        taskList = [Select Id, WhoId, WhatId from Task where Id IN: taskId];
        if(!taskList.isEmpty()) {
            for(Task t: taskList) {
                if(t.whoId != null && t.WhoId.getSObjectType().getDescribe().getName() == 'Lead') {
                    if(!mapLeadTask.containsKey(t.WhoId)) {
                        List<Task> tList = new List<Task>();
                        tList.add(t);
                        mapLeadTask.put(t.WhoId, tList);
                    } else {
                        mapLeadTask.get(t.WhoId).add(t);
                    }
                }
            }
            if(mapLeadTask != null)
                leadList = [Select Id, NCT_Counter__c from Lead where Id IN: mapLeadTask.keySet() AND IsConverted = false];
            
            if(!leadList.isEmpty()) {
                for(Lead l: leadList) {
                    if(mapLeadTask.containsKey(l.Id)) {
                        if(l.NCT_Counter__c != null)
                            l.NCT_Counter__c += mapLeadTask.get(l.Id).size();
                        else
                            l.NCT_Counter__c = mapLeadTask.get(l.Id).size();
                        updateLeadList.add(l);
                    }
                }
            }
        }
        if(!updateLeadList.isEmpty())
            update updateLeadList;
    }
    
    public static void rollupBhStoreTasks(Set<Id> taskId) {
        List<Task> taskList = new List<Task>();
        List<Lead> leadList = new List<Lead>();
        List<Lead> updateLeadList = new List<Lead>();
        Map<Id, Task> leadTaskMap = new Map<Id, Task>();
        
        taskList = [Select Id, WhoId, WhatId, Disposition__c,Next_Action__c,Follow_Up_DateTime__c, toLabel(Sub_Disposition__c), CreatedDate, Language__c from Task 
                    where Id IN: taskId];
        if(!taskList.isEmpty()) {
            for(Task t: TaskList) {
                if(t.whoId != null && t.whoId.getSObjectType().getDescribe().getName() == 'Lead') {
                    if(leadTaskMap.containsKey(t.whoId)) {
                        if(leadTaskMap.get(t.whoId).createdDate < t.createdDate) {
                            leadTaskMap.put(t.whoId, t);
                        }
                    } else {
                        leadTaskMap.put(t.whoId, t);
                    }
                }
            }
            leadList = [Select Id, Call_Disposition__c, Sub_Disposition_in_Last_Call__c, FollowUp_DateTime_in_Last_Call__c, Is_Serviced__c, Language__c from Lead 
                    where Id IN: leadTaskMap.keySet() AND IsConverted = false];
            
            if(!leadList.isEmpty()) {
                for(Lead l: leadList) {
                    if(leadTaskMap.containsKey(l.Id)) {
                    	/*l.Call_Disposition__c = leadTaskMap.get(l.Id).Disposition__c;
                        l.Sub_Disposition_in_Last_Call__c = leadTaskMap.get(l.Id).Sub_Disposition__c;
                        l.FollowUp_DateTime_in_Last_Call__c = leadTaskMap.get(l.Id).Follow_Up_DateTime__c;
                        l.Is_Serviced__c = true;
                        l.Language__c = leadTaskMap.get(l.Id).Language__c;*/
                       // l.Next_Action__c = leadTaskMap.get(l.Id).Next_Action__c;
                      // l.LastModifiedTime__c = leadTaskMap.get(l.Id).Follow_Up_DateTime__c;
                        updateLeadList.add(l);
                    }
                }
            }
        }
        if(!updateLeadList.isEmpty())
            update updateLeadList;
    }
}