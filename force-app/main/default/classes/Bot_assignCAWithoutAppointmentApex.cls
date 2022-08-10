public class Bot_assignCAWithoutAppointmentApex {
    
    public class PrechatInput{
        @InvocableVariable
        public String LeadId;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String dealerId;
    }
    
    public class PrechatOutput{
        @InvocableVariable
        public Boolean isAppointmentScheduled = False;
    }
    
    @InvocableMethod(label = 'Bot_assignCAWithoutAppointmentApex')
    public static List<PrechatOutput> assignCAWithoutAppointmentApex(List<PrechatInput> inputParameters){//List<PrechatInput> inputParameters
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String LeadId = inputParameters[0].LeadId;
        String contactId = inputParameters[0].contactId;
        String dealerId = inputParameters[0].dealerId;
        
        String appointmentStatus = Get_SA_Available_Slot.Bot_assignCAWithoutAppointmentApex(LeadId, contactId, dealerId);
        System.debug('## appointment : '+appointmentStatus);
        
        if(appointmentStatus == 'Success'){
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