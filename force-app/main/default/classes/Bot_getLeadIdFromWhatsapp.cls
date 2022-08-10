public class Bot_getLeadIdFromWhatsapp {

    public class PrechatInput{
        @InvocableVariable
        public String whatsappNumberWithCode;
        @InvocableVariable
        public String whatsappNumberWithoutCode;
        @InvocableVariable
        public String CountryCode;
    }
    public class PrechatOutput{
        @InvocableVariable
        public Id leadId;
        @InvocableVariable
        public string LeadPincode;
        @InvocableVariable
        public string LeadEmail;
        @InvocableVariable
        public string LeadBU;
        @InvocableVariable
        public string LeadLastName;
        @InvocableVariable
        public string LeadRecordTypeName;
        @InvocableVariable
        public Boolean leadExists = False;
        @InvocableVariable
        public Boolean leadExistsWithBotJourney = False;
        @InvocableVariable
        public Boolean leadExistsWithStatus = False;
    }
    @InvocableMethod(label = 'Bot_getLeadIdFromWhatsapp')
    public static List<PrechatOutput> getLeadId(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String whatsappNumberWithCode = inputParameters[0].whatsappNumberWithCode;
        String whatsappNumberWithoutCode = inputParameters[0].whatsappNumberWithoutCode;
        String CountryCode = inputParameters[0].CountryCode;
        
        
        List<Lead> leadList = [SELECT Id, Name, Pincode__c, MobilePhone, Email, RecordTypeId, RecordType.Name, Skills__c, 
                               Service_Territory__c,is_Bot__c, Status, Bot_Journey__c
                               From Lead
                               Where MobilePhone =: whatsappNumberWithoutCode
                               ORDER BY CreatedDate DESC];
        System.debug('##leadList : '+leadList);
        if(leadList != null && leadList.size() > 0){
            outputParameter.leadId = leadList[0].id;
            outputParameter.leadExists = True;
            outputParameter.LeadLastName = leadList[0].Name;
            outputParameter.LeadPincode = leadList[0].Pincode__c;
            outputParameter.LeadRecordTypeName = leadList[0].RecordType.Name;
            if(leadList[0].Bot_Journey__c != 'Appointment Scheduled' ||leadList[0].Bot_Journey__c == 'Self Service-Appointment Scheduled'){
                outputParameter.leadExistsWithBotJourney = True;
            }
            if(leadList[0].Status != 'Allocation Done' || leadList[0].Status != 'Lost'){
                outputParameter.leadExistsWithStatus = True;
            }
        }
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}