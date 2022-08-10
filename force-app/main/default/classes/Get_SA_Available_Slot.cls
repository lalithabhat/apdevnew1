public without sharing class Get_SA_Available_Slot {	
   /* @InvocableMethod(label='Get SA Available Slots' description='Iterate over Event on SA Calendar')
    public static List<List<String>> getSlots(List<c_Request> req){
       // List<List<event>> available_Event_List = new List<List<event>>();
        List<event> available_Slots = new List<event>();
        List<String> slots_In_String = new List<String>();
        List<List<String>> slots_In_String_Final = new List<List<String>>();
        system.debug('inside getSlots:: '+req);
        if(req != null && !req.isEmpty()){
            string uId = req[0].userId;
            DateTime visit_Dt = req[0].visit_Date;
            String month_ST = string.valueOf(visit_Dt.month());
            if(month_ST.length() == 1)month_ST = '0' + month_ST;
            
            String day_ST = string.valueOf(visit_Dt.Day());
            if(day_ST.length() == 1)day_ST = '0' + day_ST;
            
            string startTime_Of_Visit_Date = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T00:00:00Z';
            string endTime_Of_Visit_Date = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T23:59:59Z';
            
            string lId = req[0].leadId;
            string startTimeField = 'StartDateTime';
            string endTimeField = 'EndDateTime';
            
            string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ' +
    						string.valueOf(startTimeField) + '>=' + startTime_Of_Visit_Date + ' AND ' + 
               			    string.valueOf(endTimeField) + '<=' + endTime_Of_Visit_Date + ' AND ' +
                			'ownerId = ' + '\'' + uId + '\'';
        	List<Event> eventList = Database.query(query);
            system.debug('eventList:: '+eventList);
            
            Map<Integer,Integer> slotMap = new Map<Integer,Integer>{10=>11,11=>12,12=>13,13=>14,14=>15,15=>16,
                													16=>17,17=>18};
            Map<Integer,Integer> allotted_slotMap = new Map<Integer,Integer>();
            Map<Integer,Integer> available_slotMap = new Map<Integer,Integer>();
            if(eventList != null && !eventList.isEmpty()){
                for(Event e : eventList){
                    if(e.StartDateTime != null && e.EndDateTime != null){
               ////////// If the all the event
                        if(e.IsAllDayEvent){
                            allotted_slotMap.putAll(slotMap);
                        }
              ///////// If the event is greater than 1 hr          
                        Integer start_Hour = e.StartDateTime.hour();
                        Integer end_hour = e.EndDateTime.hour();
                        if(end_hour - start_Hour > 1){
                            allotted_slotMap.put(start_Hour,end_hour);
                            allotted_slotMap.put(start_Hour + 1,end_hour);
                        }else{
                        	allotted_slotMap.put(e.StartDateTime.hour(),e.EndDateTime.hour());
                        }
                    }
                }
            }
         /////// If the there are existing slots allotted then adding the available slots   
            if(!allotted_slotMap.isEmpty()){
                for(Integer slt : slotMap.keyset()){
                    if(allotted_slotMap.containskey(slt)){
                        /// allotted slots
                    }else{
                        ////// available slots
                        available_slotMap.put(slt,slotMap.get(slt));
                    }
                }
            }else{
                /////////// If the there is no existing slot allotted then adding whole day slots
                available_slotMap.putAll(slotMap);
            }
            
        /////////// adding event 
            if(!available_slotMap.isEmpty()){
                for(Integer key : available_slotMap.keyset()){
                    Event e = new Event();
                    e.whoId = lId;
                    e.OwnerId = uId;
                    string starting_Event_Time = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T' + key + ':00:00Z';
                    string end_Event_Time = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T' + available_slotMap.get(key) + ':00:00Z';
                    e.StartDateTime = DateTime.ValueOf(JSON.deserialize(starting_Event_Time, DateTime.class));      //DateTime.valueOf(starting_Event_Time);
                    e.EndDateTime = DateTime.ValueOf(JSON.deserialize(end_Event_Time, DateTime.class));              ///DateTime.valueOf(end_Event_Time);
                    e.Subject = 'SA Appointment';
                    //c_Response res = new c_Response();
                    //res.slots_List = e;
                   // available_Event_List.add(e);
                    available_Slots.add(e);
                    slots_In_String.add(key + '-' + available_slotMap.get(key));
                }
            }    
        }
        slots_In_String_Final.add(slots_In_String);
       // available_Event_List.add(available_Slots);
        //return available_Event_List;
        return slots_In_String_Final;
    }    */
    
  //////////////////////////Added post go live for updating lead in Apex
    @AuraEnabled
    Public static string updateLeadApex(string method, string userId, Datetime sTime, Datetime eTime,String recordId, String selectedSAId, String SADeclinedreason, String dealerName){
        try{
        system.debug(sTime +' '+ eTime);
        Lead l = new Lead();
        l.id = recordId;
        l.Status ='Allocation Done';
        l.OwnerId = userId;
        l.Assigned_To__c = selectedSAId;
        if(method == 'bookSlot'){
            l.Last_Appointment_Start_Date_Time__c = sTime;
            l.Last_Appointment_End_Date_Time__c = eTime;
            l.Assign_without_Appointment__c = false;
            l.Assign_Without_Appointment_Datetime__c = null;
        }
        if(method == 'assignWithoutAppointment'){
            l.Assign_without_Appointment__c = true;
            l.Assign_Without_Appointment_Datetime__c = sTime;
             l.Last_Appointment_Start_Date_Time__c = null;
            l.Last_Appointment_End_Date_Time__c = null;
        }
        if(SADeclinedreason != null && SADeclinedreason != ''){
            l.SA_Declined__c = true;
        }
        
       l.Reason_For_SA_Declined__c = SADeclinedreason;
        if(dealerName != null){
            l.Dealer__c = dealerName;
        }
        system.debug('lead:::'+l);
        
        update l;
       	return '';
        }catch(exception e){
            System_Log__c SL = new System_Log__c();
            SL.Lead__c = recordId;
            SL.API_Name__c  = 'Appointment Booking LWC';
            SL.Request__c = e.getMessage() + e.getLineNumber();
            insert sl;
         	return e.getMessage();
        }
    }
 ////////////////////////////// GET LEAD RECORD 
 	@AuraEnabled(cacheable=true)
    Public static Lead getLead(string lId){
        Lead lead = ScheduleAppointmentServices.getLead(lId);
        system.debug('lead:::'+lead);
        return lead;
    }
    
    @AuraEnabled(cacheable=true)
    Public static string checkDateValidation(date appointment_Date){
        if(appointment_Date < system.today()){
            return 'false';
        }
        return 'true';
    }    
    
    
/////////////////////////////// GET ContactList    
    @AuraEnabled(cacheable=true)
    Public static ScheduleAppointmentServices.UserWrapper getContactList(string lId){
        Lead lead = ScheduleAppointmentServices.getLead(lId);
        system.debug('pincode:: '+lead.Pincode__c);
      //  system.debug('BU:: '+BU);
        List<SA_Pincode_Mapping__c> userList = new List<SA_Pincode_Mapping__c>();
        if(lead != null){
            if(lead.RecordType.Name == 'SPS'){
            	userList = ScheduleAppointmentServices.getUsers_For_SPS(lead.Pincode__c,Lead.RecordType.Name, null);
            }else if(lead.RecordType.Name == 'BHS'){
                userList = ScheduleAppointmentServices.getUsers_For_BHS(lead.Pincode__c,Lead.RecordType.Name, null);
            }
        }
        system.debug('userList:::'+userList);
        ScheduleAppointmentServices.UserWrapper uw = new ScheduleAppointmentServices.UserWrapper();
        uw.BU = lead.RecordType.Name;
        uw.userList = userList;
        return uw;
    }
    
////////////////////// GET AVAILABLE SLOTS
	@AuraEnabled(cacheable=true)
    Public static List<ScheduleAppointmentServices.SlotWrapper> getSlots(string userId, string role, date appointment_Date,string lId){
        List<User> user = ScheduleAppointmentServices.getCAFromId(userId);
        if(user != null && !user.isEmpty()){
            Integer no_of_Days = 5;
            if(!Test.isRunningTest()){
                List<Appointment_Scheduling_Days__c> no_of_Days_List = Appointment_Scheduling_Days__c.getAll().values();
                no_of_Days = Integer.valueOf(no_of_Days_List[0].Number_Of_Days__c);
            }
            if(role == 'SA' || role == 'BHS'){
                system.debug('inside getSlots:::');
                List<ScheduleAppointmentServices.SlotWrapper> resultWrapper = ScheduleAppointmentServices.GetSlots_For_LWC_FIRST2(userId,appointment_Date,no_of_Days,lId,null);
                system.debug('resultWrapper:::'+resultWrapper);
                List<ScheduleAppointmentServices.SlotWrapper> resultWrapper_For_10_Slots = new List<ScheduleAppointmentServices.SlotWrapper>();
                if(resultWrapper != null && !resultWrapper.isEmpty()){
                    resultWrapper.sort();
                    if(resultWrapper.size() > 6){
                        for(Integer i=0;i<6; i++){
                            resultWrapper_For_10_Slots.add(resultWrapper[i]);
                        }
                        return resultWrapper_For_10_Slots;
                    }
                }
                RETURN resultWrapper;
            }else if(role == 'CA'){  
                List<ScheduleAppointmentServices.SlotWrapper> resultWrapper = ScheduleAppointmentServices.GetSlots_For_LWC_Second2(userId,appointment_Date,no_of_Days,lId,null);
                system.debug('resultWrapper:::'+resultWrapper);
                List<ScheduleAppointmentServices.SlotWrapper> resultWrapper_For_10_Slots = new List<ScheduleAppointmentServices.SlotWrapper>();
                if(resultWrapper != null && !resultWrapper.isEmpty()){
                    resultWrapper.sort();
                    if(resultWrapper.size() > 6){
                        for(Integer i=0;i<6; i++){
                            resultWrapper_For_10_Slots.add(resultWrapper[i]);
                        }
                        return resultWrapper_For_10_Slots;
                    }
                }
                RETURN resultWrapper;
            }
        }else{
            List<ScheduleAppointmentServices.SlotWrapper> resultWrapper = new List<ScheduleAppointmentServices.SlotWrapper>();
            ScheduleAppointmentServices.SlotWrapper rw = new ScheduleAppointmentServices.SlotWrapper();
            rw.noUser = true;
            resultWrapper.add(rw);
            return resultWrapper;
        }
        
        return null;
    }
    
    /////////////////////////////// GET CA Details
    @AuraEnabled(cacheable=true)
    Public static ScheduleAppointmentServices.CADetailsWrapper getCAList(string lId, string CARecord){
        Lead lead = getLead(lId);
        system.debug('CARecord:::'+CARecord);
        ScheduleAppointmentServices.CADetailsWrapper CAObj = new ScheduleAppointmentServices.CADetailsWrapper();
        if(CARecord != null){
            CAObj = (ScheduleAppointmentServices.CADetailsWrapper)JSON.deserialize(CARecord, ScheduleAppointmentServices.CADetailsWrapper.class);
        }
        ScheduleAppointmentServices.CADetailsWrapper cdw = ScheduleAppointmentServices.getCA(lead,CAObj);
        if(cdw != null){
            List<User> userList = ScheduleAppointmentServices.getUser_From_Id(cdw.CA.Id);
            List<Contact> cList = new list<Contact>();
            if(userList != null && !userList.isEmpty()){
                cList = ScheduleAppointmentServices.getContactDetails(userList[0].contactId);
            }
            cdw.CA_Contact = cList[0];
            cdw.phone = cList[0].MobilePhone; //system.debug('cdw.CA_Contact:: '+cdw.CA_Contact.mobilePhone);
        }
        
       /* if(CARecord != null){
            List<Contact> cList = new list<Contact>();
            cList = ScheduleAppointmentServices.getContactDetails('00372000001BdFBAA0');
            cdw.CA_Contact = cList[0];
        }else{
            List<Contact> cList = new list<Contact>();
            cList = ScheduleAppointmentServices.getContactDetails('00372000001A46bAAC');
            system.debug('cList::'+cList);
            cdw.CA_Contact = cList[0];
        }*/
       // system.debug('ca::'+cdw.CA_Contact);
        return cdw;
    } 
    
    @AuraEnabled
    public static ScheduleAppointmentServices.SuccessWrapper bookSlot(string lId,string slot,Date appointmentDate, string userId, string SADeclinedReason,boolean isReschdule, string eventId){
        system.debug('Inside bookSlot method slot::'+slot);
        ScheduleAppointmentServices.SuccessWrapper msg = ScheduleAppointmentServices.bookSlot(lId, slot, appointmentDate, userId, SADeclinedReason,isReschdule, eventId);
       
        return msg;
    }
    
    @AuraEnabled(cacheable=true)
    public static ScheduleAppointmentServices.SuccessWrapper assignCAWithoutAppointmentApex(string lId,string userId){
        // try{
        string owner = userId;
        string userName ='';
        boolean isContact = userId.startsWith('003');
        if(isContact){
            system.debug('isnide');
            List<User> userList = ScheduleAppointmentServices.getCAFromId(userId);
            if(userList != null && !userList.isEmpty())
            {owner = userList[0].id;
             userName = userList[0].Name;
            }
            system.debug('userList::'+userList);
        }
        List<Lead> todaysLeads = [Select Id from Lead WHERE ownerId =: owner AND Assign_Without_Appointment_Datetime__c = today AND Assign_without_Appointment__c = true AND Id !=: lId];
        List<Appointment_Scheduling_Days__c> daysList = Appointment_Scheduling_Days__c.getAll().values();
        Integer bookings = Integer.valueOf(daysList[0].Surge_Bookings__c);
        if(todaysLeads.size() >= bookings)
            throw new AuraHandledException('Assign Without Appointment Limit Exceeded For User '+ userName);
        // }
        
        ScheduleAppointmentServices.SuccessWrapper sw = new ScheduleAppointmentServices.SuccessWrapper('Success',owner,system.now(),null);
        return sw;
        // }Catch(Exception ex){
        //     system.debug('Fail:: '+ex.getMessage());
        //     ScheduleAppointmentServices.SuccessWrapper sw = new ScheduleAppointmentServices.SuccessWrapper('Fail',ex.getMessage(),null,null);
        // 	return sw;
        // }
    }
    
    @AuraEnabled(cacheable=true)
    public static String Bot_assignCAWithoutAppointmentApex(string lId,string userId,string dealerId){
        try{
            string owner = userId;
            boolean isContact = userId.startsWith('003');
            if(isContact){
                system.debug('isnide');
                List<User> userList = ScheduleAppointmentServices.getCAFromId(userId);
                if(userList != null && !userList.isEmpty())
                	owner = userList[0].id;
                system.debug('userList::'+userList);
            }
            
            system.debug('Inside assignCAWithoutAppointment method::');
            Lead lead = getLead(lId);
            lead.OwnerId = owner;
            lead.status = 'Allocation Done';
            if(dealerId != null || dealerId != ''){ // Added by Sankalp
                lead.Dealer__c = dealerId;
            }
            update lead;
            return 'Success';
            /*ScheduleAppointmentServices.SuccessWrapper sw = new ScheduleAppointmentServices.SuccessWrapper('Success',owner,null,null);
        	return sw;*/
        }Catch(Exception ex){
            system.debug('Fail:: '+ex.getMessage());
            /*ScheduleAppointmentServices.SuccessWrapper sw = new ScheduleAppointmentServices.SuccessWrapper('Fail',null,null,null);
        	return sw;*/
            return 'Fail';
        }
    }
    
    @AuraEnabled(cacheable=true)
    Public static List<event> isCalendarBlocked(string lId){
        List<Event> eventList = new List<Event>();
		eventList = [select id,whoId,subject,StartDateTime,owner.firstName,owner.lastName,EndDateTime,owner.Name,ownerId from event where whoId =: lId and 
                                 StartDateTime >=Today and type = 'Appointment' order by createdDate DESC];    //Schedule //whoId is leadId
       /* if(eventList.isEmpty()){
            eventList = [select id,whoId,subject,StartDateTime,owner.firstName,owner.lastName,EndDateTime from event where whoId =: lId and 
                                 StartDateTime >=Today and subject = 'Schedule Appointment'];
        } */
        system.Debug('eventList::'+eventList);
        return eventList;
    }
    
    @AuraEnabled
    Public static string deleteAppointment(string eventId,string leadId){
        try{
            Event e = new Event();
            e.Id = eventId;
            delete e;
            system.debug('leadId::'+leadId);
            Lead l = new Lead();
            l.Id = leadId;
            l.Status = 'New';
            l.OwnerId = UserInfo.getUserId();
            l.Last_Appointment_Start_Date_Time__c = null;
            l.Last_Appointment_End_Date_Time__c = null;
            l.Reason_For_SA_Declined__c = null;
            l.SA_Declined__c = false;
            l.Dealer__c = null;
            l.Appointment_Cancelled_On__c = system.now();
            l.Appointment_Rescheduled_On__c = null;
            l.Assigned_To__c = null;
            update l;
            
            return 'Success';
        }catch(Exception ex){
            system.debug('Error in event Deletion::'+ex.getMessage());
            return 'Failed';
        }
        //return null;
    }
    
    
    
    
 //////////////////////////////   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
	
	
	    
  /*  @AuraEnabled(cacheable=true)
    Public static List<User> getSAList(string lId){
       system.debug('inside getSAList method::');
        List<User> uList = [select id,name from user where email like '%stetig%' order by name ASC];
        return uList;
    }
    
    @AuraEnabled(cacheable=true)
    Public static List<User> getSAFromId(string sId){
       system.debug('inside getSAFromId method::'+sId);
        List<User> uList = [select id,name from user where Id=:sId and isActive = true];
        return uList;
    }
    
    @AuraEnabled(cacheable=true)
    Public static List<SA_Pincode_Mapping__c> getSAFromPincode(string pincode){
       system.debug('inside getSAFromPincode method::');
        List<SA_Pincode_Mapping__c > uList = [select id,name,SA__c,SA__r.Name,Pincode__c from SA_Pincode_Mapping__c
                                              where Pincode__C=:pincode];
        return uList;
    }
    
    @AuraEnabled(cacheable=true)
    Public static List<User> getCAFromId(string cId){
       system.debug('inside getSAFromId method::'+cId);
        List<User> uList = [select id,name from user where contactId=:cId and isActive = true];
        return uList;
    }
    
	@AuraEnabled(cacheable=true)
    Public static List<EventWrapper> get_CA_Slots(string cId, string uId, string lId, Date visitDate){
        system.debug('inside Get CA slots:: cId:: '+cId+':: VisitDate:: '+visitDate + ':: uId:'+uId+':: lId:'+lId);
        List<Contact> contactList = [select id,name,Slot_End__c,Slot_Start__c from Contact where Id=:cId];
        string contact_Start_Time = '00';
        string contact_End_Time = '00';
        if(contactList != null && !contactList.isEmpty()){
            if(contactList[0].Slot_Start__c != null){contact_Start_Time = string.valueOf(getSlots_In_24Hrs(contactList[0].Slot_Start__c));}
      		if(contactList[0].Slot_End__c != null){contact_End_Time = string.valueOf(getSlots_In_24Hrs(contactList[0].Slot_End__c));}
        }
        
        List<EventWrapper> available_Slots = new List<EventWrapper>();
        DateTime visit_Dt = visitDate;
        String month_ST = string.valueOf(visit_Dt.month());
        if(month_ST.length() == 1)month_ST = '0' + month_ST;
        
        String day_ST = string.valueOf(visit_Dt.Day());
        if(day_ST.length() == 1)day_ST = '0' + day_ST;
        
       // string startTime_Of_Visit_Date = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T'+ contact_Start_Time +':00:00Z';
       // string endTime_Of_Visit_Date = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T'+ contact_End_Time + ':00:00Z';
        string startTime_Of_Visit_Date = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T00:00:00Z';
        string endTime_Of_Visit_Date = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T23:59:59Z';
        
        system.debug('startTime_Of_Visit_Date:: '+startTime_Of_Visit_Date);
        system.debug('endTime_Of_Visit_Date:: '+endTime_Of_Visit_Date);
        string startTimeField = 'StartDateTime';
        string endTimeField = 'EndDateTime';
        
        string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ' +
            string.valueOf(startTimeField) + '>=' + startTime_Of_Visit_Date + ' AND ' + 
            string.valueOf(endTimeField) + '<=' + endTime_Of_Visit_Date + ' AND ' +
            'ownerId = ' + '\'' + uId + '\' AND ' +
            'whoId = ' + '\'' + lId + '\'';
        List<Event> eventList = Database.query(query);
        system.debug('eventList:: '+eventList);
        boolean is_Slot_Available = false;
        if(eventList != null && !eventList.isEmpty()){
            for(Event e :eventList){
                if(e.StartDateTime.Hour() >= Integer.valueof(contact_Start_Time) && e.EndDateTime.Hour() <= Integer.valueof(contact_End_Time)){
                    is_Slot_Available = false;
                }else{
                    is_Slot_Available = true;
                }
            }
            
        }else{
            is_Slot_Available = true;
        }
        
        if(is_Slot_Available){    
            EventWrapper eWrapper = new EventWrapper();
            Event e = new Event();
            e.whoId = lId;
            e.OwnerId = uId;
            dateTime starting_Event_Time = Datetime.newInstance(visit_Dt.year(),
                                           Integer.valueOf(month_ST),
                                           Integer.valueOf(day_ST),
                                           Integer.valueOf(contact_Start_Time),
                                           00,
                                           00);
            dateTime end_Event_Time = Datetime.newInstance(visit_Dt.year(),
                                      Integer.valueOf(month_ST),
                                      Integer.valueOf(day_ST),
                                      Integer.valueOf(contact_End_Time),
                                      00,
                                      00);
            e.StartDateTime = starting_Event_Time;
            e.EndDateTime = end_Event_Time;
            e.Subject = 'CA Appointment';
            eWrapper.event = e;
            eWrapper.slot = getSlots_In_12Hrs(Integer.valueof(contact_Start_Time)) + ' - ' + getSlots_In_12Hrs(Integer.valueof(contact_End_Time));
            available_Slots.add(eWrapper);
            system.debug('inside CA Slot::'+available_Slots);
            
    	}
        return available_Slots;
    }    
    @AuraEnabled(cacheable=true)
    Public static List<EventWrapper> getAvailableSlots(string lId, string uId, Date visitDate){
        system.debug('lId: '+lId + ' ::: uId: '+ uId +'::: visitDate:'+visitDate);
        List<EventWrapper> available_Slots = new List<EventWrapper>();
        DateTime visit_Dt = visitDate;
        String month_ST = string.valueOf(visit_Dt.month());
        if(month_ST.length() == 1)month_ST = '0' + month_ST;
        
        String day_ST = string.valueOf(visit_Dt.Day());
        if(day_ST.length() == 1)day_ST = '0' + day_ST;
        
        string startTime_Of_Visit_Date = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T00:00:00Z';
        string endTime_Of_Visit_Date = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T23:59:59Z';
        
        system.debug('month_ST:: '+month_ST);
        system.debug('day_ST:: '+day_ST);
        string startTimeField = 'StartDateTime';
        string endTimeField = 'EndDateTime';
        
        string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ' +
            string.valueOf(startTimeField) + '>=' + startTime_Of_Visit_Date + ' AND ' + 
            string.valueOf(endTimeField) + '<=' + endTime_Of_Visit_Date + ' AND ' +
            'ownerId = ' + '\'' + uId + '\' AND ' + 
            'whoId = ' + '\'' + lId + '\'';
        List<Event> eventList = Database.query(query);
        system.debug('eventList:: '+eventList);
        
        Map<String,SA_Calendar_Slots__c> slotMapFromSetting = SA_Calendar_Slots__c.getAll();/// Get slots details from Custom setting
        Map<Integer,Integer> slotMap = new Map<Integer,Integer>();
        for(string key : slotMapFromSetting.keyset()){
            if(!slotMapFromSetting.get(key).Is_Lunch_Time__c){
                slotMap.put(Integer.valueOf(slotMapFromSetting.get(key).Start_Time__c),Integer.valueOf(slotMapFromSetting.get(key).End_Time__c));
            }
        }
        Map<Integer,Integer> allotted_slotMap = new Map<Integer,Integer>();
            Map<Integer,Integer> available_slotMap = new Map<Integer,Integer>();
            if(eventList != null && !eventList.isEmpty()){
                for(Event e : eventList){
                    if(e.StartDateTime != null && e.EndDateTime != null){
               ////////// If the all the event
                        if(e.IsAllDayEvent){
                            allotted_slotMap.putAll(slotMap);
                        }
              ///////// If the event is greater than 1 hr          
                        Integer start_Hour = e.StartDateTime.hour();
                        Integer end_hour = e.EndDateTime.hour();
                        if(end_hour - start_Hour > 1){
                            allotted_slotMap.put(start_Hour,end_hour);
                            allotted_slotMap.put(start_Hour + 1,end_hour);
                        }else{
                        	allotted_slotMap.put(e.StartDateTime.hour(),e.EndDateTime.hour());
                        }
                    }
                }
            }
         /////// If the there are existing slots allotted then adding the available slots   
            if(!allotted_slotMap.isEmpty()){ 
                for(Integer slt : slotMap.keyset()){
                    if(allotted_slotMap.containskey(slt)){
                        /// allotted slots
                    }else{
                        ////// available slots
                        available_slotMap.put(slt,slotMap.get(slt));
                    }
                }
            }else{  
                /////////// If the there is no existing slot allotted then adding whole day slots
                available_slotMap.putAll(slotMap);
            }
            
        /////////// adding event 
            if(!available_slotMap.isEmpty()){
                for(Integer key : available_slotMap.keyset()){
                    EventWrapper eWrapper = new EventWrapper();
                    Event e = new Event();
                    e.whoId = lId;
                    e.OwnerId = uId;
                    dateTime starting_Event_Time = Datetime.newInstance(visit_Dt.year(),
                                        Integer.valueOf(month_ST),
                                        Integer.valueOf(day_ST),
                                        key,
                                        00,
                                        00);
                    dateTime end_Event_Time = Datetime.newInstance(visit_Dt.year(),
                                        Integer.valueOf(month_ST),
                                        Integer.valueOf(day_ST),
                                        available_slotMap.get(key),
                                        00,
                                        00);
                    //string starting_Event_Time = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T' + key + ':00:00Z';
                    //string end_Event_Time = visit_Dt.year() + '-' + month_ST + '-' + day_ST + 'T' + available_slotMap.get(key) + ':00:00Z';
                    e.StartDateTime = starting_Event_Time;//DateTime.ValueOf(JSON.deserialize(starting_Event_Time, DateTime.class));      //DateTime.valueOf(starting_Event_Time);
                    e.EndDateTime = end_Event_Time;//DateTime.ValueOf(JSON.deserialize(end_Event_Time, DateTime.class));              ///DateTime.valueOf(end_Event_Time);
                    e.Subject = 'SA Appointment';
                    //available_Slots.add(e);
                    eWrapper.event = e;
                    eWrapper.slot = getSlots_In_12Hrs(key) + ' - ' + getSlots_In_12Hrs(available_slotMap.get(key));
                    available_Slots.add(eWrapper);
                    system.debug('starting_Event_Time::'+starting_Event_Time);
                    system.debug('end_Event_Time::'+end_Event_Time);
                }
            }
        system.debug('available_Slots:: '+available_Slots);
        return available_Slots;
    }
    
    public static String getSlots_In_12Hrs(Integer i){
        if(i==10){
            return '10AM';
        }else if(i==11){return '11 AM';}
        else if(i==12){return '12 PM';}
        else if(i==13){return '01 PM';}
        else if(i==14){return '02 PM';}
        else if(i==15){return '03 PM';}
        else if(i==16){return '04 PM';}
        else if(i==17){return '05 PM';}
        else if(i==18){return '06 PM';}
        else if(i==19){return '07 PM';}
        return null;
    }
    
    public static Integer getSlots_In_24Hrs(string i){
        if(i=='10 AM'){
            return 10;
        }else if(i=='11 AM'){return 11;}
        else if(i=='12 PM'){return 12;}
        else if(i=='01 PM'){return 13;}
        else if(i=='02 PM'){return 14;}
        else if(i=='03 PM'){return 15;}
        else if(i=='04 PM'){return 16;}
        else if(i=='05 PM'){return 17;}
        else if(i=='06 PM'){return 18;}
        else if(i=='07 PM'){return 19;}
        return null;
    }
    
    @AuraEnabled
    public static String saveEvent(string eventRecord,string slotList){
        system.debug('eventRecord:: '+eventRecord);
        system.debug('slotList:: '+slotList);
        List<EventWrapper> eventSlotList = (List<EventWrapper>)JSON.deserialize(slotList, List<EventWrapper>.class);
        system.debug('eventSlotList:::'+eventSlotList);
        Map<string,event> eventMap = new Map<string,event>();
        for(EventWrapper ew : eventSlotList){
			eventMap.put(ew.slot,ew.event);            
        }
        try{
            insert eventMap.get(eventRecord);
            //system.debug('Id:: '+eventMap.get(eventRecord).id);
            return 'Success';
        }catch(Exception e){
            system.debug('Event Insertion Failed:: '+e.getMessage());
            return 'Failed';
        }
    }
    public class c_Request{        
        @InvocableVariable
        public string userId;
        @InvocableVariable
        public DateTime visit_Date;
        @InvocableVariable
        public string leadId;
    }  
    
    public class c_Response{
        @InvocableVariable
        public Event slots_List;
    }
    
    public class EventWrapper{
        @AuraEnabled public string slot;
        @AuraEnabled public Event event;
    }*/
}