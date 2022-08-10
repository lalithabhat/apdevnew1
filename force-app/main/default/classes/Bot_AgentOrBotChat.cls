public class Bot_AgentOrBotChat {
    
    public class PrechatInput{
        @InvocableVariable
        public string ChatSource;
    }
    
    public class PrechatOutput{
        @InvocableVariable
        public string OutputChatSource;
    }
    
    @InvocableMethod(label = 'Bot_AgentOrBotChat')
    public static List<PrechatOutput> AgentOrBotChat(List<PrechatInput> inputParameters){//List<PrechatInput> inputParameters
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        outputParameter.OutputChatSource = inputParameters[0].ChatSource;
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }

}