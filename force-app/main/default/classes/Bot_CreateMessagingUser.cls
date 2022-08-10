public class Bot_CreateMessagingUser {
    public class PrechatInput{
        @InvocableVariable
        public string leadId;
    }
    public class PrechatOutput{
        @InvocableVariable
        public string MessagingUserId;
    }
    
    @InvocableMethod(label = 'Bot_CreateMessagingUser') 
    public static List<PrechatOutput> CreateMessagingUser(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String leadId = inputParameters[0].leadId;
        
        List<MessagingEndUser> messageuserList = New List<MessagingEndUser>();
        MessagingEndUser messageuser = new MessagingEndUser();
        List<MessagingEndUser> MsgU = new List<MessagingEndUser>();
        
        Lead l = [SELECT Id,Name,MobilePhone FROM Lead WHERE Id=:LeadId];
        
        if(l != NULL){
            
            messageuserList=[select id, Accountid,Name,IsFullyOptedIn,MessagingConsentStatus 
                             from MessagingEndUser where Lead__c=: l.Id AND IsFullyOptedIn = True];
            if(messageuserList != NULL && messageuserList.size()>0){
                System.debug('User Lead Already Exists');
                String Mesg = 'User Lead Already Exists';
                outputParameter.MessagingUserId = messageuserList[0].id;
            }
            else{
                MsgU = [SELECT Id,Name FROM MessagingEndUser WHERE MessagingPlatformKey =: 'whatsapp:+91'+lead.MobilePhone];
                system.debug('MsgU : ' +MsgU);
                if(MsgU != NULL && MsgU.size()>0){
                    MsgU[0].MessagingConsentStatus = 'ExplicitlyOptedIn';
                    update MsgU;
                    system.debug('MsgU : ' +MsgU);
                    outputParameter.MessagingUserId = MsgU[0].id;
                }
                else{
                    messageuser.Name = l.Name;
                    messageuser.Lead__c = l.id;
                    messageuser.MessagingPlatformKey = 'whatsapp:+91'+l.MobilePhone ;messageuser.MessageType = 'Whatsapp';
                    messageuser.MessagingChannelId = '0Mj8n0000000001CAA'; // Sandbox = 0Mj720000000001CAA Production = 0Mj8n0000000001CAA
                    messageuser.MessagingConsentStatus = 'ExplicitlyOptedIn';
                    insert messageuser;    
                    system.debug('messageuser : ' +messageuser);
                    outputParameter.MessagingUserId = messageuser.Id;
                }
            }
        } 
        System.debug('#outputParameter : '+outputParameter);
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}