public class Bot_endFlowCheck {
    
    public class PrechatInput{
        @InvocableVariable
        public string Check;
    }
    
    public class PrechatOutput{
        @InvocableVariable
        public string OutputCheck;
    }
    
    @InvocableMethod(label = 'Bot_endFlowCheck')
    public static List<PrechatOutput> endFlowCheck(List<PrechatInput> inputParameters){//List<PrechatInput> inputParameters
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        outputParameter.OutputCheck = inputParameters[0].Check;
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}