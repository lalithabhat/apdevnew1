public class Bot_getContactDetails {

    public class PrechatInput{
        @InvocableVariable
        public Id ContactId;
    }
    public class PrechatOutput{
        @InvocableVariable
        public String outContactId;
        @InvocableVariable
        public string outName;
        @InvocableVariable
        public string outMobile;
        @InvocableVariable
        public string outEmail;
        @InvocableVariable
        public string outPincode;
    }
    @InvocableMethod(label = 'Bot_getContactDetails')
    public static List<PrechatOutput> getContactDetails(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String ContactId = inputParameters[0].ContactId;
        
        List<Contact> contactList = [SELECT Id, Name, Pincode__c, MobilePhone, Email, isBot__c, X10_Digit_Mobile__c, X6_Digit_Pincode__c
                                     From Contact
                                     Where Id =: ContactId
                                     ORDER BY CreatedDate DESC];
        System.debug('##contactList : '+contactList);
        contactList[0].isBot__c = True;
        update contactList;
        System.debug('##contactList after update: '+contactList);
        if(contactList != null && contactList.size() > 0){
            outputParameter.outName = contactList[0].Name;
            outputParameter.outMobile = contactList[0].X10_Digit_Mobile__c;
            outputParameter.outEmail = contactList[0].Email;
            outputParameter.outPincode = contactList[0].X6_Digit_Pincode__c;
        }
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}