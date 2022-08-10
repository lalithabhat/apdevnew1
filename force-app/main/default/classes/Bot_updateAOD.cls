public class Bot_updateAOD {
    
    public class PrechatInput{
        @InvocableVariable
        public Id leadId;
    }
    public class PrechatOutput{
        @InvocableVariable
        public string message;
    }
    @InvocableMethod(label = 'Bot_updateAOD')
    public static List<PrechatOutput> updateAOD(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String leadId = inputParameters[0].leadId;
        List<Lead> leadList = [SELECT Id, Name, Pincode__c, MobilePhone, Email, CampaignName__c,Process_Type__c,AOD_Master__c
                               From Lead
                               Where Id =: leadId
                               ORDER BY CreatedDate DESC];
        System.debug('##leadList : '+leadList);
        try{
            if(leadList != null && leadList.size() > 0){
                Map<Lead, AOD_Master__c> returnMap = LeadManagementServices.getServiceId(leadList);
                outputParameter.message = String.valueOf(returnMap);
                System.debug('##returnMap : '+returnMap);
                leadList[0].AOD_Master__c = returnMap.get(leadList[0]).Id;
                update leadList[0];
            }    
        }
        catch(exception e){
            outputParameter.message = 'Lead Id - '+'. Exception Details - '+e;
        }
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}