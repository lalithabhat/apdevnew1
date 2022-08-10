public class Bot_Multiselect {
    public class PrechatInput{
        @InvocableVariable
        public string InputString;
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
    }
    public class PrechatOutput{
        @InvocableVariable
        public String OptionSelected;
        @InvocableVariable
        public String ValueToPassToMultiPickList;
        @InvocableVariable
        public String Message;
    }
    @InvocableMethod(label = 'Bot_Multiselect')
    public static List<PrechatOutput> Multiselect(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String Option1 = inputParameters[0].Option1;
        String Option2 = inputParameters[0].Option2;
        String Option3 = inputParameters[0].Option3;
        String Option4 = inputParameters[0].Option4;
        String Option5 = inputParameters[0].Option5;
        String Option6 = inputParameters[0].Option6;
        String Option7 = inputParameters[0].Option7;
        String InputString = inputParameters[0].InputString;
        
        try{
            if(Option1 != null && Option1.length() > 0 && InputString.contains('1')){
                outputParameter.OptionSelected = Option1;
                outputParameter.ValueToPassToMultiPickList = Option1;
            }
            if(Option2 != null && Option2.length() > 0 && InputString.contains('2')){
                outputParameter.OptionSelected = outputParameter.OptionSelected + ', ' + Option2;
                outputParameter.ValueToPassToMultiPickList = outputParameter.ValueToPassToMultiPickList + ';' + Option2;
            }
            if(Option3 != null && Option3.length() > 0 && InputString.contains('3')){
                outputParameter.OptionSelected = outputParameter.OptionSelected + ', ' + Option3;
                outputParameter.ValueToPassToMultiPickList = outputParameter.ValueToPassToMultiPickList + ';' + Option3;
            }
            if(Option4 != null && Option4.length() > 0 && InputString.contains('4')){
                outputParameter.OptionSelected = outputParameter.OptionSelected + ', ' + Option4;
                outputParameter.ValueToPassToMultiPickList = outputParameter.ValueToPassToMultiPickList + ';' + Option4;
            }
            if(Option5 != null && Option5.length() > 0 && InputString.contains('5')){
                outputParameter.OptionSelected = outputParameter.OptionSelected + ', ' + Option5;
                outputParameter.ValueToPassToMultiPickList = outputParameter.ValueToPassToMultiPickList + ';' + Option5;
            }
            if(Option6 != null && Option6.length() > 0 && InputString.contains('6')){
                outputParameter.OptionSelected = outputParameter.OptionSelected + ', ' + Option6;
                outputParameter.ValueToPassToMultiPickList = outputParameter.ValueToPassToMultiPickList + ';' + Option6;
            }
            if(Option7 != null && Option7.length() > 0 && InputString.contains('7')){
                outputParameter.OptionSelected = outputParameter.OptionSelected + ', ' + Option7;
                outputParameter.ValueToPassToMultiPickList = Option7;      
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