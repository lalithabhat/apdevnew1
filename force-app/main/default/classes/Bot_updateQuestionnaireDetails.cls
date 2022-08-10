public class Bot_updateQuestionnaireDetails {
    public class PrechatInput{
        @InvocableVariable
        public string LeadId;
        @InvocableVariable
        public string Question1;
        @InvocableVariable
        public string Question2;
        @InvocableVariable
        public string Question3;
        @InvocableVariable
        public string Question4;
        
    }
    public class PrechatOutput{
        @InvocableVariable
        public Boolean isServiceable;
        @InvocableVariable
        public String Message;
    }
    @InvocableMethod(label = 'Bot_updateQuestionnaireDetails')
    public static List<PrechatOutput> updateQuestionnaireDetails(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String LeadId = inputParameters[0].LeadId;
        String Question1 = inputParameters[0].Question1;
        String Question2 = inputParameters[0].Question2;
        String Question3 = inputParameters[0].Question3;
        
        Lead l = [Select id from Lead where id =: LeadId];
        
        System.debug('#outputParameter : '+outputParameter);
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}