public class CloseWork {

    @InvocableMethod(label='Update Workfrom flow' Description='use in flow for the Updating the Work as close')
    public static List<string> updateWork(List<Id> workId){
        system.debug('inside update work method::'+workId);
        List<Milestone1_Milestone__c > workList = [select id,name,Complete__c from Milestone1_Milestone__c where Id IN:workId];
        List<string> stList = new List<String>();
        if(workList != null && !workList.isEmpty()){
            try{
                List<Milestone1_Task__c > taskList = [select id,name,Complete__c from Milestone1_Task__c where 
                                                  Project_Milestone__c IN : workId];
                if(taskList != null && !taskList.isEmpty()){
                    for(Milestone1_Task__c t : taskList){
                        t.Complete__c = true;
                    }
                    update taskList;
                }
                workList[0].Complete__c = true;
                update workList;
                stList.add('Success');
                return stList;
            }Catch(Exception ex){
                stList.add('Failed');
                return stList;
            }
            
        }
        return null;
    }
    
    
}