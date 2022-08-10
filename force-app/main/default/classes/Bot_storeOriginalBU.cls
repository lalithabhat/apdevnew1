public class Bot_storeOriginalBU {
    
    public class PrechatInput{
        @InvocableVariable
        public string originalBU;
    }
    
    public class PrechatOutput{
        @InvocableVariable
        public string OutputoriginalBU;
    }
    
    @InvocableMethod(label = 'Bot_storeOriginalBU')
    public static List<PrechatOutput> storeOriginalBU(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        outputParameter.OutputoriginalBU = inputParameters[0].originalBU;
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}