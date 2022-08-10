public class Bot_getSlot {
    
    public class PrechatInput{
        @InvocableVariable
        public String LeadId;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String role;
        @InvocableVariable
        public String SelectedSlot;
    }
    
    public class PrechatOutput{
        @InvocableVariable//(required=true)
        public List<String> availableSlots;
        @InvocableVariable
        public Boolean isServiceable;
        @InvocableVariable
        public String Message;
        @InvocableVariable
        public string ContactId;
        @InvocableVariable
        public String onlySlot;
        @InvocableVariable
        public Date selectedDate;
    }
    
    @InvocableMethod(label = 'Bot_getSlot')
    public static List<PrechatOutput> getSlot(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String LeadId = inputParameters[0].LeadId;
        System.debug('## LeadId : '+LeadId);
        
        String SelectedSlot = inputParameters[0].SelectedSlot;
        System.debug('## SelectedSlot : '+SelectedSlot);
        
        if(SelectedSlot != null && SelectedSlot != ''){
            List<String> parsedSelectedSlot = SelectedSlot.split(' on ');
            String slotFromList = parsedSelectedSlot[0];
            String dateFromList = parsedSelectedSlot[1];
            
            
            Date onlyDate = Date.parse(dateFromList);
            
            outputParameter.onlySlot = slotFromList;
            outputParameter.selectedDate = OnlyDate;
        }
        
        
        ScheduleAppointmentServices.UserWrapper uw = Get_SA_Available_Slot.getContactList(LeadId);
        System.debug('## uw : '+uw);
        
        string contactId = inputParameters[0].contactId;
        string role = inputParameters[0].role;
        
        if(contactId == null || contactId == ''){ // This will execute in the BHS Flow
            if(uw.BU == 'SPS'){ // it means SA is avaialble
                System.debug('## 1 ##');
                if(!uw.userList.isEmpty()){
                    System.debug('## 2 ##');
                    contactId = uw.userList[0].SA__c;
                    role = 'SA';
                }
                else{  // find CA
                    System.debug('## 3 ##');
                    ScheduleAppointmentServices.CADetailsWrapper cw = Get_SA_Available_Slot.getCAList(LeadId,null);
                    System.debug('## cw : '+cw);
                    contactId = cw.CA_Contact.Id;
                    role = 'CA';
                }
            }else if(uw.BU == 'BHS'){
                System.debug('## 4 ##');
                contactId = uw.userList[0].SA__c;
                role = 'BHS';
            }
        }
        
        // contactId and role has been passed from the Bot_isSAorCA for SPS flow
        List<ScheduleAppointmentServices.SlotWrapper> sw1 = Get_SA_Available_Slot.getSlots(ContactId, role, Date.valueOf(System.today()+1),LeadId);
        // parameters of getSlots(string userId, string role, date appointment_Date,string lId)
        System.debug('## sw1 : '+sw1);
        
        if(ContactId!= null){
            outputParameter.ContactId = ContactId;
        }
        
        List<String> tempList = new List<String>();
        for(ScheduleAppointmentServices.SlotWrapper swi : sw1){
            
            for(String s : swi.available_Slots){
                //tempList.add(s);
                tempList.add(s+' on '+swi.scheduleDate.format());
            }       
            
            if(tempList.size()>=5){
                break;
            }
        }
        
        if(tempList.size() < 1){
            tempList.add('No slot available');
        }
        tempList.add('For more options chat with an Agent');

        outputParameter.availableSlots = tempList;
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}