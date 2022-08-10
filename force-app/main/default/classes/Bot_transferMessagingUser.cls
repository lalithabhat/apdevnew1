public class Bot_transferMessagingUser {
    public class PrechatInput{
        @InvocableVariable
        public string previousLeadId;//bhs lead
        @InvocableVariable
        public string currentLeadId;//sps lead
    }
    
    public class PrechatOutput{
        @InvocableVariable
        public string MessagingUserId;
    }
    
    @InvocableMethod(label = 'Bot_transferMessagingUser')
    public static List<PrechatOutput> transferMessagingUser(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        String previousLeadId = inputParameters[0].previousLeadId;
        String currentLeadId = inputParameters[0].currentLeadId;
        if(previousLeadId != null && currentLeadId != null){
            Lead pLead = [Select Id, Name, Messaging_User__c From Lead where Id =: previousLeadId];
            Lead cLead = [Select Id, Name, Messaging_User__c From Lead where Id =: currentLeadId];

            System.debug('pLead old'+pLead);            
            System.debug('cLead old'+cLead);            
            cLead.Messaging_User__c = pLead.Messaging_User__c;
            pLead.Messaging_User__c = null;
            update pLead;
            update cLead;
            System.debug('pLead new'+pLead);            
            System.debug('cLead new'+cLead);    
            outputParameter.MessagingUserId = cLead.Messaging_User__c;
        }
        
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}