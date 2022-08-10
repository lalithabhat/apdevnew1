public class Bot_BuinessHoursCheck {
    public class PrechatInput {
        @InvocableVariable
        public String sChatKey;      // chat key is the context variable for a live chat session in livechattranscript object
    }
    public class PrechatOutput {
        @InvocableVariable
        public Boolean isWithinBusinessHours;
    }
    @InvocableMethod(label = 'Bot_BuinessHoursCheck')
    public static List < PrechatOutput > BuinessHoursCheck(List < PrechatInput > inputParameters) {
        System.debug('######## Input Parameters: ' + inputParameters);
        Boolean Agent = false;
        List < prechatoutput > outputParameters = new List < prechatoutput > ();
        PrechatOutput outputParameter = new PrechatOutput();
        
        
        // Get the default business hours
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        System.debug('BusinessHours : '+bh);
        
        Datetime targetTime = System.now();
        //Datetime targetTime = Datetime.newInstance(2021, 2, 18, 6, 6, 8); // Create Datetime on feb 18, 2021 at 6:06:08 in the local timezone.
        
        System.debug('targettime : '+targetTime);
        
        Boolean isWithin= BusinessHours.isWithin(bh.id, targetTime);
        
        System.debug('isWithin : '+isWithin);
        outputParameter.isWithinBusinessHours = isWithin;
        outputParameters.add(outputParameter);

        System.debug('outputParameters : '+outputParameters);
        return outputParameters;
    }
}