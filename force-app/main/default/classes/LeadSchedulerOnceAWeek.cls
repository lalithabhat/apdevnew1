global class LeadSchedulerOnceAWeek implements Schedulable {
	 global void execute(SchedulableContext SC) {
      	LeadBatchCancelAppointment b2 = new LeadBatchCancelAppointment();
       database.executebatch(b2,100);
   }
}