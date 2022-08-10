public class Bot_isSAorCA {
    
    public class PrechatInput{
        @InvocableVariable
        public String LeadId;
    }
    
    public class PrechatOutput{
        @InvocableVariable
        public String isSAorCA;
        @InvocableVariable
        public String contactId;
        @InvocableVariable
        public String dealerId;
        @InvocableVariable
        public String role;
    }
    
    @InvocableMethod(label = 'Bot_isSAorCA')
    public static List<PrechatOutput> isSAorCA(List<PrechatInput> inputParameters){//List<PrechatInput> inputParameters
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String LeadId = inputParameters[0].LeadId;
        
        ScheduleAppointmentServices.UserWrapper uw = Get_SA_Available_Slot.getContactList(LeadId);
        System.debug('## uw : '+uw);
        
        string contactId;
        string role;
        string dealerId;

        if(uw.BU == 'SPS'){ // it means SA is avaialble
            if(!uw.userList.isEmpty()){
                contactId = uw.userList[0].SA__c;
                role = 'SA';
            }
            else{  // find CA
                ScheduleAppointmentServices.CADetailsWrapper cw = Get_SA_Available_Slot.getCAList(LeadId,null);
                System.debug('## cw : '+cw);
                contactId = cw.CA_Contact.Id;
                dealerId = cw.dealer.Id;
                role = 'CA';
            }
        }
        else if(uw.BU == 'BHS'){
            contactId = uw.userList[0].SA__c;
            role = 'BHS';
        }
        
        outputParameter.isSAorCA = role;
        outputParameter.contactId = contactId;
        outputParameter.dealerId = dealerId;
        outputParameter.role = role;
        
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}