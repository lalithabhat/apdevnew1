@RestResource(urlMapping='/CrossLead/*')
global class REST_CrossLead_YM {
    @HttpPOST
    global static REST_result checkLead(string originalLeadId, string LOB, string leadRating, string description, boolean WtsSendFlag) {
        REST_result r = new REST_result();
        if(string.isBlank(originalLeadId) || string.isBlank(LOB)){
            r.returnCode = 201;
            r.message = 'Failed: originalLeadId and LOB parameters mandatory';
            r.crmLeadId = null;
            return r;
        }
        List<Lead> lead = new List<Lead>();
        DescribeSObjectResult describeResultLead = Lead.getSObjectType().getDescribe();  
        List<String> fieldNamesLead = new List<String>( describeResultLead.fields.getMap().keySet() );
        String query1 = ' SELECT ' + String.join( fieldNamesLead, ',' ) + ',recordType.Name ' +
            ' FROM ' + describeResultLead.getName() + ' where Id =' + '\'' + originalLeadId + '\'' +
            ' and isConverted = false';
        
        lead = Database.query(query1);
        system.debug('lead::'+lead);
        if(lead != null && !lead.isEmpty()){
            Lead l = lead[0];
            Boolean isLeadExist = ServiceabilityManagement.IsExistingLeadAvailable(l.Pincode__c, LOB, l.MobilePhone);
            system.debug('isLeadExist::'+isLeadExist);
            if(isLeadExist){
                r.returnCode = 203;
                r.message = 'Failed: There is already lead available with the given LOB.';
                r.crmLeadId = null;
                return r;
            }else{
                Boolean isServiceable = ServiceabilityManagement.getLeadServiceableFromBot(l.Pincode__c, LOB);
                if(!isServiceable){
                    r.returnCode = 204;
                    r.message = 'Failed: Given LOB not serviceable';
                    r.crmLeadId = null;
                    return r;
                }else{
                    string msg = ServiceabilityManagement.createCrossLead(l,LOB,leadRating,description,WtsSendFlag);
                    if(msg != 'Failed'){
                        r.returnCode = 200;
                        r.message = 'Success: Lead created';
                        r.crmLeadId = msg;
                        return r;
                    }else{
                        r.returnCode = 205;
                        r.message = 'Lead Creation Failed';
                        r.crmLeadId = null;
                        return r;
                    }
                }
            }
        }else{
            r.returnCode = 202;
            r.message = 'Failed: Original Lead does not exists';
            r.crmLeadId = null;
            return r;
        }
        
    }
    
    global class REST_result {
        webservice Integer returnCode;
        webservice String message;
        webservice String crmLeadId;
    }
    
}