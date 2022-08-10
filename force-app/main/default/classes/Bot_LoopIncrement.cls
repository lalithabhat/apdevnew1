public class Bot_LoopIncrement {
    
    public class PrechatInput{
        @InvocableVariable
        public Integer LoopCounterValueInput;
    }
    
    public class PrechatOutput{
        @InvocableVariable
        public Integer LoopCounterValueOutput;
    }
    @InvocableMethod(label = 'Bot_LoopIncrement')
    public static List<PrechatOutput> LoopIncrement(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        Integer LoopCounterValueInput = inputParameters[0].LoopCounterValueInput;
        Integer InitialCounter = 0;
        
        if(LoopCounterValueInput == null || LoopCounterValueInput == 0){
            outputParameter.LoopCounterValueOutput = InitialCounter+1;
        }
        else if(LoopCounterValueInput >= 1){
            outputParameter.LoopCounterValueOutput = LoopCounterValueInput+1;
        }
        
        outputParameters.add(outputParameter);
        
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}