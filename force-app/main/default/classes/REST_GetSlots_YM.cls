@RestResource(urlMapping='/GetSlots/*')
global class REST_GetSlots_YM {
    @HttpPOST
    global static REST_result getSlots(string pincode, string serviceGroup, string crmLeadId, string fromDate, string toDate, Integer priority){
        REST_result r = new REST_result();
        if(string.isBlank(pincode) || string.isBlank(serviceGroup) || string.isBlank(crmLeadId)){
            r.returnCode = 201;
            r.message = 'Required Parameters are missing';
            r.CRMuserId = null;
            r.AvailableSlots = null;
            return r;
        }else{
            date frmdt;
            Date todt;
            if(string.isNotBlank(fromDate) && string.isNotBlank(toDate)){
                 frmdt = Date.valueOf(fromDate);
            	 todt = Date.valueOf(toDate);
                if(frmdt > todt){
                    r.returnCode = 208;
                    r.message = 'toDate should be greater than fromDate';
                    r.CRMuserId = null;
                    r.AvailableSlots = null;
                    return r;
                }
            }
            Lead lObj = ScheduleAppointmentServices.getLead(crmLeadId);
            if(lObj != null && lObj.Id != null){
                ///// Check passed pincode and Bu match with lead else throw error
                if(lObj.Pincode__c != pincode){
                    r.returnCode = 204;
                    r.message = 'Pincode does not match';
                    r.CRMuserId = null;
                    r.AvailableSlots = null;
                    return r;
                }
                if(lObj.recordtype.name != serviceGroup){
                    r.returnCode = 205;
                    r.message = 'Recordtype does not match';
                    r.CRMuserId = null;
                    r.AvailableSlots = null;
                    return r;
                }
                
                List<SA_Pincode_Mapping__c> userList = new List<SA_Pincode_Mapping__c>();
                string userId;
                string role;
                string dealerId;
                if(lObj.RecordType.Name == 'SPS'){
                    userList = ScheduleAppointmentServices.getUsers_For_SPS(lObj.Pincode__c,lObj.RecordType.Name, priority);
                    if(userList.isEmpty()){
                        ScheduleAppointmentServices.CADetailsWrapper cdw = ScheduleAppointmentServices.getCA(lObj,null);
                        if(cdw != null){
            				List<User> user = ScheduleAppointmentServices.getUser_From_Id(cdw.CA.Id);
                            if(user != null && !user.isEmpty()){
                               	List<Contact> cList = ScheduleAppointmentServices.getContactDetails(user[0].contactId);
                                if(cList != null && !cList.isEmpty()){
                                    userId = cList[0].Id;
                                    role = 'CA';
                                    dealerId = cdw.dealer.Id;
                                }
                            }
                        }
                    }else{
                        userId = userList[0].SA__c;
                        role = 'SA';
                    }
                }else if(lObj.RecordType.Name == 'BHS'){
                    userList = ScheduleAppointmentServices.getUsers_For_BHS(lObj.Pincode__c,lObj.RecordType.Name, priority);
                    if(!userList.isEmpty()){
                        userId = userList[0].SA__c;
                        role = 'BHS';
                    }
                }
                if(string.isBlank(userId)){
                    r.returnCode = 206;
                    r.message = 'There is no user found';
                    r.CRMuserId = null;
                    r.AvailableSlots = null;
                    return r;
                }else{
                    List<ScheduleAppointmentServices.SlotWrapper> resultWrapper = new List<ScheduleAppointmentServices.SlotWrapper>();
                    Date appointmentDate = system.today();
                    Integer no_Days = 5;
                    if(frmdt != null){
                        appointmentDate = frmdt;
                    }
                    if(todt != null){
                        no_Days = appointmentDate.daysBetween(todt);
                    }
                    if(role == 'SA' || role == 'BHS'){
                         resultWrapper = ScheduleAppointmentServices.GetSlots_For_LWC_FIRST2(userId,appointmentDate,no_Days,lObj.Id,todt);
                    }else if(role == 'CA'){
                         resultWrapper = ScheduleAppointmentServices.GetSlots_For_LWC_Second2(userId,appointmentDate,no_Days,lObj.Id,todt);
                    }
                    List<ScheduleAppointmentServices.SlotWrapper> resultWrapper_For_6_Slots = new List<ScheduleAppointmentServices.SlotWrapper>();
                    if(resultWrapper != null && !resultWrapper.isEmpty()){
                        resultWrapper_For_6_Slots.addAll(resultWrapper);
                        /*system.debug('resultWrapper::'+resultWrapper.size());
                        resultWrapper.sort();
                        if(resultWrapper.size() > 6 && string.isBlank(fromDate) && string.isBlank(toDate)){
                            for(Integer i=0;i<6; i++){
                                resultWrapper_For_6_Slots.add(resultWrapper[i]);
                            }
                        }else{
                            resultWrapper_For_6_Slots.addAll(resultWrapper);
                        }*/
                    }else{
                        r.returnCode = 207;
                        r.message = 'No slots available';
                        r.CRMuserId = null;
                        r.AvailableSlots = null;
                        return r;
                    }
                    if(!resultWrapper_For_6_Slots.isEmpty()){
                        List<REST_Slot> availableList = new List<REST_Slot>();
                        for(ScheduleAppointmentServices.SlotWrapper sw : resultWrapper_For_6_Slots){
                            REST_Slot rs = new REST_Slot();
                            rs.availableDate = sw.scheduleDate;
                            rs.slots = sw.available_Slots;
                            availableList.add(rs);
                        }
                        r.returnCode = 200;
                        r.message = 'Success';
                        r.CRMuserId = userId;
                        r.availableSlots = availableList;
                        r.dealerId = dealerId;
                        return r;
                        
                    }
                }
                
            }else{
                r.returnCode = 202;
                r.message = 'Lead record not found';
                r.CRMuserId = null;
                r.AvailableSlots = null;
                return r;
            }
        }
    	return null;
    }
    
    global class REST_result {
        webservice Integer returnCode;
        webservice String message;
        webservice String CRMuserId;
        webservice List<REST_Slot> AvailableSlots;
        webservice string dealerId;
        
        global REST_result(){
            AvailableSlots = new List<REST_Slot>();
        }
    }
    
    global class REST_Slot {
        webservice Date availableDate;
        webservice List<String> slots;
        
        global REST_Slot(){
            slots = new List<String>();
        }
        
    }
}