public class Bot_isQualified {
    public class PrechatInput{
        @InvocableVariable
        public string leadId;        
    }
    public class PrechatOutput{
        @InvocableVariable
        public Boolean isQualified = False;
    }
    @InvocableMethod(label = 'Bot_isQualified') 
    public static List<PrechatOutput> isQualified(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String leadId = inputParameters[0].leadId;
        List<Lead> leadList = [SELECT Id,Name,Email,MobilePhone,Assigned_DateTime__c, Pincode__c,
                               Whatsapp_Notification__c,Address,What_is_the_timeline_for_painting__c,
                               Is_construction_work_going_on__c,House__c,Street,
                               InteriorOrPainting__c, Type_of_place__c,Qualification_Status__c
                               FROM Lead WHERE id =: leadId];
        
        if(leadList.size() > 0 && leadList[0].Qualification_Status__c == 'Qualified'){
            outputParameter.isQualified = True;
        }
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}