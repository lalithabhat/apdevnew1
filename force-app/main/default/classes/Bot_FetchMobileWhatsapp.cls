public class Bot_FetchMobileWhatsapp {
    public class PrechatInput{
        @InvocableVariable
        public string ChatKey; // chat key is the context variable for a live chat session in livechattranscript object
        @InvocableVariable
        public String MessagingEndUserId;  // messaging end is the context variable for a messaging session in Messaging Session object.
        @InvocableVariable
        public string MessagingSessionId;
    }
    public class PrechatOutput{
        @InvocableVariable
        public String whatsappNumberWithCode;
        @InvocableVariable
        public String whatsappNumberWithoutCode;
        @InvocableVariable
        public String CountryCode;
        @InvocableVariable
        public String MessagingEndUserId;
    }
    
    @InvocableMethod(label = 'Bot_FetchMobileWhatsapp')
    public static List<PrechatOutput> FetchMobileWhatsapp(List <PrechatInput> inputParameters){
        System.debug('inputParameters : '+inputParameters);
        List <PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        Boolean accountFetched = false;
        
        if(inputParameters != null && inputParameters.size() == 1 ){
            String ChatKey = inputParameters[0].ChatKey;
            String MessagingEndUserId = inputParameters[0].MessagingEndUserId;
            
            if (String.isNotBlank(MessagingEndUserId)) {
                List<MessagingEndUser> meu = [Select Id,Name,MessageType,MessagingChannelId, MessagingPlatformKey 
                                              from MessagingEndUser 
                                              where id =:inputParameters[0].MessagingEndUserId];
                System.debug('meu'+meu);
                
                //List < MessagingSession > ms = [Select Id, EndUserContactId, EndUserAccountId, LeadId from Messagingsession where Id =: inputParameters[0].sMessagingSessionId];
                //System.debug('ms'+ms);
                
                List <String> splitFields = new List <String>();
                splitFields = meu[0].MessagingPlatformKey.split(':');
                
                String whatsappNumberWithCode = splitFields[1]; //meu[0].MessagingPlatformKey.substringAfter('+');
                System.debug('whatsappNumberWithCode'+whatsappNumberWithCode);
                String whatsappNumberWithoutCode = whatsappNumberWithCode.mid(3, 10);
                System.debug('whatsappNumberWithoutCode'+whatsappNumberWithoutCode);
                
                OutputParameter.whatsappNumberWithCode = whatsappNumberWithCode.mid(1, whatsappNumberWithCode.length()-11)+'-'+whatsappNumberWithCode.mid(whatsappNumberWithCode.length()-10,10);
                OutputParameter.whatsappNumberWithoutCode = whatsappNumberWithCode.mid(whatsappNumberWithCode.length()-10,10);
                OutputParameter.CountryCode = whatsappNumberWithCode.mid(1, whatsappNumberWithCode.length()-11);
                OutputParameter.MessagingEndUserId = meu[0].id;
                // +918275404075 length =13
                // 0123456789
            }
        }

        System.Debug('Output parameter for Checking : '+outputParameter);
        outputParameters.add(outputParameter);
        return outputParameters;   
    }    
}