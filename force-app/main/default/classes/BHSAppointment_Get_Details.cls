@RestResource(urlMapping='/BHSAppointmentGetDetails/*')
//get appointment details of BHS Leads
global class BHSAppointment_Get_Details {
    @HttpPost
    global static REST_result getApptDetails(REST_Request[] request){
        REST_result r = new REST_result();
        r.returnCode = 201;
        r.message = null; 
        r.Appt_Start_Time=null;
        r.Appt_End_Time = null;
        for(REST_Request req: request)
        {
            if(string.isBlank(req.crmleadId))
            {
                r.returnCode = 201;
                r.message = 'crmLeadId should not be blank';  
                r.crmLeadId=null;
                r.Name=null;
                r.Appt_Start_Time=null;
                r.Appt_End_Time = null;
                r.eventId=null;
                return r;
            }
            else
            {     
                Lead l =[SELECT Last_Appointment_Start_Date_Time__c, Last_Appointment_End_Date_Time__c, Appointment_End_Time__c, Appointment_start_time__c, Name FROM Lead WHERE Id=:req.crmleadId];
                List<Event> eventList = [select id,whoId,subject,StartDateTime,owner.lastName,EndDateTime,owner.Name,ownerId from event where whoId =: req.crmleadId and 
                                   StartDateTime >=Today and type = 'Appointment' order by createdDate DESC];
                //r.Appt_Start_Time=eventList.StartDateTime.format();
                //r.Appt_End_Time = eventList.EndDateTime.format();
                if(eventList.isEmpty())
                {
                 	r.Appt_Start_Time = null;
                	r.Appt_End_Time = null;
                	r.Name=l.Name;
                	r.returnCode = 201;
                	r.message = 'Appointment Details not available'; 
                	r.crmLeadId=l.Id;
                	r.eventId=null; 
                	return r;   
                }
                else
                {
                    
                r.Appt_Start_Time = l.Last_Appointment_Start_Date_Time__c.format();
                r.Appt_End_Time = l.Last_Appointment_End_Date_Time__c.format();
                r.Name=l.Name;
                r.returnCode = 201;
                r.message = 'Success'; 
                r.crmLeadId=l.Id;
                r.eventId=eventList[0].Id; 
                return r;
                }
            }
        }
        return r;
    }
    global class REST_result
    {
        webservice String crmLeadId;
        webservice String Name;
        webservice Integer returnCode;
        webservice String message;
        webservice String Appt_Start_Time;
        webservice String Appt_End_Time; 
        webservice string eventId;        
    }
    global class REST_Request
    {
        webservice String crmleadId;   
    }
    
}