public class Bot_updateLead {
    public class PrechatInput{
        @InvocableVariable
        public string leadId;
        @InvocableVariable
        public string isWorkPlanningPending;
        @InvocableVariable
        public string whenToStartWork;
        @InvocableVariable
        public string fullAdress;
        @InvocableVariable
        public string landmark;
        @InvocableVariable
        public string spsRating;
        @InvocableVariable
        public string idsInteriorOrPainting; 
        @InvocableVariable
        public string idsDesignArea; 
        @InvocableVariable
        public string idsDesignComponents;
        @InvocableVariable
        public string idsTypeOfPlace;
        @InvocableVariable
        public string WhatsappOptin;
        @InvocableVariable
        public string option1BHS;
        @InvocableVariable
        public string option2BHS;
        @InvocableVariable
        public string option4BHS;
        @InvocableVariable
        public string option3BHS;
        @InvocableVariable
        public string option5BHS;
        @InvocableVariable
        public string clearDesignComponents;
    }
    public class PrechatOutput{
        @InvocableVariable
        public Boolean isLeadUpdated = False;
        @InvocableVariable
        public Boolean isWorkPlanningPendingUpdated = False;
        @InvocableVariable
        public Boolean iswhenToStartWorkUpdated = False;
        @InvocableVariable
        public Boolean isfullAdressUpdated = False;
        @InvocableVariable
        public Boolean islandmarkUpdated = False;
        @InvocableVariable
        public Boolean isspsRatingUpdated = False;
        @InvocableVariable
        public Boolean isidsInteriorOrPaintingUpdated = False;
        @InvocableVariable
        public Boolean isidsTypeOfPlaceUpdated = False;
        @InvocableVariable
        public Boolean isidsDesignAreaUpdated = False;
        @InvocableVariable
        public Boolean isidsDesignComponentsUpdated = False;
        @InvocableVariable
        public Boolean isWhatsappOptinUpdated = False;
        @InvocableVariable
        public String Message;
    }
    @InvocableMethod(label = 'Bot_updateLead') 
    public static List<PrechatOutput> updateLead(List<PrechatInput> inputParameters){
        List<PrechatOutput> outputParameters = new List<PrechatOutput>();
        PrechatOutput outputParameter = new PrechatOutput();
        
        String leadId = inputParameters[0].leadId;
        
        String WhatsappOptin = inputParameters[0].WhatsappOptin;
        
        String isWorkPlanningPending = inputParameters[0].isWorkPlanningPending; //For SPS
        String whenToStartWork = inputParameters[0].whenToStartWork; //For SPS
        String fullAdress = inputParameters[0].fullAdress; //For SPS
        String landmark = inputParameters[0].landmark; //For SPS
        String spsRating = inputParameters[0].spsRating; //For SPS
        
        String idsInteriorOrPainting = inputParameters[0].idsInteriorOrPainting; //For BHS
        String idsTypeOfPlace = inputParameters[0].idsTypeOfPlace; //For BHS
        String idsDesignArea = inputParameters[0].idsDesignArea; //For BHS
        String idsDesignComponents = inputParameters[0].idsDesignComponents; //For BHS
        
        String option1BHS = inputParameters[0].option1BHS; //For BHS
        String option2BHS = inputParameters[0].option2BHS; //For BHS
        String option3BHS = inputParameters[0].option3BHS; //For BHS
        String option4BHS = inputParameters[0].option4BHS; //For BHS
        String option5BHS = inputParameters[0].option5BHS; //For BHS
        String clearDesignComponents = inputParameters[0].clearDesignComponents; //For BHS
        System.debug('## inputParameters: '+inputParameters);
        
        List<Lead> leadList = [SELECT Id,Name,Email,MobilePhone,Assigned_DateTime__c, Pincode__c,
                               Whatsapp_Notification__c,Address,What_is_the_timeline_for_painting__c,
                               Is_construction_work_going_on__c,House__c,Street,
                               InteriorOrPainting__c, Type_of_place__c
                               FROM Lead WHERE id =: leadId]; //Service__c
        System.debug('## leadList old: '+leadList);
        
        if(leadList.size() > 0 && leadList[0].Whatsapp_Notification__c == False && WhatsappOptin == 'Yes'){
            leadList[0].Whatsapp_Notification__c = True;
            outputParameter.isWhatsappOptinUpdated = True;
            outputParameter.isLeadUpdated = True;
        }
        
        else if(leadList.size() > 0 && leadList[0].Whatsapp_Notification__c == True && WhatsappOptin == 'No'){
            leadList[0].Whatsapp_Notification__c = False;
            outputParameter.isWhatsappOptinUpdated = True;
            outputParameter.isLeadUpdated = True;
        }
        
        if(leadList!= null){
            if(isWorkPlanningPending != null){
                if(isWorkPlanningPending == 'Not Sure'){
                    leadList[0].Is_construction_work_going_on__c = 'No';
                }
                else{
                leadList[0].Is_construction_work_going_on__c = isWorkPlanningPending;
                }
                outputParameter.isWorkPlanningPendingUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            else if(whenToStartWork != null){
                leadList[0].What_is_the_timeline_for_painting__c = whenToStartWork;
                outputParameter.iswhenToStartWorkUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            else if(fullAdress != null && landmark != null){
                leadList[0].Street = fullAdress +', '+landmark;
                outputParameter.isfullAdressUpdated = True;
                outputParameter.islandmarkUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            else if(fullAdress != null){
                leadList[0].Street = fullAdress;
                outputParameter.isfullAdressUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            else if(spsRating != null){
                leadList[0].Rating = spsRating;
                outputParameter.isspsRatingUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            
            else if(idsInteriorOrPainting != null){
                leadList[0].InteriorOrPainting__c = idsInteriorOrPainting;
                outputParameter.isidsInteriorOrPaintingUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            else if(idsTypeOfPlace != null){
                leadList[0].Type_of_place__c = idsTypeOfPlace;
                outputParameter.isidsTypeOfPlaceUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            
            System.debug('##idsDesignComponents : '+idsDesignComponents);
            if(idsDesignComponents != null){
                if(idsDesignComponents.contains('null;')){
                    idsDesignComponents = idsDesignComponents.remove('null;');
                }
            }
            System.debug('##idsDesignComponents : '+idsDesignComponents);
            if(option1BHS != null){    
                leadList[0].Bedroom_Interior_Design__c = True;
                if(idsDesignComponents.contains('Complete Bedroom Interior Design')){
                    leadList[0].Bedroom_Interior_Design_Components__c = 'Bed;Side Table;Wardrobe;False ceiling;Walk-in-closet;Furnishings';
                }
                else{
                    leadList[0].Bedroom_Interior_Design_Components__c = idsDesignComponents;
                }
                outputParameter.isidsDesignComponentsUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            if(option2BHS != null){
                leadList[0].Living_Room_Interior_Design__c = True;
                if(idsDesignComponents.contains('Complete Living Room Interior Design')){
                    leadList[0].Living_Room_Interior_Design_Components__c = 'Sofa;TV. Cabinet;Shoe Rack;Dining Table;Centre Table;False Ceiling';
                }
                else{
                    leadList[0].Living_Room_Interior_Design_Components__c = idsDesignComponents;
                }
                outputParameter.isidsDesignComponentsUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            if(option3BHS != null){
                leadList[0].Complete_Modular_Kitchen__c = True;
                outputParameter.isidsDesignComponentsUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            if(option4BHS != null){
                leadList[0].Other_Home_Areas__c = True;
                leadList[0].Other_Home_Areas_Components__c = idsDesignComponents;
                outputParameter.isidsDesignComponentsUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            if(option5BHS != null){
                leadList[0].Complete_Home_Interiors__c = True;
                outputParameter.isidsDesignComponentsUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            if(clearDesignComponents != null){
                leadList[0].Bedroom_Interior_Design__c = False;
                leadList[0].Living_Room_Interior_Design__c = False;
                leadList[0].Other_Home_Areas__c = False;
                leadList[0].Complete_Modular_Kitchen__c= False;
                leadList[0].Complete_Home_Interiors__c= False;
                leadList[0].Bedroom_Interior_Design_Components__c = '';
                leadList[0].Living_Room_Interior_Design_Components__c = '';
                leadList[0].Other_Home_Areas_Components__c = '';
                outputParameter.isidsDesignComponentsUpdated = True;
                outputParameter.isLeadUpdated = True;
            }
            update leadList;
            System.debug('## leadList new: '+leadList);
        }
        
        System.debug('#outputParameter : '+outputParameter);
        outputParameters.add(outputParameter);
        System.debug('##outputParameters : '+outputParameters);
        return outputParameters;
    }
}