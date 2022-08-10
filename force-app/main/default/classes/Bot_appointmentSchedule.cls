public class Bot_appointmentSchedule {
    
    public class PrechatInput{
        @InvocableVariable
        public String LeadId;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String dealerId;
        @InvocableVariable
        public String onlySlot;
        @InvocableVariable
        public Date SelectedDate;
    }
    
    public class PrechatOutput{
        @InvocableVariable//(required=true)
        public List<ScheduleAppointmentServices.SlotWrapper> availableSlots;
        @InvocableVariable
        public String selectedSlot;
        //@InvocableVariable
        //public Date selectedDate;
        @InvocableVariable
        public Boolean isAppointmentScheduled = False;
    }
    
    @InvocableMethod(label = 'Bot_appointmentSchedule')
    public static List<PrechatOutput> appointmentSchedule(List<PrechatInput> inputParameters){//List<PrechatInput> inputParameters
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String LeadId = inputParameters[0].LeadId;
        String contactId = inputParameters[0].contactId;
        String dealerId = inputParameters[0].dealerId;
        String onlySlot = inputParameters[0].onlySlot;
        Date OnlyDate = inputParameters[0].SelectedDate;
        
        ScheduleAppointmentServices.SuccessWrapper sw = ScheduleAppointmentServices.Bot_bookSlot(LeadId, onlySlot, OnlyDate,contactId,null,False,null,dealerId);
        // parameters of bookSlot(string lId,string slot,Date appointmentDate, string userId, string SADeclinedReason,boolean isReschdule, string eventId){
        System.debug('## sw : '+sw);
        
        if(sw != null ){
            outputParameter.isAppointmentScheduled = True;
        }
        else{
            outputParameter.isAppointmentScheduled = False;
        }
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}