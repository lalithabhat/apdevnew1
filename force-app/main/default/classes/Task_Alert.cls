public without sharing class Task_Alert {
    public static void checkCompletion(List<Milestone1_Task__c> task,List<Milestone1_Task__c> taskOld){
      
        if(task[0].Complete__c != taskOld[0].Complete__c){
             
            Decimal completeDays = 0;
            Decimal totalDays = 0;
            List<Milestone1_Milestone__c> workList = new List<Milestone1_Milestone__c>();
            for(Milestone1_Task__c t : [SELECT Complete__c, No_of_days__c FROM Milestone1_Task__c 
                                        WHERE Project_Milestone__c =: task[0].Project_Milestone__c
                                        AND Id !=: task[0].Id]){
                                            if(t.No_of_Days__c !=null){
                                                if(t.Complete__c) completeDays +=t.No_of_days__c;
                                                totalDays +=t.No_of_days__c;
                                            }
                                        }
            Decimal completeDaysOld = completeDays;
            Decimal totalDaysOld = totalDays;
            if(task[0].Complete__c) completeDays += task[0].No_of_Days__c;
            if(taskOld[0].Complete__c) completeDaysOld += taskOld[0].No_of_Days__c;
            totalDays += task[0].No_of_Days__c;
            totalDaysOld += taskOld[0].No_of_Days__c;
            system.debug(completeDays +' '+ totalDays + ' '+completeDaysOld);
            if(totalDays >0){
                Decimal per = completeDays / totalDays *100;
                Decimal oldPer = completeDaysOld / totalDays *100;
               // if( per > oldPer){
                     system.debug('per '+ per +' oldper '+ oldper );
                    for(Integer mileStone : new List<Integer>{80,60,40,20}){
                         system.debug('n trigger method'+ milestone);
                        if(per >= mileStone && oldPer < mileStone){
                            Set<String> recipient = new Set<String>{[SELECT Project__r.ownerid from Milestone1_Milestone__c WHERE ID =:task[0].Project_Milestone__c][0].Project__r.ownerid}; 
                                Notification_Utility.notifyUsers(recipient,task[0].Project_Milestone__c,'Work Milestone Achieved!','Time to send Work Report');
                            break;
                        }
                    } 
              //  }
            }
            
        }
    }
    
   
}