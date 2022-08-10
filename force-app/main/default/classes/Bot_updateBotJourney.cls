public class Bot_updateBotJourney {
    public class PrechatInput{
        @InvocableVariable
        public string leadId;
        @InvocableVariable
        public string BotJourneyValue;
    }
    public class PrechatOutput{
        @InvocableVariable
        public Boolean isLeadUpdated = False;
    }
    @InvocableMethod(label = 'Bot_updateBotJourney') 
    public static List<PrechatOutput> updateLead(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String leadId = inputParameters[0].leadId;
        String BotJourneyValue = inputParameters[0].BotJourneyValue;
        if(leadId!= null){
            List<Lead> leadList = [SELECT Id,Name,Email,MobilePhone,Assigned_DateTime__c, Pincode__c, Bot_Journey__c
                                   FROM Lead WHERE id =: leadId];
            System.debug('## leadList old: '+leadList);
            
            if(leadList!= null){
                if(BotJourneyValue != null){
                    leadList[0].Bot_Journey__c = BotJourneyValue;
                    outputParameter.isLeadUpdated = True;
                }
                
                update leadList;
                System.debug('## leadList new: '+leadList);
            }
        }
        
        
        System.debug('#outputParameter : '+outputParameter);
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}