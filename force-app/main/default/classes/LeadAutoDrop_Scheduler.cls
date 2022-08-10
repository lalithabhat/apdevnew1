global class LeadAutoDrop_Scheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      LeadAutoDrop_Batch cdp = new LeadAutoDrop_Batch();
       database.executebatch(cdp,100);
   }
}