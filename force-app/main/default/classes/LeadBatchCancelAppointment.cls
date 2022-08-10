//16 Customer cancels appointment - Once a week for two weeks till another appointment is booked or till the lead is dropped
//SPS & BHS
global class LeadBatchCancelAppointment implements Database.Batchable<sObject>, Database.AllowsCallouts{
    Email_Parameters__c epara;
    Id userId;
    public LeadBatchCancelAppointment(){
        this.userId =userinfo.getUserId(); //require a valid whoId for renderStoredEmailTemplate method. It will not be used 
        this.epara = Email_Parameters__c.getOrgDefaults();
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date backDate = Date.today() -14;
        String backDateString = String.valueof(backDate.year()) +'-';
          if(backDate.month() >9)  backDateString +=  String.valueof(backDate.month())+'-';
              else backDateString += '0'+  String.valueof(backDate.month()) +'-';
        if(backDate.day() >9)  backDateString +=  String.valueof(backDate.day())  +'T00:00:00Z';
              else backDateString += '0'+  String.valueof(backDate.day())  +'T00:00:00Z';
             
        String query = 'SELECT RecordType.DeveloperName, MobilePhone, Email, Appointment_Cancelled_On__c, Last_Appointment_Start_Date_Time__c FROM Lead WHERE Status != \'Lost\' AND Appointment_Cancelled_On__c > '+ backDateString;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        List<Email_Log__c> eList = new List<Email_Log__c>(); 
        for(Lead l : leadList){
            if((l.Appointment_Cancelled_On__c >= l.Last_Appointment_Start_Date_Time__c) || l.Last_Appointment_Start_Date_Time__c == null){
                if(l.RecordType.DeveloperName =='SPS'){
                	Email_log__c e = SendEmailFromBatch.sendMail(l.Email, 'SPS_Testimonial_2', l.Id, this.epara, this.userId);
                    eList.add(e);
                }
                else if(l.RecordType.DeveloperName =='BHS'){
                	Email_log__c e = SendEmailFromBatch.sendMail(l.Email, 'BHS_testimonial_mailer_cancelled_appointmen', l.Id, this.epara, this.userId);
                    eList.add(e);
                }
                
            }
            
        }
        insert eList;
    }
    
  
global void finish(Database.BatchableContext BC) {
}

}