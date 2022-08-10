@RestResource(urlMapping='/FetchLead/*')
global class REST_FetchLeadDetails_YM {
    @HttpPOST
    global static REST_result LeadDetails(string CRMLeadID) {
        REST_result r = new REST_result();
        try {
            List<Lead> lead = new List<Lead>();
            DescribeSObjectResult describeResultLead = Lead.getSObjectType().getDescribe();  
            List<String> fieldNamesLead = new List<String>( describeResultLead.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesLead, ',' ) + ',recordType.Name ' +
                ' FROM ' + describeResultLead.getName() + ' where Id =' + '\'' + CRMLeadID + '\'' +
                ' and isConverted = false';
            
            lead = Database.query(query1);
            system.debug('lead::'+lead);
            if(!lead.isEmpty()){
                Lead l = lead[0];
                r.address = '';
                r.returnCode = 200;
                r.message = 'Success';
                r.firstName = l.FirstName;
                r.lastName = l.lastName;
                r.pincode = l.Pincode__c;
                if(l.House__c != null)
                	r.address = l.House__c + ', ';
                if(l.Floor__c != null)
                	r.address += l.Floor__c + ', ';
                if(l.street != null)
                	r.address += l.street + ', ';
                if(l.City != null)
                	r.address += l.City + ', ';
                if(l.State != null)
                	r.address += l.State + ', ';
                if(l.Country != null)
                	r.address += l.Country + ', ';
                r.recordType = l.recordType.Name;
                r.status = l.status;
                r.mobilePhone = l.mobilePhone;
                r.emailAddress = l.Email;
                r.campaignId = l.YM_Campaign_Code__c;
                if(l.Last_Appointment_Start_Date_Time__c != null){
                    r.appointmentStart = l.Last_Appointment_Start_Date_Time__c.format();
                }
                if(l.Last_Appointment_End_Date_Time__c != null){
                    r.appointmentEnd = l.Last_Appointment_End_Date_Time__c.format();
                }
                r.whatsappconsent = '';
                r.leadScore = '';
                return r;
            }else{
                r.returnCode = 201;
                r.message = 'Failed: Lead record does not exists';
                return r;
            }
        } catch (Exception e) {
            r.returnCode = 201;
            r.message = 'Failed: ' + e.getMessage();
            return r;
        }
     	//return null;   
    }
    
    global class REST_result {
        webservice Integer returnCode;
        webservice String message;
        webservice String firstName;
        webservice String lastName;
        webservice String pincode;
        webservice String address;
        webservice String recordType;
        webservice String status;
        webservice String mobilePhone;
        webservice String emailAddress;
        webservice String campaignId;
        webservice String appointmentStart;
        webservice String appointmentEnd;
        webservice String whatsappconsent;
        webservice String leadScore;
    }
}