public class Bot_storePreviousLeadId {
    public class PrechatInput{
        @InvocableVariable
        public string previousLeadId;//bhs lead
    }
    
    public class PrechatOutput{
        @InvocableVariable
        public string opPreviousLeadId;
    }
    
    @InvocableMethod(label = 'Bot_storePreviousLeadId')
    public static List<PrechatOutput> storePreviousLeadId(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        if(inputParameters[0].previousLeadId != null){
            outputParameter.opPreviousLeadId = inputParameters[0].previousLeadId;
        }
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}