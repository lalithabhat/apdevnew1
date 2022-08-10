@RestResource(urlMapping='/UpdateLead/*')
global class REST_UpdateLead {
    @HttpPOST                                          //sales amount string added by Saransh 
    global static REST_result LeadDetails(string CRMLeadID, string status, string currentOwner, string currentOwnerName, string currentOwnerEmail, string currentOwnerEmpId, string currentOwnerMobile, string dateofDesignSharing, string ERPB1Id, string dropReason, string comments,string salesAmount) {
        REST_result r = new REST_result();
        if(string.isBlank(CRMLeadId)){
            r.returnCode = 201;
            r.message = 'CRMLeadID is missing';
            r.CRMleadId = null;
            return r;
        }else if(string.isBlank(status)){
            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
            if(isEnabled[0].Enable_Logs__c){
                System_Log__c SL = new System_Log__c();
                if(CRMLeadID.startsWith('00Q'))
                	SL.Lead__c = CRMLeadID;
                else if(CRMLeadID.startsWith('006'))
                	SL.Opportunity__c = CRMLeadID;
                SL.API_Name__c  = 'Lead Update API';
                SL.Request__c = 'Request Parameters:: ' + '\n' +
                    'CRMLeadID: '+ CRMLeadID + '\n' +
                    'status: '+ status + '\n' +
                    'currentOwner: '+ currentOwner + '\n' +
                	'currentOwnerName: '+ currentOwnerName + '\n' +
                	'currentOwnerEmail: '+ currentOwnerEmail + '\n' +
                	'currentOwnerEmpId: '+ currentOwnerEmpId + '\n' +
                	'currentOwnerMobile: '+ currentOwnerMobile + '\n' +
                	'dateofDesignSharing: '+ dateofDesignSharing + '\n' +
                	'ERPB1Id: '+ ERPB1Id + '\n' +
                	'dropReason: '+ dropReason + '\n' +
                    'comments: ' + comments + '\n'+
                    'salesAmount: ' + salesAmount + '\n';//sales amount -new addition
                SL.Response__c = 'Failed: Can not proceed, status parameter is blank';
                SL.Success__c = false;
                insert SL;
            }
            r.returnCode = 201;
            r.message = 'Can not proceed, status parameter is blank';
            r.CRMleadId = CRMLeadID;
            return r;
        }else if(string.isBlank(currentOwner)){
            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
            if(isEnabled[0].Enable_Logs__c){
                System_Log__c SL = new System_Log__c();
                if(CRMLeadID.startsWith('00Q'))
                	SL.Lead__c = CRMLeadID;
                else if(CRMLeadID.startsWith('006'))
                	SL.Opportunity__c = CRMLeadID;
                SL.API_Name__c  = 'Lead Update API';
                SL.Request__c = 'Request Parameters:: ' + '\n' +
                    'CRMLeadID: '+ CRMLeadID + '\n' +
                    'status: '+ status + '\n' +
                    'currentOwner: '+ currentOwner + '\n' +
                	'currentOwnerName: '+ currentOwnerName + '\n' +
                	'currentOwnerEmail: '+ currentOwnerEmail + '\n' +
                	'currentOwnerEmpId: '+ currentOwnerEmpId + '\n' +
                	'currentOwnerMobile: '+ currentOwnerMobile + '\n' +
                	'dateofDesignSharing: '+ dateofDesignSharing + '\n' +
                	'ERPB1Id: '+ ERPB1Id + '\n' +
                	'dropReason: '+ dropReason + '\n' +
                	'comments: ' + comments + '\n'+
                     'salesAmount: ' + salesAmount + '\n';//sales amount -new addition
                SL.Response__c = 'Failed: CurrentOwner Parameter is missing';
                SL.Success__c = false;
                insert SL;
            }
            r.returnCode = 201;
            r.message = 'CurrentOwner Parameter is missing';
            r.CRMleadId = CRMLeadID;
            return r;
        }
        else if(string.isBlank(currentOwnerEmpId)){
            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
            if(isEnabled[0].Enable_Logs__c){
                System_Log__c SL = new System_Log__c();
                if(CRMLeadID.startsWith('00Q'))
                	SL.Lead__c = CRMLeadID;
                else if(CRMLeadID.startsWith('006'))
                	SL.Opportunity__c = CRMLeadID;
                SL.API_Name__c  = 'Lead Update API';
                SL.Request__c = 'Request Parameters:: ' + '\n' +
                    'CRMLeadID: '+ CRMLeadID + '\n' +
                    'status: '+ status + '\n' +
                    'currentOwner: '+ currentOwner + '\n' +
                	'currentOwnerName: '+ currentOwnerName + '\n' +
                	'currentOwnerEmail: '+ currentOwnerEmail + '\n' +
                	'currentOwnerEmpId: '+ currentOwnerEmpId + '\n' +
                	'currentOwnerMobile: '+ currentOwnerMobile + '\n' +
                	'dateofDesignSharing: '+ dateofDesignSharing + '\n' +
                	'ERPB1Id: '+ ERPB1Id + '\n' +
                	'dropReason: '+ dropReason + '\n' +
                    'comments: ' + comments + '\n'+
                    'salesAmount: ' + salesAmount + '\n';//sales amount -new addition
                SL.Response__c = 'Failed: currentOwnerEmpId Parameter is missing';
                SL.Success__c = false;
                insert SL;
            }
            r.returnCode = 201;
            r.message = 'currentOwnerEmpId Parameter is missing';
            r.CRMleadId = CRMLeadID;
            return r;
        }
        else{
            try{
                List<Opportunity> oppRecord = new List<Opportunity>();
                List<Lead> lead = new List<Lead>();
                lead = APIMangementServices.getLeadRecord(CRMLeadID);
                List<User> user = APIMangementServices.getUserFrom_PositionId(currentOwner);
                
                if(lead != null && !lead.isEmpty()){
                    if(!status.equalsIgnoreCase('Converted') && !status.equalsIgnoreCase('BOOK_KITCHEN')){
                        if(user != null && !user.isEmpty()){
                            lead[0].ownerId = user[0].Id;
                        } else {
                            lead[0].Current_Owner_PositionID__c = currentOwner;
                        }
                        lead[0].Status_From_API__c = status;
                        lead[0].LastModifiedTime__c = system.now();
                        lead[0].Current_Owner_Employee_Id__c = currentOwnerEmpId;
                        lead[0].Current_Owner_Name__c = currentOwnerName;
                        lead[0].Current_Owner_Mobile__c = currentOwnerMobile;
                        lead[0].Current_Owner_Email__c = currentOwnerEmail;
                        if(!String.isBlank(dateofDesignSharing))
                        	lead[0].Date_of_Design_Sharing__c = date.parse(dateofDesignSharing);
                        lead[0].ERP_B1_Id__c = ERPB1Id;
                        if(status.equalsIgnoreCase('Drop') || status.equalsIgnoreCase('Dropped')) {
                            lead[0].Status = 'Lost';
                        	lead[0].Drop_Lead_Reason__c = dropReason;
                        }
                        if(!String.isBlank(comments)) 
                            lead[0].External_System_Update__c += '\n' + system.now().format() + ' : ' + comments;
                        //sales amount newly added----------------------------------//
                        if(!String.isBlank(salesAmount)){
                              lead[0].Sales_Amount__c=double.valueOf(salesAmount);
                        }      
						//------------------------------------------------------------//
                        update lead;
                        
                        List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                        if(isEnabled[0].Enable_Logs__c){
                            System_Log__c SL = new System_Log__c();
                            SL.Lead__c = lead[0].Id;
                            SL.API_Name__c  = 'Lead Update API';
                            SL.Request__c = 'Request Parameters:: ' + '\n' +
                                            'CRMLeadID: '+ CRMLeadID + '\n' +
                                            'status: '+ status + '\n' +
                                            'currentOwner: '+ currentOwner + '\n' +
                                            'currentOwnerName: '+ currentOwnerName + '\n' +
                                            'currentOwnerEmail: '+ currentOwnerEmail + '\n' +
                                            'currentOwnerEmpId: '+ currentOwnerEmpId + '\n' +
                                            'currentOwnerMobile: '+ currentOwnerMobile + '\n' +
                                            'dateofDesignSharing: '+ dateofDesignSharing + '\n' +
                                            'ERPB1Id: '+ ERPB1Id + '\n' +
                                            'dropReason: '+ dropReason + '\n' +
                                			'comments: ' + comments + '\n'+
                                            'salesAmount: ' + salesAmount + '\n';//sales amount -new addition
                            SL.Response__c = 'Lead Updated Succesfully';
                            SL.Success__c = true;
                            insert SL;
                        }
                        r.returnCode = 200;
                        r.message = 'Record Updated Succesfully';
                        r.CRMleadId = CRMleadId;
                        return r;
                    }else{
                        system.debug('Inside Lead Conversion');
                        oppRecord = APIMangementServices.convertLead(lead[0]);
                    }
                }else{
                    system.debug('Inside NO Lead ');
                    oppRecord = APIMangementServices.getOpportunityRecord(CRMLeadID);
                }
                system.debug('oppRecord::'+oppRecord);
                if(oppRecord != null && !oppRecord.isEmpty()){
                    system.debug('Inside Opportunity');
                    if(user != null && !user.isEmpty()){
                        oppRecord[0].ownerId = user[0].Id;
                    }else{
                        oppRecord[0].Current_Owner_PositionID__c = currentOwner;
                    }
                    if(status.equalsIgnoreCase('Converted'))
                    	oppRecord[0].StageName = 'Design';
                    else
                        oppRecord[0].StageName = status;
                    oppRecord[0].Status_From_API__c = status;
                    oppRecord[0].LastModifiedTime__c = system.now();
                    oppRecord[0].Current_Owner_Employee_Id__c = currentOwnerEmpId;
                    oppRecord[0].Current_Owner_Name__c = currentOwnerName;
                    oppRecord[0].Current_Owner_Mobile__c = currentOwnerMobile;
                    oppRecord[0].Current_Owner_Email__c = currentOwnerEmail;
                    if(!String.isBlank(dateofDesignSharing))
                    	oppRecord[0].Date_of_Design_Sharing__c = date.parse(dateofDesignSharing);
                    oppRecord[0].ERP_B1_Id__c = ERPB1Id;
                    oppRecord[0].Loss_Reason__c = dropReason;
                    if(!String.isBlank(comments)) {
                        if(!String.isBlank(oppRecord[0].External_System_Update__c))
                            oppRecord[0].External_System_Update__c = system.now().format() + ' : ' + comments;
                        else
                            oppRecord[0].External_System_Update__c = oppRecord[0].External_System_Update__c + '\n' + system.now().format() + ' : ' + comments;
                    }
                         //sales amount newly added----------------------------------//
                    if(!String.isBlank(salesAmount)){
                        oppRecord[0].Sales_Amount__c=double.valueOf(salesAmount);
                    }        
						//------------------------------------------------------------//
                    update oppRecord;
                    
                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                    if(isEnabled[0].Enable_Logs__c){
                        System_Log__c SL = new System_Log__c();
                        SL.Opportunity__c = oppRecord[0].Id;
                        SL.API_Name__c  = 'Lead Update API';
                        SL.Request__c = 'Request Parameters:: ' + '\n' +
                            'CRMLeadID: '+ CRMLeadID + '\n' +
                            'status: '+ status + '\n' +
                            'currentOwner: '+ currentOwner + '\n' +
                            'currentOwnerName: '+ currentOwnerName + '\n' +
                            'currentOwnerEmail: '+ currentOwnerEmail + '\n' +
                            'currentOwnerEmpId: '+ currentOwnerEmpId + '\n' +
                            'currentOwnerMobile: '+ currentOwnerMobile + '\n' +
                            'dateofDesignSharing: '+ dateofDesignSharing + '\n' +
                            'ERPB1Id: '+ ERPB1Id + '\n' +
                            'dropReason: '+ dropReason + '\n' +
                            'comments: ' + comments + '\n'+
                            'salesAmount: ' + salesAmount + '\n';//sales amount -new addition
                        SL.Response__c = 'Opportunity Updated Succesfully';
                        SL.Success__c = true;
                        insert SL;
                    }
                    r.returnCode = 200;
                    r.message = 'Record Updated Succesfully';
                    r.CRMleadId = CRMleadId;
                    return r;
                }
                if(lead.isEmpty() && oppRecord.isEmpty()){
                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                    if(isEnabled[0].Enable_Logs__c){
                        System_Log__c SL = new System_Log__c();
                        if(CRMLeadID.startsWith('00Q'))
                            SL.Lead__c = CRMLeadID;
                        else if(CRMLeadID.startsWith('006'))
                            SL.Opportunity__c = CRMLeadID;
                        SL.API_Name__c  = 'Lead Update API';
                        SL.Request__c = 'Request Parameters:: ' + '\n' +
                            'CRMLeadID: '+ CRMLeadID + '\n' +
                            'status: '+ status + '\n' +
                            'currentOwner: '+ currentOwner + '\n' +
                            'currentOwnerName: '+ currentOwnerName + '\n' +
                            'currentOwnerEmail: '+ currentOwnerEmail + '\n' +
                            'currentOwnerEmpId: '+ currentOwnerEmpId + '\n' +
                            'currentOwnerMobile: '+ currentOwnerMobile + '\n' +
                            'dateofDesignSharing: '+ dateofDesignSharing + '\n' +
                            'ERPB1Id: '+ ERPB1Id + '\n' +
                            'dropReason: '+ dropReason + '\n' +
                            'comments: ' + comments + '\n'+
                            'salesAmount: ' + salesAmount + '\n';//sales amount -new addition
                        SL.Response__c = 'No Reord found or Lead conversion error occurred';
                        SL.Success__c = false;
                        insert SL;
                    }
                    r.returnCode = 201;
                    r.message = 'No Record Found: ';
                    r.CRMleadId = CRMleadId;
                    return r;
                }
            }Catch(Exception ex){
                system.debug('Exception::'+ex.getMessage());
                List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                if(isEnabled[0].Enable_Logs__c){
                    System_Log__c SL = new System_Log__c();
                    if(CRMLeadID.startsWith('00Q'))
                        SL.Lead__c = CRMLeadID;
                    else if(CRMLeadID.startsWith('006'))
                        SL.Opportunity__c = CRMLeadID;
                    SL.API_Name__c  = 'Lead Update API';
                    SL.Request__c = 'Request Parameters:: ' + '\n' +
                        'CRMLeadID: '+ CRMLeadID + '\n' +
                        'status: '+ status + '\n' +
                        'currentOwner: '+ currentOwner + '\n' +
                        'currentOwnerName: '+ currentOwnerName + '\n' +
                        'currentOwnerEmail: '+ currentOwnerEmail + '\n' +
                        'currentOwnerEmpId: '+ currentOwnerEmpId + '\n' +
                        'currentOwnerMobile: '+ currentOwnerMobile + '\n' +
                        'dateofDesignSharing: '+ dateofDesignSharing + '\n' +
                        'ERPB1Id: '+ ERPB1Id + '\n' +
                        'dropReason: '+ dropReason + '\n' +
                        'comments: ' + comments + '\n'+
                        'salesAmount: ' + salesAmount + '\n';//sales amount -new addition
                    SL.Response__c = 'Record Update failed - '+ ex.getMessage();
                    SL.Success__c = false;
                    insert SL;
                }
                
                r.returnCode = 400;
                r.message = 'Record Update failed - '+ ex.getMessage();
                r.CRMleadId = CRMleadId;
                return r;
            }
        }
        
        return null;
    } 
    
    global class REST_result {
        webservice Integer returnCode;
        webservice String message;
        webservice String CRMleadId;
    }
}