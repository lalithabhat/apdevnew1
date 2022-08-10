@RestResource(urlMapping='/BHSAppointmentBookSlot/*')
global class BHSAppointment_Book_Slot {
    @HttpPOST
    global static REST_result bookSlot(REST_Request[] request){
        REST_result r = new REST_result();
        for(REST_Request req: request)
        {
        if(string.isBlank(req.crmLeadId) || string.isBlank(req.selectedSlot) || string.isBlank(req.action) || string.isBlank(req.crmUserId) || req.selectedDate == null){
            r.returnCode = 201;
            r.message = 'crmLeadId, selectedDate, selectedSlot,crmUserId and action Parameters should not be blank';
            r.CRMleadId = null;
            r.CRMEventId = null;
            return r;
        }
        if(string.isNotBlank(req.action) && (req.action.equalsIgnoreCase('Cancel') || req.action.equalsIgnoreCase('Reschedule')) &&
          string.isBlank(req.eventId)){
            r.returnCode = 202;
            r.message = 'EventId mandatory to cancel or reschedule the appointment';
            r.CRMleadId = req.CRMLeadId;
            r.CRMEventId = null;
            return r;
        }
        
        List<event> existingEvent = Get_SA_Available_Slot.isCalendarBlocked(req.CRMLeadId); 
        if(existingEvent != null && !existingEvent.isEmpty() && req.action.equalsIgnoreCase('Book')){
            r.returnCode = 203;
            r.message = 'Appointment already booked';
            r.CRMleadId = req.CRMLeadId;
            r.CRMEventId = existingEvent[0].Id;
            return r;
        }
        if(req.action.equalsIgnoreCase('Cancel')){
            List<Event> eventRecord = [select id from event where Id=:req.eventId];
            if(eventRecord != null && !eventRecord.isEmpty()){
                String msg = Get_SA_Available_Slot.deleteAppointment(req.eventId,req.CRMLeadId);
                if(msg == 'Success'){
                    r.returnCode = 200;
                    r.message = 'Appointment successfully cancelled';
                    r.CRMleadId = req.CRMLeadId;
                    r.CRMEventId = null;
                    return r;
                }else{
                    r.returnCode = 204;
                    r.message = 'Error in Appointment cancelled';
                    r.CRMleadId = req.CRMLeadId;
                    r.CRMEventId = req.eventId;
                    return r;
                }
            }else{
                r.returnCode = 205;
                r.message = 'EventId not exists in CRM';
                r.CRMleadId = req.CRMLeadId;
                r.CRMEventId = req.eventId;
                return r;
            }
            
        }
        
        Lead lObj = ScheduleAppointmentServices.getLead(req.crmLeadId);
        string role;
        if(lObj != null){
           /* if(lObj.RecordType.Name == 'SPS'){
                List<user> userRecord = [select id,name,profile.name from user where contactId =:req.crmUserId and isActive =true];
                if(userRecord != null && !userRecord.isEmpty()){
                    if(userRecord[0].Profile.Name == 'Customer Associate (CA)'){
                        role = 'CA';
                    }else{
                        role = 'SA';
                    }
                }else{
                    r.returnCode = 207;
                    r.message = 'Failed: User Record not exists';
                    r.CRMleadId = req.CRMLeadId;
                    r.CRMEventId = null;
                    return r;
                }
                   
            }*/
            if(lObj.RecordType.Name == 'BHS'){
                role = 'BHS'; 
            }
        }else{
            r.returnCode = 206;
            r.message = 'Failed: Lead Record not exists';
            r.CRMleadId = req.CRMLeadId;
            r.CRMEventId = null;
            return r;
        }
        
        List<ScheduleAppointmentServices.SlotWrapper> resultWrapper = new List<ScheduleAppointmentServices.SlotWrapper>();
            System.debug('role'+role);
        if(role == 'SA' || role == 'BHS'){
            resultWrapper = ScheduleAppointmentServices.GetSlots_For_LWC_FIRST2(req.crmUserId,req.selectedDate,0,req.crmLeadId,null);
        }
        
        if(resultWrapper != null && !resultWrapper.isEmpty()){
            Map<date, List<string>> slotMap = new Map<Date,List<string>>();
            for(ScheduleAppointmentServices.SlotWrapper sw : resultWrapper){
                slotMap.put(sw.scheduleDate, sw.available_Slots);
            }
            if(!slotMap.containsKey(req.selectedDate)){
                r.returnCode = 208;
                r.message = 'Failed: No slots for the selectedDate';
                r.CRMleadId = req.CRMLeadId;
                r.CRMEventId = null;
                return r;
            }else{
                boolean slotAvailable = false;
                for(string st : slotMap.get(req.selectedDate)){
                    if(st == req.selectedSlot ){
                        slotAvailable = true;
                    }
                }
                if(!slotAvailable){
                    r.returnCode = 209;
                    r.message = 'Failed: Selected slot already booked';
                    r.CRMleadId = req.CRMLeadId;
                    r.CRMEventId = null;
                    return r;
                }else{
                    ScheduleAppointmentServices.SuccessWrapper msg = new ScheduleAppointmentServices.SuccessWrapper();
                    if(req.action.equalsIgnoreCase('Reschedule')){
                        msg = ScheduleAppointmentServices.Bot_bookSlot(req.crmLeadId, req.selectedSlot, req.selectedDate, req.crmUserId, req.description,true, req.eventId,req.dealerId);
                    } else if(req.action.equalsIgnoreCase('Book')){
                        msg = ScheduleAppointmentServices.Bot_bookSlot(req.crmLeadId, req.selectedSlot, req.selectedDate, req.crmUserId, req.description,false, null,req.dealerId);
                    	system.debug('msg::'+msg);
                    }
                    //system.debug('msg::'+msg);
                    if(msg.message == 'Success'){
                        Lead leadObj = ScheduleAppointmentServices.getLead(req.crmLeadId);
                        if(leadObj != null) {
                            leadObj.Bot_Journey__c = 'Appointment Scheduled-BHS';
                            update leadObj;    
                        }
                        
                        r.returnCode = 200;
                        r.message = 'Success: Appointment booked successfully';
                        r.CRMleadId = req.CRMLeadId;
                        r.CRMEventId = msg.eventId;
                        return r;
                    }else{
                        r.returnCode = 210;
                        r.message = 'Failed: Appointment booking failed '+ msg.userId; // user userId to hold error details
                        r.CRMleadId = req.CRMLeadId;
                        r.CRMEventId = null;
                        return r;
                    }
                }
            }
        }else{
            r.returnCode = 207;
            r.message = 'Failed: No slots available';
            r.CRMleadId = req.CRMLeadId;
            r.CRMEventId = null;
            return r;
        }
        }       
        //return null
        return r;
    }
    
    global class REST_Request {
        	webservice string crmLeadId; 
            webservice string selectedSlot; 
            webservice Date selectedDate;
            webservice string action; 
            webservice string eventId; 
            webservice string description; 
            webservice boolean WtsSendFlag;
            webservice string crmUserId; 
            webservice string dealerId;
    }
		global class REST_result {
        webservice Integer returnCode;
        webservice String message;
        webservice String CRMleadId;
        webservice String CRMEventId;
    }
}