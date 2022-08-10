@RestResource(urlMapping='/BookSlot/*')
global class REST_BookSlot_YM {
    @HttpPOST
    global static REST_result bookSlot(string crmLeadId, string selectedSlot, Date selectedDate, string action, string eventId, string description, boolean WtsSendFlag,string crmUserId, string dealerId){
        REST_result r = new REST_result();
        if(string.isBlank(crmLeadId) || string.isBlank(selectedSlot) || string.isBlank(action) || string.isBlank(crmUserId) || selectedDate == null){
            r.returnCode = 201;
            r.message = 'crmLeadId, selectedDate, selectedSlot,crmUserId and action Parameters should not be blank';
            r.CRMleadId = null;
            r.CRMEventId = null;
            return r;
        }
        if(string.isNotBlank(action) && (action.equalsIgnoreCase('Cancel') || action.equalsIgnoreCase('Reschedule')) &&
          string.isBlank(eventId)){
            r.returnCode = 202;
            r.message = 'EventId mandatory to cancel or reschedule the appointment';
            r.CRMleadId = CRMLeadId;
            r.CRMEventId = null;
            return r;
        }
        
        List<event> existingEvent = Get_SA_Available_Slot.isCalendarBlocked(CRMLeadId); 
        if(existingEvent != null && !existingEvent.isEmpty() && action.equalsIgnoreCase('Book')){
            r.returnCode = 203;
            r.message = 'Appointment already booked.';
            r.CRMleadId = CRMLeadId;
            r.CRMEventId = existingEvent[0].Id;
            return r;
        }
        if(action.equalsIgnoreCase('Cancel')){
            List<Event> eventRecord = [select id from event where Id=:eventId];
            if(eventRecord != null && !eventRecord.isEmpty()){
                String msg = Get_SA_Available_Slot.deleteAppointment(eventId,CRMLeadId);
                if(msg == 'Success'){
                    r.returnCode = 200;
                    r.message = 'Appointment successfully cancelled';
                    r.CRMleadId = CRMLeadId;
                    r.CRMEventId = null;
                    return r;
                }else{
                    r.returnCode = 204;
                    r.message = 'Error in Appointment cancelled';
                    r.CRMleadId = CRMLeadId;
                    r.CRMEventId = eventId;
                    return r;
                }
            }else{
                r.returnCode = 205;
                r.message = 'EventId not exists in CRM';
                r.CRMleadId = CRMLeadId;
                r.CRMEventId = eventId;
                return r;
            }
            
        }
        
        Lead lObj = ScheduleAppointmentServices.getLead(crmLeadId);
        string role;
        if(lObj != null){
            if(lObj.RecordType.Name == 'SPS'){
                List<user> userRecord = [select id,name,profile.name from user where contactId =:crmUserId and isActive =true];
                if(userRecord != null && !userRecord.isEmpty()){
                    if(userRecord[0].Profile.Name == 'Customer Associate (CA)'){
                        role = 'CA';
                    }else{
                        role = 'SA';
                    }
                }else{
                    r.returnCode = 207;
                    r.message = 'Failed: User Record not exists';
                    r.CRMleadId = CRMLeadId;
                    r.CRMEventId = null;
                    return r;
                }
                   
            }else if(lObj.RecordType.Name == 'BHS'){
                role = 'BHS'; 
            }
        }else{
            r.returnCode = 206;
            r.message = 'Failed: Lead Record not exists';
            r.CRMleadId = CRMLeadId;
            r.CRMEventId = null;
            return r;
        }
        
        List<ScheduleAppointmentServices.SlotWrapper> resultWrapper = new List<ScheduleAppointmentServices.SlotWrapper>();
        if(role == 'SA' || role == 'BHS'){
            resultWrapper = ScheduleAppointmentServices.GetSlots_For_LWC_FIRST2(crmUserId,selectedDate,0,crmLeadId,null);
        }else if(role == 'CA'){
            resultWrapper = ScheduleAppointmentServices.GetSlots_For_LWC_Second2(crmUserId,selectedDate,0,crmLeadId,null);
        }
        
        if(resultWrapper != null && !resultWrapper.isEmpty()){
            Map<date, List<string>> slotMap = new Map<Date,List<string>>();
            for(ScheduleAppointmentServices.SlotWrapper sw : resultWrapper){
                slotMap.put(sw.scheduleDate, sw.available_Slots);
            }
            if(!slotMap.containsKey(selectedDate)){
                r.returnCode = 208;
                r.message = 'Failed: No slots for the selectedDate';
                r.CRMleadId = CRMLeadId;
                r.CRMEventId = null;
                return r;
            }else{
                boolean slotAvailable = false;
                for(string st : slotMap.get(selectedDate)){
                    if(st == selectedSlot){
                        slotAvailable = true;
                    }
                }
                if(!slotAvailable){
                    r.returnCode = 209;
                    r.message = 'Failed: Selected slot already booked';
                    r.CRMleadId = CRMLeadId;
                    r.CRMEventId = null;
                    return r;
                }else{
                    ScheduleAppointmentServices.SuccessWrapper msg = new ScheduleAppointmentServices.SuccessWrapper();
                    if(action.equalsIgnoreCase('Reschedule')){
                        msg = ScheduleAppointmentServices.Bot_bookSlot(crmLeadId, selectedSlot, selectedDate, crmUserId, description,true, eventId,dealerId);
                    } else if(action.equalsIgnoreCase('Book')){
                        msg = ScheduleAppointmentServices.Bot_bookSlot(crmLeadId, selectedSlot, selectedDate, crmUserId, description,false, null,dealerId);
                    }
                    system.debug('msg::'+msg);
                    if(msg.message == 'Success'){
                        Lead leadObj = ScheduleAppointmentServices.getLead(crmLeadId);
                        if(leadObj != null) {
                            leadObj.Bot_Journey__c = 'Appointment Scheduled-YM';
                            update leadObj;    
                        }
                        
                        r.returnCode = 200;
                        r.message = 'Success: Appointment booked successfully';
                        r.CRMleadId = CRMLeadId;
                        r.CRMEventId = msg.eventId;
                        return r;
                    }else{
                        r.returnCode = 210;
                        r.message = 'Failed: Appointment booking failed';
                        r.CRMleadId = CRMLeadId;
                        r.CRMEventId = null;
                        return r;
                    }
                }
            }
        }else{
            r.returnCode = 207;
            r.message = 'Failed: No slots available';
            r.CRMleadId = CRMLeadId;
            r.CRMEventId = null;
            return r;
        }
                
        //return null;
    }
    
    global class REST_result {
        webservice Integer returnCode;
        webservice String message;
        webservice String CRMleadId;
        webservice String CRMEventId;
    }
}