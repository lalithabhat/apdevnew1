public class Bot_DateValidation {
    public class PrechatInput{
        @InvocableVariable
        public string sDate;
    }
    public class PrechatOutput{
        @InvocableVariable
        public Boolean isDateVerified;
        @InvocableVariable
        public String Message;
    }
    @InvocableMethod(label = 'Bot_DateValidation')
    public static List<PrechatOutput> DateValidation(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        try{
            String sDate = inputParameters[0].sDate;
            Date dDate = Date.parse(inputParameters[0].sDate);
            Boolean isDateVerified = False;
            if(dDate < Date.today()){
                isDateVerified = False;
                outputParameter.Message = 'Date is less';
            }
            else if(dDate >= Date.today()){
                isDateVerified = True;
                outputParameter.Message = 'Date is ok';
            }
            else{
                outputParameter.Message = 'Date is not ok';
            }
            outputParameter.isDateVerified = isDateVerified;
        }
        catch(Exception e){
            outputParameter.Message = e.getMessage();
            outputParameter.isDateVerified = False;
        }
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}