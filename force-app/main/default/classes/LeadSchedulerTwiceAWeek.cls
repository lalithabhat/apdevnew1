global class LeadSchedulerTwiceAWeek implements Schedulable {
	 global void execute(SchedulableContext SC) {
      LeadBatchTwiceAWeek b1 = new LeadBatchTwiceAWeek();
       database.executebatch(b1,100);
   }
}