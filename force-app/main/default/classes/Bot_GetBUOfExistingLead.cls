public class Bot_GetBUOfExistingLead {
    public class PrechatInput{
        @InvocableVariable
        public String leadId;
    }
    public class PrechatOutput{
        @InvocableVariable
        public String ExistingLeadBU;
    }
    @InvocableMethod(label = 'Bot_GetBUOfExistingLead') 
    public static List<PrechatOutput> GetBUOfExistingLead(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String leadId = inputParameters[0].leadId;
        if(leadId != null){
            List<Lead> leadList = [SELECT Id,Name,Email,MobilePhone,Assigned_DateTime__c, Pincode__c, Bot_Journey__c,Skills__c
                                   FROM Lead WHERE id =: leadId];
            System.debug('## leadList old: '+leadList);  
            
            if(leadList!= null){
                outputParameter.ExistingLeadBU = leadList[0].Skills__c;
            }
        }
        System.debug('#outputParameter : '+outputParameter);
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}