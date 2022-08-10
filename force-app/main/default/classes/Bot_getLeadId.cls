public class Bot_getLeadId {
    public class PrechatInput{
        @InvocableVariable
        public string Pincode;
        @InvocableVariable
        public string BU;
        @InvocableVariable
        public string FlowBU; // This is the BU for different flows within the chatbot, it is used to perform certain conditional checks
        @InvocableVariable
        public string Name;
        @InvocableVariable
        public string Mobile;
        @InvocableVariable
        public string Email;
        @InvocableVariable
        public string WhatsappOptin;
        @InvocableVariable
        public string OriginalBU;
        
    }
    public class PrechatOutput{
        @InvocableVariable
        public Id leadId;
        @InvocableVariable
        public Id MessageUserId;
    }
    @InvocableMethod(label = 'Bot_getLeadId/createLead')
    public static List<PrechatOutput> getLeadId(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String Pincode = inputParameters[0].Pincode;
        String BU = inputParameters[0].BU;
        String Name = inputParameters[0].Name;
        String Mobile = inputParameters[0].Mobile;
        String Email = inputParameters[0].Email; 
        String WhatsappOptin = inputParameters[0].WhatsappOptin;
        String OriginalBU = inputParameters[0].OriginalBU;
        
        outputParameter.leadId = AP_BotManagementServices.createBotLead(Name, Mobile, Email, Pincode, BU, OriginalBU);
        Set<Id> leadSet = new Set<Id>();
        leadSet.add(outputParameter.leadId);
        AP_BotManagementServices.initiateJourney(leadSet);
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}