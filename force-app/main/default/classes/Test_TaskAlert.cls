@isTest
public class Test_TaskAlert {
	@isTest
    static void test(){
         Milestone1_Project__c site = new Milestone1_Project__c(status__c ='Active', Tier__c ='Platinum', New_Service__c ='San Assure');
        Insert site;
        Milestone1_Milestone__c work = new Milestone1_Milestone__c(Name ='Work 1', Project__c = site.Id);
        Insert work;
        Milestone1_Task__c task = new Milestone1_Task__c(Name ='Task 1', Project_Milestone__c = work.Id,Start_Date__c =Date.today(), Due_Date__c = Date.Today()+ 5);
        Insert task;
         Milestone1_Task__c task2 = new Milestone1_Task__c(Name ='Task 1', Project_Milestone__c = work.Id,Start_Date__c =Date.today(), Due_Date__c = Date.Today()+ 5);
        Insert task2;
        Milestone1_Task__c taskN = new Milestone1_Task__c(Id = task.Id, Complete__c = true);
        Update taskn;
    }
}