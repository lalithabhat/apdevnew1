public class Bot_getDate {
    
    public class PrechatInput{
        @InvocableVariable
        public String LeadId;
    }
    
    public class PrechatOutput{
        @InvocableVariable
        public List<String> listDate;
    }
    
    @InvocableMethod(label = 'Bot_getDate')
    public static List<PrechatOutput> getDate(List<PrechatInput> inputParameters){//List<PrechatInput> inputParameters
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        List<String> tempList = new List<String>();
        
        for (Integer i = 0; i < 3; i++) {
            tempList.add((System.today()+i).format());
            
        }
        
        tempList.add('No slot available');
        outputParameter.listDate = tempList;
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}