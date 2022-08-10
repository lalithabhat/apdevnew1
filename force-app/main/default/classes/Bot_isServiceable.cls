public class Bot_isServiceable {
    public class PrechatInput{
        @InvocableVariable
        public string Pincode;
        @InvocableVariable
        public string BU;
        @InvocableVariable
        public string Name;
        
    }
    public class PrechatOutput{
        @InvocableVariable
        public Boolean isServiceable;
    }
    @InvocableMethod(label = 'Bot_isServiceable') 
    public static List<PrechatOutput> isServiceable(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String Pincode = inputParameters[0].Pincode;
        String BU = inputParameters[0].BU;
        
        outputParameter.isServiceable = ServiceabilityManagement.getLeadServiceableFromBot(Pincode,BU);
        
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}