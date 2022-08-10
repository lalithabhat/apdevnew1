@RestResource(urlMapping='/UpdateLeadYM/*')
global class REST_UpdateLead_YM2 {
    @HttpPOST
    global static REST_result updateLead(string crmLeadId,boolean CA_APPOINTMENT, Address addressDetails, List<Questionnaire> questionnair) {
        REST_result r = new REST_result();
        
         if(string.isBlank(crmLeadId)) {
            r.returnCode = 201;
            r.message = 'Failed: crmLeadId is missing';
            return r;
         }
         try {
            //Lead lead = new Lead();
            //lead.Id = crmLeadId;
            Lead lead = ScheduleAppointmentServices.getLead(crmLeadId);
            if(lead != null && lead.Id != null) {
                if(addressDetails != null) {
                    //if(string.isNotBlank(addressDetails.houseNo)){ lead.House__c = addressDetails.houseNo;}
                    //if(string.isNotBlank(addressDetails.floorNo)){ lead.Floor__c = addressDetails.floorNo;}
                    if(string.isNotBlank(addressDetails.street)){ lead.Street = addressDetails.street;}
                    //if(string.isNotBlank(addressDetails.city)){ lead.City = addressDetails.city;}
                    //if(string.isNotBlank(addressDetails.state)){ lead.State = addressDetails.state;}
                    //if(string.isNotBlank(addressDetails.country)){ lead.Country = addressDetails.country;}
                    if(string.isNotBlank(addressDetails.postalCode)) { 
                        lead.PostalCode = addressDetails.postalCode;
                        lead.Pincode__c = addressDetails.postalCode;
                        List<Pincode__c > pincodeRecord = [select id,name,City__c,State__c,Country__c
                                                           from Pincode__c where Name =: addressDetails.postalCode];
                        if(pincodeRecord != null && !pincodeRecord.isEmpty()) {
                            lead.City = pincodeRecord[0].City__c;
                            lead.state = pincodeRecord[0].State__c;
                            lead.country = pincodeRecord[0].Country__c;
                        }
                    }
                }

                if(questionnair != null) {
                    Map<string,string>  LeadFields = new Map<string,string>();
                    String type='Lead';
                    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                    Schema.SObjectType leadSchema = schemaMap.get(type);
                    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
                
                    for (String fieldName: fieldMap.keySet()) {
                        LeadFields.put(fieldMap.get(fieldName).getDescribe().getLabel(),fieldName);
                    }
                    
                    for(Questionnaire qn: questionnair)
                    {
                        //System.debug('Question = '+qn.question);
                        if(qn.question.equalsIgnoreCase('Q4'))
                        {
                            //Initialization
                            lead.Complete_Home_Interiors__c = false;
                            lead.Complete_Modular_Kitchen__c = false;
                            lead.Living_Room_Interior_Design__c = false;
                            lead.Bedroom_Interior_Design__c = false;
                            lead.Other_Home_Areas__c = false;
                            } else if(qn.question.equalsIgnoreCase('Q5'))
                            {
                            lead.At_Home_Consultation__c = false;
                            lead.Online_Consultation__c = false;
                            }
                    }

                    for(Questionnaire q : questionnair) {
                        if(string.isNotBlank(q.question) && string.isNotBlank(q.answer)) {
                            if(LeadFields.containskey(q.question)) {
                                if(q.answer.equalsIgnoreCase('true') || q.answer.equalsIgnoreCase('false')) {
                                    boolean booleanVal = false;
                                    if(q.answer.equalsIgnoreCase('true')) {
                                        booleanVal = true;
                                    }
                                    lead.put(LeadFields.get(q.question),booleanVal);
                                } else {
                                    lead.put(LeadFields.get(q.question),q.answer);
                                }
                                
                            } else if(q.question.equalsIgnoreCase('Q4')) {
                                if(q.answer.equalsIgnoreCase('A1')) {
                                    lead.Complete_Home_Interiors__c = true;
                                } else if(q.answer.equalsIgnoreCase('A2')) {
                                    lead.Complete_Modular_Kitchen__c = true;
                                } else if(q.answer.equalsIgnoreCase('A3')) {
                                    lead.Living_Room_Interior_Design__c = true;
                                } else if(q.answer.equalsIgnoreCase('A4')) {
                                    lead.Bedroom_Interior_Design__c = true;
                                } else if(q.answer.equalsIgnoreCase('A5')) {
                                    lead.Other_Home_Areas__c = true;
                                }
                            }
                            else if(q.question.equalsIgnoreCase('Q5')) {
                                if(q.answer.equalsIgnoreCase('A1')) {
                                    lead.At_Home_Consultation__c = true;
                                } else if(q.answer.equalsIgnoreCase('A2')) {
                                    lead.Online_Consultation__c = true;
                                }
                            }
                        }
                    }
                }  
                if(CA_APPOINTMENT == null) {
                    CA_APPOINTMENT = false;
                }
                if(CA_APPOINTMENT) {
                    Set<String> skillSet = new Set<String>();
                    if(lead.Skills__c != null){
                        skillSet.addAll(lead.Skills__c.split(';'));
                    }
                    Map<Id, DealerManagementServices.CADetailWrapper> CADetails = DealerManagementServices.getCAInfo(lead.Pincode__c, skillSet, null); 
                    system.debug('CADetails:: '+CADetails);
                    if(CADetails != null && !CADetails.isEmpty()) {
                        for(Id key : CADetails.keySet()) {
                            lead.OwnerId = CADetails.get(key).CA.Id;
                            lead.Dealer__c = CADetails.get(key).Dealer.Id;
                        }
                    }
                    lead.Bot_Journey__c = 'Responded-CA Lead';
                    lead.Status = 'Allocation Done';
                }
                
                update lead;
                r.returnCode = 200;
                r.message = 'Success: Lead updated!';
                return r;
            } else {
                r.returnCode = 203;
                r.message = 'Failed: Lead Record not found' ;
                return r;
            }
         } catch(exception ex) {
             system.debug('Exception:: '+ex.getMessage());
             r.returnCode = 202;
             r.message = 'Failed: ' + ex.getMessage();
             return r;
         }
         
         //return null;       
    }
    
    global class REST_result {
        webservice Integer returnCode;
        webservice String message;
    }

    global class Address {
        //webservice string houseNo;
        //webservice String floorNo;
        webservice string street;
        //webservice String city;
        //webservice string state;
        //webservice String country;
        webservice string postalCode;
    } 

    global class Questionnaire {
        webservice string question;
        webservice string answer;

        public Questionnaire() {
            
        }
    }
}