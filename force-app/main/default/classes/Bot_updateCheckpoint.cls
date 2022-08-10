public class Bot_updateCheckpoint {
    public class PrechatInput{
        @InvocableVariable
        public string InputCheckpoint;        
    }
    public class PrechatOutput{
        @InvocableVariable
        public string OutputCheckpoint;        
    }
    @InvocableMethod(label = 'Bot_updateCheckpoint') 
    public static List<PrechatOutput> updateCheckpoint(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        outputParameter.OutputCheckpoint = inputParameters[0].InputCheckpoint;
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}