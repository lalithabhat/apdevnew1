public class Bot_getBU {
    
    public class PrechatInput{
        @InvocableVariable
        public string BU;
    }
    
    public class PrechatOutput{
        @InvocableVariable
        public string OutputBU;
    }
    
    @InvocableMethod(label = 'Bot_getBU')
    public static List<PrechatOutput> getBU(List<PrechatInput> inputParameters){//List<PrechatInput> inputParameters
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        outputParameter.OutputBU = inputParameters[0].BU;
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}