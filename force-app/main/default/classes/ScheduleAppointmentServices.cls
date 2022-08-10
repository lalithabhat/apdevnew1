public class ScheduleAppointmentServices {
    Public static Lead getLead(string lId){
        system.debug('lId::'+lId);
        Lead l = new Lead();
        List<Lead> lList = [select id,name,Service_By__c,SA_Name__c,Multiple_SA__c,CA_Name__c,SA_Declined__c,Skills__c,
                            Declined_Reason__c,Pincode__c,CA_Name__r.Name,recordtypeId,OwnerId,Reason_For_SA_Declined__c, 
                            recordtype.name,status, Last_Appointment_End_Date_Time__c,Street,City,State,Country,PostalCode,
                            Last_Appointment_Start_Date_Time__c,Service_Territory__c,mobilePhone,Bot_Journey__c,
                            Service_Territory__r.Business_Hour_End__c, Service_Territory__r.Business_Hour_start__c,
                             YM_Campaign_Code__c,BP_No__c,Email,Whatsapp_Notification__c,description,Complete_Home_Interiors__c,
                            Bedroom_Interior_Design__c,Living_Room_Interior_Design__c,Complete_Modular_Kitchen__c,
                             At_Home_Consultation__c,Online_Consultation__c,Assign_without_Appointment__c,Assign_Without_Appointment_Datetime__c 
                            from lead where id=:lId and isConverted = false];
        system.debug('llist:: '+lList);
        if(lList != null && !lList.isEmpty())
            l = lList[0];
        return l;
    }
    
    public static List<Contact> getContactDetails(string cId){
        List<Contact> cList = [select id,name,Slot_End__c,Slot_Start__c, End_Slot__c, Start_Slot__c,mobilePhone from Contact where Id=:cID];
        return cList;
    }
    
    Public static List<SA_Pincode_Mapping__c> getUsers_For_SPS(string pincode, string bu, Integer priority){
       system.debug('inside getUsers_For_SPS method::');
        List<SA_Pincode_Mapping__c > uList = new List<SA_Pincode_Mapping__c >();
        Map<Id,SA_Pincode_Mapping__c> userMap = new Map<Id,SA_Pincode_Mapping__c>(); 
        if(priority != null){
             uList = [select id,name,SA__c,SA__r.Name,SA__r.AccountId,Pincode__c,Service__c/*BU__c*/,Role__c,Priority__c,
                                              SA__r.mobilePhone
                                              from SA_Pincode_Mapping__c
                                              where Pincode__C=:pincode and Service__c =: bu and Role__c = 'SA'and SA__r.Active__c =true
                                              and Priority__c =: priority 
                                              order by Priority__c ASC];
        }
        if(uList.isEmpty()){
             uList = [select id,name,SA__c,SA__r.Name,SA__r.AccountId,Pincode__c,Service__c/*BU__c*/,Role__c,Priority__c,
                                              SA__r.mobilePhone
                                              from SA_Pincode_Mapping__c
                                              where Pincode__C=:pincode and Service__c =: bu and Role__c = 'SA' and SA__r.Active__c =true
                                              order by Priority__c ASC]; //
        }
       for(SA_Pincode_Mapping__c s : uList){
            userMap.put(s.SA__c, s);
        }
        return userMap.values(); 
       // return uList;
    }
    
    Public static List<SA_Pincode_Mapping__c> getUsers_For_BHS(string pincode, string bu, Integer priority){
       system.debug('inside getUsers_For_BHS method::');
        List<SA_Pincode_Mapping__c > uList = new List<SA_Pincode_Mapping__c >();
         Map<Id,SA_Pincode_Mapping__c> userMap = new Map<Id,SA_Pincode_Mapping__c>(); 
       
        if(priority != null){
            uList = [select id,name,SA__c,SA__r.Name,Pincode__c,Service__c/*BU__c*/,Role__c, Priority__c,
                                              SA__r.mobilePhone
                                              from SA_Pincode_Mapping__c
                                              where Pincode__C=:pincode and Service__c =: bu and
                     						  Priority__c =: priority AND SA__r.Active__c =true
                     						  order by Priority__c ASC]; //
        }
        if(uList.isEmpty()){
            uList = [select id,name,SA__c,SA__r.Name,Pincode__c,Service__c/*BU__c*/,Role__c, Priority__c,
                     SA__r.mobilePhone
                     from SA_Pincode_Mapping__c
                     where Pincode__C=:pincode and Service__c =: bu and SA__r.Active__c =true order by Priority__c ASC]; //
        }
        
        for(SA_Pincode_Mapping__c s : uList){
            userMap.put(s.SA__c, s);
        }
        return userMap.values(); 
        //return uList;
    }
    
    Public static List<User> getUser_From_Id(string sId){
       system.debug('inside getSAFromId method::'+sId);
        List<User> uList = [select id,name,contactId from user where Id=:sId and isActive = true];
        return uList;
    }
    
    /*Public static List<SA_Pincode_Mapping__c> getSAFromPincode(string pincode){
       system.debug('inside getSAFromPincode method::');
        List<SA_Pincode_Mapping__c > uList = [select id,name,SA__c,SA__r.Name,Pincode__c from SA_Pincode_Mapping__c
                                              where Pincode__C=:pincode]; //
        return uList;
    }*/

    /* 
    Public static List<User> getCAFromId(string cId){
       system.debug('inside getSAFromId method::'+cId);
        List<User> uList = [select id,name,mobilePhone from user where contactId=:cId and isActive = true];
        return uList;
    }
   */
    
    
        Public static List<User> getCAFromId(string cId){
       system.debug('inside getSAFromId method::'+cId);

contact ContDetails=[SELECT Id, Name, PositionID__c, Employee_Code__c FROM Contact where id=:cId];

        List<User> uList = [SELECT Id, Name, PositionID__c, Employee_Number__c,mobilePhone FROM User
							where PositionID__c=:ContDetails.PositionID__c 
							and Employee_Number__c=:ContDetails.Employee_Code__c
							and isActive = true];
        return uList;
    }
   
    
    
    
    
    
    public static Decimal getSlotDuration(string BU, string skills){
        if(string.isNotBlank(BU) && string.isNotBlank(skills)){
            Set<String> skillSet = new Set<String>();
            skillSet.addAll(skills.split(';'));
            List<Service_Master__c > sm = [select id,name,Service__c, Skills__c, Slot_Duration_in_Hours__c 
                                           from Service_Master__c where Service__c =: BU and Skills__c IN:skillSet LIMIT 1];
            if(sm != null && !sm.isEmpty()){
                if(sm[0].Slot_Duration_in_Hours__c != null){
                    return sm[0].Slot_Duration_in_Hours__c;
                }
            }
        }
        return null;
    }
  /*  public static List<SlotWrapper> GetSlotsForSelfServe(List<string> userList, List<Date> dateList, Integer no_of_Days){
        
        string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ' +
                        'ownerId IN: userList and and EndDateTime <= NEXT_N_DAYS:' + no_of_Days + ' and ' + 
                        'StartDateTime >= TODAY';
        List<Event> eventList = Database.query(query);
        Map<string,list<event>> user_booked_slots = new map<string,list<event>>();
        if(eventList != null && !eventList.isEmpty()){
            for(event e : eventList){
                if(user_booked_slots.containsKey(e.ownerId)){
                    List<event> existingEvents = user_booked_slots.get(e.ownerId);
                    existingEvents.add(e);
                    user_booked_slots.put(e.ownerId,existingEvents);
                }else{
                    List<event> existingEvents = new List<event>();
                    existingEvents.add(e);
                    user_booked_slots.put(e.ownerId,existingEvents);
                }
            }
        }
        Map<String,SA_Calendar_Slots__c> slotMapFromSetting = SA_Calendar_Slots__c.getAll();
        Map<String,String> slotMap = new Map<string,string>();
        for(string key : slotMapFromSetting.keyset()){
            if(!slotMapFromSetting.get(key).Is_Lunch_Time__c){
                slotMap.put(slotMapFromSetting.get(key).Slot_Start__c , slotMapFromSetting.get(key).Slot_End__c);
            }
        }
        system.debug('slotMap:: '+slotMap.keyset());
        if(!user_booked_slots.isEmpty()){
            for(string key : user_booked_slots.keyset()){
                for(event e : user_booked_slots.get(key)){
                    
                }
            }
        }else{
            List<SlotWrapper> availableSlot = new List<SlotWrapper>();
            
        }
        return null;
    } */
    
    Public static CADetailsWrapper getCA(Lead lead, CADetailsWrapper existingCADetails){
        system.debug('inside scheduleAppointmentServices.getCA method:: '+lead);
        Set<String> skillSet = new Set<String>();
        if(lead.Skills__c != null){
            skillSet.addAll(lead.Skills__c.split(';'));
        }
        Map<Id, DealerManagementServices.CADetailWrapper> existingCAWrapper = new Map<Id, DealerManagementServices.CADetailWrapper>();
        if(existingCADetails != null){
            DealerManagementServices.CADetailWrapper cw = new DealerManagementServices.CADetailWrapper(existingCADetails.CA,existingCADetails.dealer,null);
            existingCAWrapper.put(existingCADetails.CA.Id, cw);           
        }
        Map<Id, DealerManagementServices.CADetailWrapper> CADetails = DealerManagementServices.getCAInfo(lead.Pincode__c,skillSet,existingCAWrapper); 
        system.debug('CADetails:: '+CADetails);
        if(CADetails != null && !CADetails.isEmpty()){
            CADetailsWrapper cdw = new CADetailsWrapper();
            for(Id key : CADetails.keySet()){
                cdw.CA = CADetails.get(key).CA;
                cdw.dealer = CADetails.get(key).Dealer;
            }
            return cdw;
        }
        return null;
    }
    
    public static List<SlotWrapper> GetSlots_For_LWC_FIRST2(string userId, Date Appointment_date, Integer no_of_Days, string lId, Date toDate){
        List<SlotWrapper> resultList = new List<SlotWrapper>();
        List<User> user = getCAFromId(userId);   
        Lead lead = getLead(lId);
        Decimal slot_Duration = getSlotDuration(lead.RecordType.Name, lead.Skills__c);
        string startTimeField = 'StartDateTime';
        string endTimeField = 'EndDateTime';
        String month_ST = string.valueOf(Appointment_date.month());
            if(month_ST.length() == 1)month_ST = '0' + month_ST;
        
        String day_ST = string.valueOf(Appointment_date.Day());
            if(day_ST.length() == 1)day_ST = '0' + day_ST;
        
        string startTime_Of_Visit_Date = Appointment_date.year() + '-' + month_ST + '-' + day_ST + 'T00:00:00Z';
        system.debug('startTime_Of_Visit_Date::'+startTime_Of_Visit_Date);
        system.debug('user:: '+user[0].Id);
        system.debug('no_of_Days:: '+no_of_Days);
        List<Event> eventList = new List<Event>();
        /*string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ' +
                        string.valueOf(startTimeField) + ' >='+ startTime_Of_Visit_Date + ' and ' +
                        'ownerId = ' + '\'' + user[0].id + '\''; */ /*'EndDateTime <= NEXT_N_DAYS:' + no_of_Days + ' and '+ */
        string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ((' +
                        string.valueOf(startTimeField) + '<' + startTime_Of_Visit_Date + ' and '+ 
                        string.valueOf(endTimeField) + '>' + startTime_Of_Visit_Date + ') OR ' +
                        string.valueOf(startTimeField) + ' >='+ startTime_Of_Visit_Date + ') and ' +
                        'ownerId = ' + '\'' + user[0].id + '\'';
        eventList = Database.query(query);
        system.debug('eventList:::'+eventList);
        
        Map<Time,Time> slotMap = new Map<Time,Time>();
       
        Time start_slot = lead.Service_Territory__r.Business_Hour_start__c;
        Time end_slot = lead.Service_Territory__r.Business_Hour_End__c;
        time dTime = start_slot;
        if(Test.isRunningTest()){
            slot_Duration = 1.00;
        }
        string durationInstring = string.valueOf(slot_Duration);
        durationInstring = durationInstring.substringAfter('.');
        Integer durationMins = Integer.valueOf(durationInstring);
        if(durationMins > 0){
            durationMins = (durationMins * 60)/100;
        }
        Integer init = slot_Duration.intValue();
        boolean isadd = false;
        
        while(!isadd){
            dTime = dTime.addHours(init);
            dTime = dTime.addMinutes(durationMins);
            if(dTime <= end_slot){
                slotMap.put(start_slot,dTime);
                start_slot = dTime;
            }else{
                isadd = true;
            }
        }
                
        system.debug('slotMap::'+slotMap);
        Map<Date,Map<Time,Time>> allotted_Date = new Map<Date,Map<Time,Time>>();
        
        if(eventList != null && !eventList.isEmpty()){
            for(event e : eventList){
                Map<Time,Time> allotted_slotMap = new map<Time,Time>();
                Map<Date,Map<Time,Time>> slotAllotted = new map<Date,Map<Time,Time>>();
                Integer ndays = e.startDatetime.date().daysBetween(e.endDateTime.date());
                if(ndays > 0){
                    //List<Date> dList = new List<Date>();
                    for(Integer i=0;i<=ndays;i++){
                        date d = e.startDatetime.date().addDays(i);
                        Map<Time,Time> timeMap = new Map<Time,Time>();
                        if(d.isSameDay(e.startDatetime.date())){
                            Time myTime = Time.newInstance(23, 59, 59, 0);
                            timeMap.put(e.startDatetime.Time(),myTime);
                            system.debug('inside start::'+timeMap);
                            slotAllotted.put(d,timeMap);
                        }else if(d.isSameDay(e.endDateTime.date())){
                            Time myTime = Time.newInstance(00, 00, 00, 0);
                            timeMap.put(myTime,e.endDateTime.Time());
                            slotAllotted.put(d,timeMap);
                            system.debug('inside end::'+timeMap);
                        }else{
                            slotAllotted.put(d,slotMap);
                        }
                    }
                }else{
                    Map<Time,Time> timeMap = new Map<Time,Time>();
                    timeMap.put(e.StartDateTime.Time(),e.EndDateTime.Time());
                    slotAllotted.put(e.StartDateTime.Date(),timeMap);
                }
                //allotted_slotMap.put(e.StartDateTime.Time(),e.EndDateTime.Time());
                for(Date dt : slotAllotted.keyset()){
                    if(allotted_Date.containskey(dt)){
                        map<Time,Time> dummyMap = new Map<Time,Time>();
                        dummyMap = allotted_Date.get(dt);
                        dummyMap.putAll(slotAllotted.get(dt));
                        allotted_Date.put(dt,dummyMap);
                    }else{
                        allotted_Date.put(dt,slotAllotted.get(dt));
                    }
                }
            }
        }
        system.debug('allotted_Date::'+allotted_Date);
       // List<Date> finalList = new List<Date>();
        Map<Date,Map<Time,Time>> finalMap = new Map<Date,Map<Time,Time>>();
        if(!allotted_Date.isEmpty()){
            for(Integer i=0;i<=no_of_Days;i++){
                date dt = Appointment_date.addDays(i);
                system.debug('dt::'+dt);
                if(allotted_Date.containskey(dt)){
                    //system.debug('is true');
                    Map<Time,Time> dummyMap = new map<Time,Time>();
                    dummyMap = allotted_Date.get(dt);
                    map<Time,Time> temp_slot = new map<Time,Time>();
                   
                    system.debug('dummyMap:: '+dummyMap);
                    Map<Time,time> removeMap = new map<time,time>();
                    Map<Time,time> resultMap = new map<time,time>();
                    Map<Time,time> secondMap = new map<time,time>();
                    secondMap.putAll(slotMap);
                    
                    for(Time key : dummyMap.keyset()){
                        for(time secondKey : slotMap.keyset()){
                            if((key<secondKey && dummyMap.get(key) >= slotMap.get(secondKey)) || ( key>=secondKey && dummyMap.get(key) <= slotMap.get(secondKey))
                                || (key<secondKey && dummyMap.get(key) <= slotMap.get(secondKey) && dummyMap.get(key) > secondKey) || (key>=secondKey && dummyMap.get(key) > slotMap.get(secondKey) && key<slotMap.get(secondKey)) ){
                                system.debug('inside no add:: '+ key +'-'+secondKey);
                                removeMap.put(secondKey,slotMap.get(secondKey));
                            }else{
                                resultMap.put(secondKey,slotMap.get(secondKey));
                            }
                        }
                    }
                    for(Time k:removeMap.keyset()){
                        secondMap.remove(k);
                    }
                    temp_slot.putAll(secondMap);
                    
                    finalMap.put(dt,temp_slot);
                }else{
                    finalMap.put(dt,slotMap);
                }
            }
        }else{
            system.debug('else');
            for(Integer i=0;i<=no_of_Days;i++){
                date dt = Appointment_date.addDays(i);
                finalMap.put(dt,slotMap);
            }
        }       

        if(!finalMap.isEmpty()){
            Integer slot_size = 1;
            for(Date dt : finalMap.keyset()){
                List<string> dummyList = new List<String>();
                for(Time key : finalMap.get(dt).keyset()){
                    system.debug('slot_size::'+slot_size);
                    if(slot_size < 7){
                        boolean isAddTo = true;
                        if(system.today() == dt){
                            if(system.now().Time() > key){
                                isAddTo = false;
                            }
                        }
                        if(isAddTo){
                            system.debug('isadd');
                            string keyMinutes = string.valueOf(key.Minute());
                            string valuMinutes = string.valueOf(finalMap.get(dt).get(key).Minute());
                            if(keyMinutes.length() == 1){
                                keyMinutes = keyMinutes + '0';
                            }
                            if(valuMinutes.length() == 1){
                                valuMinutes = valuMinutes + '0';
                            }
                            string st = getSlots_In_12Hrs(key.hour()).left(2) + ':' + keyMinutes + ' ' + 
                                        getSlots_In_12Hrs(key.hour()).right(2);
                            string en = getSlots_In_12Hrs(finalMap.get(dt).get(key).hour()).left(2) + ':' + 
                                        valuMinutes + ' ' +
                                        getSlots_In_12Hrs(finalMap.get(dt).get(key).hour()).right(2);
                            //sw.slot = st + ' - ' + en;
                            //sw.slotWithDate = dt.format() + ' ' + sw.slot;
                            string st1 = st + ' - ' + en;
                            string st2 = dt.format() + ' ' + st1;
                            dummyList.add(st1);
                            if(toDate != null){
                                
                            }else{
                                slot_size++;
                            }
                            
                        }
                    }
                }
                if(!dummyList.isEmpty()){
                    SlotWrapper sw1 = new SlotWrapper(dt,null,null,dummyList);
                    resultList.add(sw1);
                }
            }
        }
        
        return resultList;   
    }
    
    public static List<SlotWrapper> GetSlots_For_LWC_Second2(string userId, Date Appointment_date, Integer no_of_Days, string lId, Date toDate){
        List<SlotWrapper> resultList = new List<SlotWrapper>();
        
        List<Contact> contactDetails = getContactDetails(userId);
        List<User> user = getCAFromId(userId);
        
        Lead lead = getLead(lId);
        Decimal slot_Duration = getSlotDuration(lead.RecordType.Name, lead.Skills__c);
        
        Map<Time,Time> slotMap = new Map<Time,Time>();
        Time business_Hour_Start = lead.Service_Territory__r.Business_Hour_start__c;
        Time business_Hour_End = lead.Service_Territory__r.Business_Hour_End__c;
        
        Time start_Time;
        Time end_Time;
        if(contactDetails[0].Start_Slot__c >= business_Hour_Start){
            start_Time = contactDetails[0].Start_Slot__c;
        }else if(contactDetails[0].Start_Slot__c < business_Hour_Start){
            start_Time = business_Hour_Start;
        }                
        if(contactDetails[0].End_Slot__c <= business_Hour_End){
            end_Time = contactDetails[0].End_Slot__c;
        }else if(contactDetails[0].End_Slot__c > business_Hour_End){
            end_Time = business_Hour_End;
        }
        
        time dTime = start_Time;
        string durationInstring = string.valueOf(slot_Duration);
        durationInstring = durationInstring.substringAfter('.');
        Integer durationMins = Integer.valueOf(durationInstring);
        if(durationMins > 0){
            durationMins = (durationMins * 60)/100;
        }
        Integer init = slot_Duration.intValue();
        boolean isaddN = false;
        
        while(!isaddN){
            dTime = dTime.addHours(init);
            dTime = dTime.addMinutes(durationMins);
            if(dTime <= end_Time){
                slotMap.put(start_Time,dTime);
                start_Time = dTime;
            }else{
                isaddN = true;
            }
        }
        
        string startTimeField = 'StartDateTime';
        string endTimeField = 'EndDateTime';
        String month_ST = string.valueOf(Appointment_date.month());
            if(month_ST.length() == 1)month_ST = '0' + month_ST;
        
        String day_ST = string.valueOf(Appointment_date.Day());
            if(day_ST.length() == 1)day_ST = '0' + day_ST;
        
        string startTime_Of_Visit_Date = Appointment_date.year() + '-' + month_ST + '-' + day_ST + 'T00:00:00Z';
        
        /*string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ' +
                        string.valueOf(startTimeField) + ' >='+ startTime_Of_Visit_Date + ' and ' +
                        'ownerId = ' + '\'' + user[0].id + '\''; */ /*'EndDateTime <= NEXT_N_DAYS:' + no_of_Days + ' and '+ */
        
        string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ((' +
                        string.valueOf(startTimeField) + '<' + startTime_Of_Visit_Date + ' and '+ 
                        string.valueOf(endTimeField) + '>' + startTime_Of_Visit_Date + ') OR ' +
                        string.valueOf(startTimeField) + ' >='+ startTime_Of_Visit_Date + ') and ' +
                        'ownerId = ' + '\'' + user[0].id + '\'';
        
        List<Event> eventList = Database.query(query);
        
        Map<Date,Map<Time,Time>> allotted_Date = new Map<Date,Map<Time,Time>>();
        if(eventList != null && !eventList.isEmpty()){
            for(event e : eventList){
                Map<Time,Time> allotted_slotMap = new map<Time,Time>();
                Map<Date,Map<Time,Time>> slotAllotted = new map<Date,Map<Time,Time>>();
                Integer ndays = e.startDatetime.date().daysBetween(e.endDateTime.date());
                if(ndays > 0){
                    //List<Date> dList = new List<Date>();
                    for(Integer i=0;i<=ndays;i++){
                        date d = e.startDatetime.date().addDays(i);
                        Map<Time,Time> timeMap = new Map<Time,Time>();
                        if(d.isSameDay(e.startDatetime.date())){
                            Time myTime = Time.newInstance(23, 59, 59, 0);
                            timeMap.put(e.startDatetime.Time(),myTime);
                            system.debug('inside start::'+timeMap);
                            slotAllotted.put(d,timeMap);
                        }else if(d.isSameDay(e.endDateTime.date())){
                            Time myTime = Time.newInstance(00, 00, 00, 0);
                            timeMap.put(myTime,e.endDateTime.Time());
                            slotAllotted.put(d,timeMap);
                            system.debug('inside end::'+timeMap);
                        }else{
                            slotAllotted.put(d,slotMap);
                        }
                    }
                }else{
                    Map<Time,Time> timeMap = new Map<Time,Time>();
                    timeMap.put(e.StartDateTime.Time(),e.EndDateTime.Time());
                    slotAllotted.put(e.StartDateTime.Date(),timeMap);
                }
                for(Date dt : slotAllotted.keyset()){
                    if(allotted_Date.containskey(dt)){
                        map<Time,Time> dummyMap = new Map<Time,Time>();
                        dummyMap = allotted_Date.get(dt);
                        dummyMap.putAll(slotAllotted.get(dt));
                        allotted_Date.put(dt,dummyMap);
                    }else{
                        allotted_Date.put(dt,slotAllotted.get(dt));
                    }
                }
            }
        }
      
        
       /* if(eventList != null && !eventList.isEmpty()){
            for(event e : eventList){
                Map<Time,Time> allotted_slotMap = new map<Time,Time>();
                
                allotted_slotMap.put(e.StartDateTime.Time(),e.EndDateTime.Time());
                
                if(allotted_Date.containskey(e.StartDateTime.Date())){
                    map<Time,Time> dummyMap = new Map<Time,Time>();
                    dummyMap = allotted_Date.get(e.StartDateTime.Date());
                    dummyMap.putAll(allotted_slotMap);
                    allotted_Date.put(e.StartDateTime.Date(),dummyMap);
                    
                }else{
                    allotted_Date.put(e.StartDateTime.Date(),allotted_slotMap);
                }
            }
        }*/
        
        
        
        system.debug('allotted_Date::'+allotted_Date);
       // List<Date> finalList = new List<Date>();
        Map<Date,Map<Time,Time>> finalMap = new Map<Date,Map<Time,Time>>();
        if(!allotted_Date.isEmpty()){
            for(Integer i=0;i<=no_of_Days;i++){
                date dt = Appointment_date.addDays(i);
                system.debug('dt::'+dt);
                if(allotted_Date.containskey(dt)){
                    //system.debug('is true');
                    Map<Time,Time> dummyMap = new map<Time,Time>();
                    dummyMap = allotted_Date.get(dt);
                    map<Time,Time> temp_slot = new map<Time,Time>();
                   
                    system.debug('dummyMap:: '+dummyMap);
                    Map<Time,time> removeMap = new map<time,time>();
                    Map<Time,time> resultMap = new map<time,time>();
                    Map<Time,time> secondMap = new map<time,time>();
                    secondMap.putAll(slotMap);
                    
                    for(Time key : dummyMap.keyset()){
                        for(time secondKey : slotMap.keyset()){
                            if((key<secondKey && dummyMap.get(key) >= slotMap.get(secondKey)) || ( key>=secondKey && dummyMap.get(key) <= slotMap.get(secondKey))
                                || (key<secondKey && dummyMap.get(key) <= slotMap.get(secondKey) && dummyMap.get(key) > secondKey) || (key>=secondKey && dummyMap.get(key) > slotMap.get(secondKey) && key<slotMap.get(secondKey)) ){
                                system.debug('inside no add:: '+ key +'-'+secondKey);
                                removeMap.put(secondKey,slotMap.get(secondKey));
                            }else{
                                resultMap.put(secondKey,slotMap.get(secondKey));
                            }
                        }
                    }
                    for(Time k:removeMap.keyset()){
                        secondMap.remove(k);
                    }
                    temp_slot.putAll(secondMap);
                    
                    finalMap.put(dt,temp_slot);
                }else{
                    finalMap.put(dt,slotMap);
                }
            }
        }else{
            for(Integer i=0;i<=no_of_Days;i++){
                date dt = Appointment_date.addDays(i);
                finalMap.put(dt,slotMap);
            }
        }
                
        if(!finalMap.isEmpty()){
            Integer slot_size = 1;
            for(Date dt : finalMap.keyset()){
                List<string> dummyList = new List<String>();
                for(Time key : finalMap.get(dt).keyset()){
                    system.debug('slot_size::'+slot_size);
                    if(slot_size < 7){
                        boolean isAddTo = true;
                        if(system.today() == dt){
                            if(system.now().Time() > key){
                                isAddTo = false;
                            }
                        }
                        if(isAddTo){
                            system.debug('isadd');
                            string keyMinutes = string.valueOf(key.Minute());
                            string valuMinutes = string.valueOf(finalMap.get(dt).get(key).Minute());
                            if(keyMinutes.length() == 1){
                                keyMinutes = keyMinutes + '0';
                            }
                            if(valuMinutes.length() == 1){
                                valuMinutes = valuMinutes + '0';
                            }
                            string st = getSlots_In_12Hrs(key.hour()).left(2) + ':' + keyMinutes + ' ' + 
                                        getSlots_In_12Hrs(key.hour()).right(2);
                            string en = getSlots_In_12Hrs(finalMap.get(dt).get(key).hour()).left(2) + ':' + 
                                        valuMinutes + ' ' +
                                        getSlots_In_12Hrs(finalMap.get(dt).get(key).hour()).right(2);
                            //sw.slot = st + ' - ' + en;
                            //sw.slotWithDate = dt.format() + ' ' + sw.slot;
                            string st1 = st + ' - ' + en;
                            string st2 = dt.format() + ' ' + st1;
                            dummyList.add(st1);
                            if(toDate != null){
                                
                            }else{
                                slot_size++;
                            }
                        }
                    }
                }
                if(!dummyList.isEmpty()){
                    SlotWrapper sw1 = new SlotWrapper(dt,null,null,dummyList);
                    resultList.add(sw1);
                }
            }
        }
        
        
        /*Map<Date,Date> alloted_Date = new Map<Date,Date>();
        if(eventList != null && !eventList.isEmpty()){
            for(event e : eventList){
                if(e.StartDateTime.Time() >= start_Time && e.EndDateTime.Time() <= end_Time)
                {
                    alloted_Date.put(e.StartDateTime.Date(),e.EndDateTime.Date());
                }
            }
        }
        List<Date> available_Date = new List<Date>();
        if(!alloted_Date.isEmpty()){
            for(Integer i=0;i<=no_of_Days;i++){
                Date dt = Appointment_date.addDays(i);
                if(alloted_Date.containskey(dt)){
                    
                }else{
                    boolean isAdd = true;
                    if(system.today() == dt){
                        if(start_Time < system.now().Time()){
                            isAdd = false;
                        }
                    }
                    if(isAdd){
                        available_Date.add(dt);
                    }
                }
            }
        }else{
            for(Integer i=0;i<=no_of_Days;i++){
                Date dt = Appointment_date.addDays(i);
                boolean isAdd = true;
                if(system.today() == dt){
                    if(start_Time < system.now().Time()){
                        isAdd = false;
                    }
                }
                if(isAdd){
                    available_Date.add(dt);
                }
            }
        }
        
        if(!available_Date.isEmpty()){
            for(Date dt : available_Date){
                List<string> dummyList = new List<String>();
                
                string keyMinutes = string.valueOf(start_Time.Minute());
                string valuMinutes = string.valueOf(end_Time.minute());
                if(keyMinutes.length() == 1){
                    keyMinutes = keyMinutes + '0';
                }
                if(valuMinutes.length() == 1){
                    valuMinutes = valuMinutes + '0';
                }
                string st = getSlots_In_12Hrs(start_Time.hour()).left(2) + ':' + keyMinutes + ' ' + 
                    getSlots_In_12Hrs(start_Time.hour()).right(2);
                string en = getSlots_In_12Hrs(end_Time.hour()).left(2) + ':' + 
                    valuMinutes + ' ' +
                    getSlots_In_12Hrs(end_Time.hour()).right(2);
                
                
                string st1 = st + ' - ' + en;
                string st2 = dt.format() + ' ' + st1;
                dummyList.add(st1);
                SlotWrapper sw1 = new SlotWrapper(dt,null,null,dummyList);
                resultList.add(sw1);
            }
        }*/
        
        return resultList;    
    }
    
  /*  public static List<SlotWrapper> GetSlots_For_LWC_FIRST(string userId, Date Appointment_date, Integer no_of_Days){
        List<SlotWrapper> resultList = new List<SlotWrapper>();
        List<User> user = getCAFromId(userId);        
        string startTimeField = 'StartDateTime';
        String month_ST = string.valueOf(Appointment_date.month());
            if(month_ST.length() == 1)month_ST = '0' + month_ST;
        
        String day_ST = string.valueOf(Appointment_date.Day());
            if(day_ST.length() == 1)day_ST = '0' + day_ST;
        
        string startTime_Of_Visit_Date = Appointment_date.year() + '-' + month_ST + '-' + day_ST + 'T00:00:00Z';
        
        string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ' +
                        'EndDateTime <= NEXT_N_DAYS:' + no_of_Days + ' and '+ 
                        string.valueOf(startTimeField) + ' >='+ startTime_Of_Visit_Date + ' and ' +
                        'ownerId = ' + '\'' + user[0].id + '\'';
        List<Event> eventList = Database.query(query);
        
        Map<String,SA_Calendar_Slots__c> slotMapFromSetting = SA_Calendar_Slots__c.getAll();
        Map<Integer,Integer> slotMap = new Map<Integer,Integer>();
        for(string st : slotMapFromSetting.keyset()){
            Integer start_slot = getSlots_In_24Hrs(slotMapFromSetting.get(st).Slot_Start__c);
            Integer end_slot = getSlots_In_24Hrs(slotMapFromSetting.get(st).Slot_End__c);
            slotMap.put(start_slot,end_slot);
        }
        system.debug('slotMap::'+slotMap);
        Map<Date,Map<Integer,Integer>> allotted_Date = new Map<Date,Map<Integer,Integer>>();
        
        if(eventList != null && !eventList.isEmpty()){
            for(event e : eventList){
                Map<Integer,Integer> allotted_slotMap = new map<Integer,Integer>();
                Integer start_Hour = e.StartDateTime.hour();
                Integer end_hour = e.EndDateTime.hour();
                if(end_hour - start_Hour > 1){
                    allotted_slotMap.put(start_Hour,end_hour);
                    allotted_slotMap.put(start_Hour + 1,end_hour);
                }else{
                    allotted_slotMap.put(e.StartDateTime.hour(),e.EndDateTime.hour());
                }
                if(allotted_Date.containskey(e.StartDateTime.Date())){
                    map<Integer,Integer> dummyMap = new Map<Integer,Integer>();
                    dummyMap = allotted_Date.get(e.StartDateTime.Date());
                    dummyMap.putAll(allotted_slotMap);
                    allotted_Date.put(e.StartDateTime.Date(),dummyMap);
                    
                }else{
                    allotted_Date.put(e.StartDateTime.Date(),allotted_slotMap);
                }
            }
        }
        system.debug('allotted_Date::'+allotted_Date);
       // List<Date> finalList = new List<Date>();
        Map<Date,Map<Integer,Integer>> finalMap = new Map<Date,Map<Integer,Integer>>();
        if(!allotted_Date.isEmpty()){
            for(Integer i=0;i<=no_of_Days;i++){
                date dt = Appointment_date.addDays(i);
                if(allotted_Date.containskey(dt)){
                    Map<Integer,Integer> dummyMap = new map<Integer,Integer>();
                    dummyMap = allotted_Date.get(dt);
                    map<Integer,Integer> temp_slot = new map<Integer,Integer>();
                    for(Integer key : slotMap.keyset()){
                        if(dummyMap.containskey(key)){
                            
                        }else{
                            temp_slot.put(key,slotMap.get(key));
                        }
                    }
                    finalMap.put(dt,temp_slot);
                }else{
                   // finalList.add(dt);
                    finalMap.put(dt,slotMap);
                }
            }
        }else{
            for(Integer i=0;i<=no_of_Days;i++){
                date dt = Appointment_date.addDays(i);
                //finalList.add(dt);
                finalMap.put(dt,slotMap);
            }
        }
        
       /* Integer slot_size_new = 1;
        if(!finalList.isEmpty()){
            for(date dt : finalList){
                List<string> dummyList = new List<String>();
                for(integer key : slotMap.keyset()){
                    if(slot_size_new < 7){
                        boolean isAdd = true;
                        if(system.today() == dt){
                            if(system.now().Hour() > key){
                                isAdd = false;
                            }
                        }
                        if(isAdd){
                            string st = getSlots_In_12Hrs(key);
                            string en = getSlots_In_12Hrs(slotMap.get(key));
                           // sw.slot = st + ' - ' + en;
                            //sw.slotWithDate = dt.format() + ' ' + sw.slot;
                            string st1 = st + ' - ' + en;
                            string st2 = dt.format() + ' ' + st1;
                            dummyList.add(st1);
                            slot_size_new++;
                        }
                    }
                }
                if(!dummyList.isEmpty()){
                    SlotWrapper sw1 = new SlotWrapper(dt,null,null,dummyList);
                    resultList.add(sw1);
                }
            }
        }*/
        
   /*     if(!finalMap.isEmpty()){
            Integer slot_size = 1;
            for(Date dt : finalMap.keyset()){
                List<string> dummyList = new List<String>();
                for(Integer key : finalMap.get(dt).keyset()){
                    system.debug('slot_size::'+slot_size);
                    if(slot_size < 7){
                        boolean isAdd = true;
                        if(system.today() == dt){
                            if(system.now().Hour() > key){
                                isAdd = false;
                            }
                        }
                        if(isAdd){
                            system.debug('isadd');
                            string st = getSlots_In_12Hrs(key);
                            string en = getSlots_In_12Hrs(finalMap.get(dt).get(key));
                            //sw.slot = st + ' - ' + en;
                            //sw.slotWithDate = dt.format() + ' ' + sw.slot;
                            string st1 = st + ' - ' + en;
                            string st2 = dt.format() + ' ' + st1;
                            dummyList.add(st1);
                            slot_size++;
                        }
                    }
                }
                if(!dummyList.isEmpty()){
                    SlotWrapper sw1 = new SlotWrapper(dt,null,null,dummyList);
                    resultList.add(sw1);
                }
            }
        }
        /*if(!finalList.isEmpty()){
            for(date dt : finalList){
                for(integer key : slotMap.keyset()){
                    //SlotWrapper sw = new SlotWrapper();
                    //sw.scheduleDate = dt;
                    string st = getSlots_In_12Hrs(key);
                    string en = getSlots_In_12Hrs(slotMap.get(key));
                   // sw.slot = st + ' - ' + en;
                    //sw.slotWithDate = dt.format() + ' ' + sw.slot;
                    string st1 = st + ' - ' + en;
                    string st2 = dt.format() + ' ' + st1;
                    SlotWrapper sw1 = new SlotWrapper(dt,st1,st2);
                    resultList.add(sw1);    
                }
            }
        }
        
        if(!finalMap.isEmpty()){
            for(Date dt : finalMap.keyset()){
                for(Integer key : finalMap.get(dt).keyset()){
                   // SlotWrapper sw = new SlotWrapper();
                    //sw.scheduleDate = dt;
                    string st = getSlots_In_12Hrs(key);
                    string en = getSlots_In_12Hrs(finalMap.get(dt).get(key));
                    //sw.slot = st + ' - ' + en;
                    //sw.slotWithDate = dt.format() + ' ' + sw.slot;
                    string st1 = st + ' - ' + en;
                    string st2 = dt.format() + ' ' + st1;
                    SlotWrapper sw1 = new SlotWrapper(dt,st1,st2);
                    resultList.add(sw1);
                }
            }
        }
        return resultList;   
    }*/
    
   /* public static List<SlotWrapper> GetSlots_For_LWC(string userId, Date Appointment_date, Integer no_of_Days){
        List<SlotWrapper> resultList = new List<SlotWrapper>();
        List<User> user = getUser_From_Id(userId);        
        string startTimeField = 'StartDateTime';
        String month_ST = string.valueOf(Appointment_date.month());
            if(month_ST.length() == 1)month_ST = '0' + month_ST;
        
        String day_ST = string.valueOf(Appointment_date.Day());
            if(day_ST.length() == 1)day_ST = '0' + day_ST;
        
        string startTime_Of_Visit_Date = Appointment_date.year() + '-' + month_ST + '-' + day_ST + 'T00:00:00Z';
        
        string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ' +
                        'EndDateTime <= NEXT_N_DAYS:' + no_of_Days + ' and '+ 
                        string.valueOf(startTimeField) + ' >='+ startTime_Of_Visit_Date + ' and ' +
                        'ownerId = ' + '\'' + user[0].id + '\'';
        
        List<Event> eventList = Database.query(query);
        Map<Datetime,DateTime> user_booked_slots = new map<DateTime,DateTime>();
        if(eventList != null && !eventList.isEmpty()){
            for(event e : eventList){
                Integer start_Hour = e.StartDateTime.hour();
                Integer end_hour = e.EndDateTime.hour();
                if(end_hour - start_Hour > 1){
                    start_Hour = start_Hour + 1;
                    dateTime starting_Event_Time = Datetime.newInstance(e.StartDateTime.year(),
                                        Integer.valueOf(getMonth_Day_Informat(e.StartDateTime.Month())),
                                        Integer.valueOf(getMonth_Day_Informat(e.StartDateTime.Day())),
                                        start_Hour,
                                        00,
                                        00);
                    user_booked_slots.put(starting_Event_Time,e.EndDateTime);
                }else{
                    user_booked_slots.put(e.StartDateTime,e.EndDateTime);
                }
            }
        }
        Map<String,SA_Calendar_Slots__c> slotMapFromSetting = SA_Calendar_Slots__c.getAll();
        Map<Date,Map<Datetime,Datetime>> slotMap = new Map<Date,Map<Datetime,Datetime>>();
        Map<Date,Map<Datetime,Datetime>> available_slots = new Map<Date,Map<Datetime,Datetime>>();
        
        for(Integer i=0;i<=no_of_Days;i++){
            Date dt = Appointment_date.addDays(i);
            map<Datetime,DateTime> dummyMap = new Map<Datetime,Datetime>();
            for(string key : slotMapFromSetting.keyset()){
                if(!slotMapFromSetting.get(key).Is_Lunch_Time__c){
                    Integer startSlot = getSlots_In_24Hrs(slotMapFromSetting.get(key).Slot_Start__c);
                    Integer endSlot = getSlots_In_24Hrs(slotMapFromSetting.get(key).Slot_End__c);
                    system.debug('startSlot::'+startSlot);
                    system.debug('endSlot::'+endSlot);
                    dateTime starting_Event_Time = Datetime.newInstance(Appointment_date.year(),
                                        Integer.valueOf(getMonth_Day_Informat(Appointment_date.Month())),
                                        Integer.valueOf(getMonth_Day_Informat(Appointment_date.Day())),
                                        startSlot,
                                        00,
                                        00);
                    dateTime end_Event_Time = Datetime.newInstance(Appointment_date.year(),
                                        Integer.valueOf(getMonth_Day_Informat(Appointment_date.Month())),
                                        Integer.valueOf(getMonth_Day_Informat(Appointment_date.Day())),
                                        endSlot,
                                        00,
                                        00);
                    dummyMap.put(starting_Event_Time , end_Event_Time);
                    system.debug('dummyMap:: '+dummyMap);
                }
            }
            
            slotMap.put(dt,dummyMap);
        }
        system.debug('slotMap key:: '+slotMap.keyset());
        system.debug('slotMap Values:: '+slotMap.Values());
        if(!user_booked_slots.isEmpty()){
            for(date dt : slotMap.keyset()){
                map<Datetime,DateTime> dummyMap = new Map<Datetime,Datetime>();
                for(datetime dm : slotMap.get(dt).keyset()){
                    if(user_booked_slots.containskey(dm)){
                            /// allotted slots
                    }else{
                        ////// available slots
                        dummyMap.put(dm,slotMap.get(dt).get(dm));
                    }
                }   
                available_slots.put(dt,dummyMap);
            }
        }else{
           available_slots.putAll(slotMap);
        }
        if(!available_slots.isEmpty()){
            for(date dt : available_slots.keyset()){
                SlotWrapper sw = new SlotWrapper();
                sw.scheduleDate = dt;
                List<string> dummyList = new List<String>();
                for(datetime dm : available_slots.get(dt).keyset()){
                    string slotString = '';
                    string st = getSlots_In_12Hrs(dm.hour());
                    string en = getSlots_In_12Hrs(available_slots.get(dt).get(dm).hour());
                    slotString = st + ' - ' + en;
                    dummyList.add(slotString);
                }
                sw.available_Slots.addAll(dummyList);
                sw.userId = userId;
                resultList.add(sw);
            }
        }
        return resultList;
    }*/
    
    /*public static List<SlotWrapper> GetSlots_For_LWC_Second(string userId, Date Appointment_date, Integer no_of_Days){
        List<SlotWrapper> resultList = new List<SlotWrapper>();
        
        List<Contact> contactDetails = getContactDetails(userId);
        List<User> user = getCAFromId(userId);
        
        string startTimeField = 'StartDateTime';
        String month_ST = string.valueOf(Appointment_date.month());
            if(month_ST.length() == 1)month_ST = '0' + month_ST;
        
        String day_ST = string.valueOf(Appointment_date.Day());
            if(day_ST.length() == 1)day_ST = '0' + day_ST;
        
        string startTime_Of_Visit_Date = Appointment_date.year() + '-' + month_ST + '-' + day_ST + 'T00:00:00Z';
        
        string query = 'select Id,ownerId,whoid,StartDateTime,EndDateTime,IsAllDayEvent from Event where ' +
                        'EndDateTime <= NEXT_N_DAYS:' + no_of_Days + ' and '+ 
                        string.valueOf(startTimeField) + ' >='+ startTime_Of_Visit_Date + ' and ' +
                        'ownerId = ' + '\'' + user[0].id + '\'';
        
        List<Event> eventList = Database.query(query);
        Map<Date,Date> alloted_Date = new Map<Date,Date>();
        if(eventList != null && !eventList.isEmpty()){
            for(event e : eventList){
                if(e.StartDateTime.Hour() >= contactDetails[0].Start_Slot__c.Hour() && e.EndDateTime.Hour() <= contactDetails[0].End_Slot__c.Hour())
                {
                    alloted_Date.put(e.StartDateTime.Date(),e.EndDateTime.Date());
                }
            }
        }
        List<Date> available_Date = new List<Date>();
        if(!alloted_Date.isEmpty()){
            for(Integer i=0;i<=no_of_Days;i++){
                Date dt = Appointment_date.addDays(i);
                if(alloted_Date.containskey(dt)){
                    
                }else{
                    available_Date.add(dt);
                }
            }
        }else{
            for(Integer i=0;i<=no_of_Days;i++){
                Date dt = Appointment_date.addDays(i);
                available_Date.add(dt);
            }
        }
        
        if(!available_Date.isEmpty()){
            for(Date dt : available_Date){
                List<string> dummyList = new List<String>();
                string st = getSlots_In_12Hrs(contactDetails[0].Start_Slot__c.Hour());
                string en = getSlots_In_12Hrs(contactDetails[0].End_Slot__c.Hour());
                system.debug('st::'+contactDetails[0].Start_Slot__c.Hour());
                system.debug('en::'+en);
                //sw.slot = st + ' - ' + en;
                //sw.slotWithDate = dt.format() + ' ' + sw.slot;
                boolean isAdd = true;
                if(system.today() == dt){
                    if(contactDetails[0].Start_Slot__c.Hour() < system.now().Hour()){
                        isAdd = false;
                    }
                }
                string st1 = st + ' - ' + en;
                string st2 = dt.format() + ' ' + st1;
                dummyList.add(st1);
                if(isAdd){
                    SlotWrapper sw1 = new SlotWrapper(dt,null,null,dummyList);
                    resultList.add(sw1);
                }
            }
        }
        
        return resultList;    
    }*/
    
    Public static SuccessWrapper bookSlot(string lId,string slot, Date appointmentDate, string userId, string SADeclinedReason,boolean isReschdule,string eventId){
        try{
           /* string st1 = slot.left(10);
            string st2 = slot.right(13);
            List<string> stList = st1.split('/');
            List<string> stList2 = st2.split('-');
            
            Integer yr = Integer.valueOf(stList[2]);
            Integer month = Integer.valueOf(stList[1]);
            Integer day = Integer.valueOf(stList[0]);
           
            Integer startTime = getSlots_In_24Hrs(stList2[0].trim());
            Integer endTime = getSlots_In_24Hrs(stList2[1].trim());*/
            Lead lead = getLead(lId);
            List<string> stList2 = slot.split('-');
            Integer startTime;
            Integer endTime;
            Integer startMinute;
            Integer endMinute;
            
            system.debug('stList2::'+stList2);
            List<string> startTimeSplit = stList2[0].split(':');
            startMinute = Integer.valueOf((startTimeSplit[1].trim()).left(2));
            string gg = startTimeSplit[0].trim() + ' ' + (startTimeSplit[1].trim()).right(2);
            system.debug('gg:'+gg);
            system.debug('ggg::'+getSlots_In_24Hrs(gg));
            startTime = getSlots_In_24Hrs(gg);
            
            List<string> endTimeSplit = stList2[1].split(':');
            endMinute = Integer.valueOf((endTimeSplit[1].trim()).left(2));
            string hh = endTimeSplit[0].trim() + ' ' + (endTimeSplit[1].trim()).right(2);
            system.debug('hh::'+hh);
            system.debug('hhh::'+getSlots_In_24Hrs(hh));
            endTime = getSlots_In_24Hrs(hh);
            
            Integer yr = appointmentDate.year();
            Integer month = appointmentDate.month();
            Integer day = appointmentDate.day();
           
            
           
            Datetime startDateTime = Datetime.newInstance(yr,month,day,startTime,startMinute,00);
            Datetime endDateTime = Datetime.newInstance(yr,month,day,endTime,endMinute,00);
            
            string owner = userId;
            string mobile = '';
            boolean isContact = userId.startsWith('003');
            if(isContact){
                system.debug('isnide');
                List<User> userList = getCAFromId(userId);
                system.debug('userList::'+userList);
                if(userList != null && !userList.isEmpty()){
                    owner = userList[0].id;
                    mobile = userList[0].mobilePhone;
                }
                
            }
            system.debug('owner::'+owner);
             /////Receck if Event was booked by other user
                  List<Event> eOld =[Select id from Event where ownerId =: owner AND 
                              ( ( StartDateTime =: startDateTime OR // start or end point same
                                EndDateTime =: endDateTime )
                                OR
                                ( StartDateTime <: startDateTime AND  // exisiting slot bigger than current slot
                                EndDateTime >: endDateTime )
                                OR
                               ( StartDateTime >: startDateTime  AND // exsisting slot smaller than current slot
                                EndDateTime <: endDateTime )
                                OR
                               ( StartDateTime <: startDateTime  AND // exsisting slot start & end before current start & end
                                EndDateTime >: startDateTime  )
                                OR
                               ( StartDateTime <: endDateTime  AND // exsisting slot start & end after current start & end
                                EndDateTime >: endDateTime )) ] ;
                if(!eOld.isEmpty()){
                     SuccessWrapper sw = new SuccessWrapper('Booked By another Agent',null,null,null);
            		return sw;
                }
           ///////////////////////////////////////////
            if(!isReschdule){
                Event e = new Event();
                e.ownerId = owner;
                e.whoId = lId;
                e.StartDateTime = startDateTime;
                e.EndDateTime = endDateTime;
                e.Subject = 'Appointment with ' + lead.Name;
                e.Owner_Mobile_No__c = mobile;
                e.Type='Appointment';
                if(lead.Street != null)
                    e.Location = lead.Street + ', ';
                if(lead.City != null){
                    e.Location += lead.City + ', ';
                }
                if(lead.State != null){
                    e.Location += lead.State + ', ';
                }
                if(lead.Country != null){
                    e.Location += lead.Country + ', ';
                }
                if(lead.PostalCode != null){
                    e.Location += lead.PostalCode;
                }
                e.Meeting_Time__c = appointmentDate.format() + ', ' + slot;
                e.Customer_Mobile__c = lead.MobilePhone;
                e.Customer_Name__c = lead.Name;
                insert e;
            }
            else{
                if(string.isNotBlank(eventId)){
                    Event e = new Event();
                    e.Id = eventId;
                    e.ownerId = owner;
                    e.whoId = lId;
                    e.StartDateTime = startDateTime;
                    e.EndDateTime = endDateTime;
                    e.Subject = 'Appointment with ' + lead.Name;
                    e.Owner_Mobile_No__c = mobile;
                    if(lead.Street != null)
                        e.Location = lead.Street + ', ';
                    if(lead.City != null){
                        e.Location += lead.City + ', ';
                    }
                    if(lead.State != null){
                        e.Location += lead.State + ', ';
                    }
                    if(lead.Country != null){
                        e.Location += lead.Country + ', ';
                    }
                    if(lead.PostalCode != null){
                        e.Location += lead.PostalCode;
                    }
                    e.Meeting_Time__c = appointmentDate.format() + ', ' + slot;
                    e.Customer_Mobile__c = lead.MobilePhone;
                    e.Customer_Name__c = lead.Name;
                    update e;
                }
            }
           /* Lead lead = getLead(lId);
            lead.OwnerId = owner;
            lead.status = 'Allocation Done';
            lead.Last_Appointment_Start_Date_Time__c = startDateTime;
            lead.Last_Appointment_End_Date_Time__c = endDateTime;
            if(string.isNotBlank(SADeclinedReason)){
                lead.Reason_For_SA_Declined__c = SADeclinedReason;
                lead.SA_Declined__c = true;
            }
            update lead;*/
            SuccessWrapper sw = new SuccessWrapper('Success',owner,startDateTime,endDateTime);
            system.debug('returning from try block');
            return sw;
        }catch(Exception ex){
            system.debug('Error in Save event::'+ex.getMessage());
            SuccessWrapper sw = new SuccessWrapper('Fail',null,null,null);
            return sw;
        }
        
    }
    
    Public static SuccessWrapper Bot_bookSlot(string lId,string slot, Date appointmentDate, string userId, string SADeclinedReason,boolean isReschdule,string eventId, String dealerId){
           Savepoint sp = Database.setSavepoint();
        try{
            Lead lead = getLead(lId);
            List<string> stList2 = slot.split('-');
            Integer startTime;
            Integer endTime;
            Integer startMinute;
            Integer endMinute;
            
            system.debug('stList2::'+stList2);
            List<string> startTimeSplit = stList2[0].split(':');
            startMinute = Integer.valueOf((startTimeSplit[1].trim()).left(2));
            string gg = startTimeSplit[0].trim() + ' ' + (startTimeSplit[1].trim()).right(2);
            system.debug('gg:'+gg);
            system.debug('ggg::'+getSlots_In_24Hrs(gg));
            startTime = getSlots_In_24Hrs(gg);
            
            List<string> endTimeSplit = stList2[1].split(':');
            endMinute = Integer.valueOf((endTimeSplit[1].trim()).left(2));
            string hh = endTimeSplit[0].trim() + ' ' + (endTimeSplit[1].trim()).right(2);
            system.debug('hh::'+hh);
            system.debug('hhh::'+getSlots_In_24Hrs(hh));
            endTime = getSlots_In_24Hrs(hh);
            
            Integer yr = appointmentDate.year();
            Integer month = appointmentDate.month();
            Integer day = appointmentDate.day();
           
            Datetime startDateTime = Datetime.newInstance(yr,month,day,startTime,startMinute,00);
            Datetime endDateTime = Datetime.newInstance(yr,month,day,endTime,endMinute,00);
            
            string owner = userId;
            string mobile = '';
            boolean isContact = userId.startsWith('003');
            if(isContact){
                system.debug('isnide');
                List<User> userList = getCAFromId(userId);
                system.debug('userList::'+userList);
                if(userList != null && !userList.isEmpty()){
                    owner = userList[0].id;
                    mobile = userList[0].mobilePhone;
                }
                
            }
            system.debug('owner::'+owner);
         
            if(!isReschdule){
                Event e = new Event();
                e.ownerId = owner;
                e.whoId = lId;
                e.StartDateTime = startDateTime;
                e.EndDateTime = endDateTime;
                e.Subject = 'Appointment with ' + lead.Name;
                e.Owner_Mobile_No__c = mobile;
                e.Type='Appointment';
                e.Customer_Mobile__c = lead.MobilePhone;
                e.Customer_Name__c = lead.Name;
                insert e;
                eventId = e.Id;
            }else{
                if(string.isNotBlank(eventId)){
                    Event e = new Event();
                    e.Id = eventId;
                    e.ownerId = owner;
                    e.whoId = lId;
                    e.StartDateTime = startDateTime;
                    e.EndDateTime = endDateTime;
                    e.Subject = 'Appointment with ' + lead.Name;
                    e.Owner_Mobile_No__c = mobile;
                    e.Customer_Mobile__c = lead.MobilePhone;
                    e.Customer_Name__c = lead.Name; 
                    update e;
                }
            }
            system.debug('Event inserted '+ eventId);
            //Lead lead = getLead(lId);
            lead.OwnerId = owner;
            lead.status = 'Allocation Done';
            lead.Last_Appointment_Start_Date_Time__c = startDateTime;
            lead.Last_Appointment_End_Date_Time__c = endDateTime;
            lead.Bot_Journey__c = 'Appointment Scheduled';
            if(string.isNotBlank(SADeclinedReason)){
                lead.Description = SADeclinedReason;
            }
            lead.Whatsapp_Notification__c = isReschdule;
            if(dealerId != null && dealerId != ''){ // Added by Sankalp
                lead.Dealer__c = dealerId;
            }            
            update lead;
            SuccessWrapper sw = new SuccessWrapper('Success',owner,startDateTime,endDateTime,eventId);
            return sw;
        }
        catch(Exception ex){
            system.debug('Error in Save event::'+ex.getMessage());
            SuccessWrapper sw = new SuccessWrapper('Fail',ex.getMessage(),null,null,null);
            Database.rollback(sp);
            return sw;
        }
        
    }
    
    @InvocableMethod(label='Create Event from flow' Description='use in flow for the creating the event on unit')
    public static List<string> createEvent(List<FlowRequest> req){
        system.debug('inside create event method::'+req);
        string resultString = bookEventFromFlow(req[0].uId, req[0].startTime, req[0].endTime, req[0].reason);
        List<string> stList = new List<String>();
        if(string.isNotBlank(resultString) && resultString == 'Success'){
            stList.add('Event has been successfully created');
            return stList;
        }else{
            stList.add('Failed to create event:: \n' + resultString);
            return stList;
        }
    }
    
    public static string bookEventFromFlow(string unitId, Datetime startDateTime, Datetime endDateTime, string reason){
        try{
            List<Service_Territory__c > regions = [select id,name,Parent__c from Service_Territory__c where 
                                                   Parent__c =: unitId and Type__c = 'Region'];
            set<Id> regionIDs = new Set<Id>();
            if(regions != null && !regions.isEmpty()){
                for(Service_Territory__c st : regions)
                regionIDs.add(st.Id);
            }
            system.debug('regionIDs:: '+regionIDs);
            List<Service_Territory__c > pincodes = [select id, name, Type__c, Parent__c, Pincode__c,Pincode__r.Name,
                                                    Parent__r.Parent__r.Service__c
                                                    from Service_Territory__c
                                                    where Type__c = 'Pincode' and Parent__c IN: regionIDs];
            system.debug('pincodes:: '+pincodes);
            if(pincodes != null && !pincodes.isEmpty()){
                set<string> pins = new set<String>();
                string service;
                for(Service_Territory__c st : pincodes){
                    pins.add(st.Pincode__r.Name);
                    service = st.Parent__r.Parent__r.Service__c;
                }
                List<SA_Pincode_Mapping__c > uList = [select id,name,SA__c,SA__r.Name,Pincode__c,Service__c/*BU__c*/,Role__c, Priority__c,
                                                      SA__r.mobilePhone
                                                      from SA_Pincode_Mapping__c
                                                      where Pincode__C IN:pins and Service__c =: service order by Priority__c ASC];
                
                if(uList != null && !ulist.isEmpty()){
                    set<Id> contactIds = new set<Id>();
                    for(SA_Pincode_Mapping__c s : uList){
                        contactIds.add(s.SA__c);
                    }
                    map<Id,user> userMap = new map<Id,user>();
                    for(User u : [select Id,name,contactId from user where contactId IN:contactIds]){
                        userMap.put(u.Id,u);
                    }
                    if(!userMap.isEmpty()){
                        Events__c events = new Events__c();
                        events.name = reason + ' Events created';
                        events.Unit__c = unitId;
                        events.End_Date_Time__c = endDateTime;
                        events.Start_Date_Time__c = startDateTime;
                        events.Reason__c  = reason;
                        events.Description__c = reason + ' events created and started on ' + startDateTime.date().format() + 
                                                '. Total no of users assign: ' + userMap.keySet().size();  
                        insert events;
                        
                        List<Id> eventIds = new List<Id>();
                        List<event> eventToInsert = new List<event>();
                        for(Id key : userMap.keySet()){
                            Event e = new Event();
                            e.ownerId = key;
                            e.whoId = userMap.get(key).contactId;
                            e.StartDateTime = startDateTime;
                            e.EndDateTime = endDateTime;
                            e.Subject = reason;
                            e.whatId = events.Id;
                            e.Unit__c = unitId;
                            //insert e;
                           // eventIds.add(e.Id);
                            eventToInsert.add(e);
                        }
                        insert eventToInsert;
                        return 'Success';
                    }
                }
            }
        }catch(Exception ex){
            system.debug('error:: '+ex.getMessage());
            return ex.getMessage();
        }
        return null;
    }
    
    public static Integer getSlots_In_24Hrs(string i){
        if(i=='00 AM'){return 00;}
        else if(i=='01 AM'){return 01;}
        else if(i=='02 AM'){return 02;}
        else if(i=='03 AM'){return 03;}
        else if(i=='04 AM'){return 04;}
        else if(i=='05 AM'){return 05;}
        else if(i=='06 AM'){return 06;}
        else if(i=='07 AM'){return 07;}
        else if(i=='08 AM'){return 08;}
        else if(i=='09 AM'){return 09;}
        
        else if(i=='10 AM'){return 10;}
        else if(i=='11 AM'){return 11;}
        else if(i=='12 PM'){return 12;}
        else if(i=='01 PM'){return 13;}
        else if(i=='02 PM'){return 14;}
        else if(i=='03 PM'){return 15;}
        else if(i=='04 PM'){return 16;}
        else if(i=='05 PM'){return 17;}
        else if(i=='06 PM'){return 18;}
        else if(i=='07 PM'){return 19;}
        else if(i=='08 PM'){return 20;}
        else if(i=='09 PM'){return 21;}
        else if(i=='10 PM'){return 22;}
        else if(i=='11 PM'){return 23;}
        return null;
    }
    
    public static String getSlots_In_12Hrs(Integer i){
        if(i==00){return '12 AM';}
        else if(i==01){return '01 AM';}
        else if(i==02){return '02 AM';}
        else if(i==03){return '03 AM';}
        else if(i==04){return '04 AM';}
        else if(i==05){return '05 AM';}
        else if(i==06){return '06 AM';}
        else if(i==07){return '07 AM';}
        else if(i==08){return '08 AM';}
        else if(i==09){return '09 AM';}
        else if(i==10){return '10 AM';}        
            
        else if(i==11){return '11 AM';}
        else if(i==12){return '12 PM';}
        else if(i==13){return '01 PM';}
        else if(i==14){return '02 PM';}
        else if(i==15){return '03 PM';}
        else if(i==16){return '04 PM';}
        else if(i==17){return '05 PM';}
        else if(i==18){return '06 PM';}
        else if(i==19){return '07 PM';}
        else if(i==20){return '08 PM';}
        else if(i==21){return '09 PM';}
        else if(i==22){return '10 PM';}
        else if(i==23){return '11 PM';}
        return null;
    }
    public static string getMonth_Day_Informat(Integer i){
        string ST = string.valueOf(i);
            if(ST.length() == 1)ST = '0' + ST;
        return ST;
    }
    public class SlotWrapper implements Comparable{
        @AuraEnabled public Date scheduleDate;
        @AuraEnabled public string slot;
        @AuraEnabled public string slotWithDate;
        @AuraEnabled public List<string> available_Slots;
        @AuraEnabled public string userId;
        @AuraEnabled public Boolean noUser;
        
        public SlotWrapper(){
             available_Slots = new List<string>();
        }
        
        public SlotWrapper(Date sDate, string slot, string slotWithDate, List<string> available_Slots){
            this.scheduleDate = sDate;
            this.slot = slot;
            this.slotWithDate = slotWithDate;
            this.available_Slots = available_Slots;
        }        
        
        Public Integer compareTo (Object compareTo) {
            SlotWrapper slotW = (SlotWrapper)compareTo;
            Integer returnValue = 0;
            If (scheduleDate > slotW.scheduleDate) {
            returnValue = 1;
            } else if (scheduleDate < slotW.scheduleDate) {
            returnValue = -1;
            }
            Return returnValue; 
        }
    }
    public class UserWrapper{
        @AuraEnabled public String BU;
        @AuraEnabled public String role;
        @AuraEnabled public List<SA_Pincode_Mapping__c> userList;
        public UserWrapper(){
            userList = new List<SA_Pincode_Mapping__c>();
        }
        
    }
    
    public class CADetailsWrapper{
        @AuraEnabled public User CA;
        @AuraEnabled public Account dealer;
        @AuraEnabled public Contact CA_Contact;
        @AuraEnabled public string phone;
        
        
        public CADetailsWrapper(){
            CA = new user();
            dealer = new Account();
            CA_Contact = new Contact();
        }
        
    }
    
    public class SuccessWrapper{
        @AuraEnabled public String message;
        @AuraEnabled public string userId;
        @AuraEnabled public Datetime startTime;
        @AuraEnabled public Datetime endTime;
        @AuraEnabled public string eventId;
        
        
        public SuccessWrapper(string msg, string uId, Datetime startTime, Datetime endTime){
            this.message = msg;
            this.userId = uId;
            this.startTime = startTime;
            this.endTime = endTime;
        }
        
        public SuccessWrapper(string msg, string uId, Datetime startTime, Datetime endTime,string eventId){
            this.message = msg;
            this.userId = uId;
            this.startTime = startTime;
            this.endTime = endTime;
            this.eventId = eventId;
        }
        public SuccessWrapper(){
            
        }
        
    }
    public class FlowRequest{
        @InvocableVariable
        public string uId;
        @InvocableVariable
        public DateTime startTime;
        @InvocableVariable
        public DateTime endTime;
        @InvocableVariable
        public string reason;
    }    
    
}