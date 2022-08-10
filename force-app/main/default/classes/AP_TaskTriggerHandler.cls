/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 20-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and filter all the Task based on the trigger actions.
*********************************************************************************************************/
public class AP_TaskTriggerHandler {
	public static void onAfterInsert(List<Task> taskList) {
        Set<Id> taskId = new Set<Id>();
        Set<Id> nctTaskId = new Set<Id>();
        Set<Id> bhStoreTasks = new Set<Id>();
        
        for(Task t: taskList) {
            if(t.Subject == 'Call')
            	taskId.add(t.Id);
            if(t.Subject == 'NCT Call' && t.WhoId != null)
                nctTaskId.add(t.Id);
            if(t.Subject == 'Next Action')
                bhStoreTasks.add(t.Id);
        }
        if(bhStoreTasks != null && !bhStoreTasks.isEmpty()){
            AP_TaskManagementService.rollupBhStoreTasks(bhStoreTasks);
        }
        if(!taskId.isEmpty() && taskId != null) {
            AP_TaskManagementService.latestTaskRollup(taskId);
         	AP_CTIManagementService.sendCallDispositionCTI(taskId);
        }
        if(!nctTaskId.isEmpty() && nctTaskId != null)
            AP_TaskManagementService.updateNCTCountParentDetails(nctTaskId);
    }
}