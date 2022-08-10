public class Bot_getStringValues {
    public class PrechatInput{
        @InvocableVariable
        public string InputString;
    }
    public class PrechatOutput{
        @InvocableVariable
        public string Option1;
        @InvocableVariable
        public string Option2;
        @InvocableVariable
        public string Option3;
        @InvocableVariable
        public string Option4;
        @InvocableVariable
        public string Option5;
        @InvocableVariable
        public string Option6;
        @InvocableVariable
        public string Option7;
        @InvocableVariable
        public String Message;
    }
    @InvocableMethod(label = 'Bot_getStringValues')
    public static List<PrechatOutput> getStringValues(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();

        String InputString = inputParameters[0].InputString;
        
        try{
            if(InputString.contains('1')){
                outputParameter.Option1 = '1';
            }
            if(InputString.contains('2')){
                outputParameter.Option2 = '2';
            }
            if(InputString.contains('3')){
                outputParameter.Option3 = '3';
            }
            if(InputString.contains('4')){
                outputParameter.Option4 = '4';
            }
            if(InputString.contains('5')){
                outputParameter.Option5 = '5';
            }
            if(InputString.contains('6')){
                outputParameter.Option6 = '6';
            }
            if(InputString.contains('7')){         
                outputParameter.Option7 = '7';
            }
        }
        catch(Exception e){
            outputParameter.Message = e.getMessage();
        }
        
        System.debug(outputParameter);
        outputParameters.add(outputParameter);
        return outputParameters;
    }
}