@RestResource(urlMapping='/UpdateCase/*')
global class REST_UpdateCase {
    @HttpPOST
	global static REST_result CaseDetails(string CRMCaseID, string caseStatus, string currentOwner, string caseComment){
        REST_result r = new REST_result();
        List<Case> caseList = new List<Case>();
        
        if(string.isBlank(CRMCaseID)) {
            r.returnCode = 201;
            r.message = 'CRMCaseID is missing';
            r.CRMCaseID = null;
            return r;
        } else if(string.isBlank(caseStatus)) {
            caseList = APIMangementServices.getCaseRecord(CRMCaseID);
            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
            if(isEnabled[0].Enable_Logs__c) {
                System_Log__c SL = new System_Log__c();
                SL.Case__c = caseList[0].Id;
                SL.API_Name__c  = 'Case Update API';
                SL.Request__c = 'Request Parameters:: ' + '\n' +
                    'CRMCaseID: '+ CRMCaseID + '\n' +
                    'caseStatus: '+ caseStatus + '\n' +
                    'currentOwner: '+ currentOwner + '\n' +
                    'caseComment: '+ caseComment + '\n';
                SL.Response__c = 'Failed: Can not proceed, Casestatus parameter is blank';
                SL.Success__c = false;
                insert SL;
            }
            r.returnCode = 201;
            r.message = 'Can not proceed, Casestatus parameter is blank';
            r.CRMCaseID = CRMCaseID;
            return r;
        } else if(string.isBlank(currentOwner)) {
            caseList = APIMangementServices.getCaseRecord(CRMCaseID);
            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
            if(isEnabled[0].Enable_Logs__c) {
                System_Log__c SL = new System_Log__c();
                SL.Case__c = caseList[0].Id;
                SL.API_Name__c  = 'Case Update API';
                SL.Request__c = 'Request Parameters:: ' + '\n' +
                    'CRMCaseID: '+ CRMCaseID + '\n' +
                    'caseStatus: '+ caseStatus + '\n' +
                    'currentOwner: '+ currentOwner + '\n' +
                    'caseComment: '+ caseComment + '\n';
                SL.Response__c = 'Failed: CurrentOwner Parameter is missing';
                SL.Success__c = false;
                insert SL;
            }
            r.returnCode = 201;
            r.message = 'CurrentOwner Parameter is missing';
            r.CRMCaseID = CRMCaseID;
            return r;
        } else {
            caseList = APIMangementServices.getCaseRecord(CRMCaseID);
            Map<String, Map<String, String>> codeParameterMap = new Map<String, Map<String, String>>();
            List<Case_Management_Code__c> codeList = Case_Management_Code__c.getall().values();
            if(codeList != null) {
                for(Case_Management_Code__c cmc: codeList) {
                    if(codeParameterMap.containsKey(cmc.Type__c)) {
                        Map<String, String> getMap = codeParameterMap.get(cmc.Type__c);
                        
                        if(getMap.containsKey(cmc.Code__c)) {
                            getMap.put(cmc.Code__c, cmc.Value__c);
                        } else {
                            getMap.put(cmc.Code__c, cmc.Value__c);
                        }
                        codeParameterMap.get(cmc.Type__c).putAll(getMap);
                    } else {
                        Map<String, String> newMap = new Map<String, String>();
                        newMap.put(cmc.Code__c, cmc.Value__c);
                        codeParameterMap.put(cmc.Type__c, newMap);
                    }
                }
            }
            
            if(caseList != null && !caseList.isEmpty()) {
                try {
                    List<User> user = APIMangementServices.getUserFrom_PositionId(currentOwner);
                    if(!String.isBlank(caseStatus) && codeParameterMap != null) {
                        if(codeParameterMap.get('complaintStatus').containsKey(caseStatus)) {
                            caseList[0].Status = codeParameterMap.get('complaintStatus').get(caseStatus);
                            caseList[0].Status_From_API__c = codeParameterMap.get('complaintStatus').get(caseStatus);
                        } else {
                            caseList[0].Status = caseStatus;
                            caseList[0].Status_From_API__c = caseStatus;
                        }
                    }
                    caseList[0].LastModifiedTime__c = system.now();
                    if(user != null && !user.isEmpty()) {
                        caseList[0].ownerId = user[0].Id;
                    } else {
                        caseList[0].Current_Owner_PositionID__c = currentOwner;
                    }
                    update caseList;
                    
                    //Add Case Comment
                    if(!String.isBlank(caseComment)) {
                        CaseComment newComment = new CaseComment();
                        newComment.ParentId = caseList[0].Id;
                        newComment.CommentBody = caseComment;
                        insert newComment;
                    }
                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                    if(isEnabled[0].Enable_Logs__c) {
                        System_Log__c SL = new System_Log__c();
                        SL.Case__c = caseList[0].Id;
                        SL.API_Name__c  = 'Case Update API';
                        SL.Request__c = 'Request Parameters:: ' + '\n' +
                            'CRMCaseID: '+ CRMCaseID + '\n' +
                            'caseStatus: '+ caseStatus + '\n' +
                            'currentOwner: '+ currentOwner + '\n' +
                            'caseComment: '+ caseComment + '\n';
                        SL.Response__c = 'Record Updated Succesfully';
                        SL.Success__c = true;
                        insert SL;
                    }
                    r.returnCode = 200;
                    r.message = 'Record Updated Succesfully';
                    r.CRMCaseID = CRMCaseID;
                    return r;
                } catch(Exception ex) {
                    system.debug('inside catch::'+ex.getMessage());
                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                    if(isEnabled[0].Enable_Logs__c) {
                        System_Log__c SL = new System_Log__c();
                        SL.Case__c = caseList[0].Id;
                        SL.API_Name__c  = 'Case Update API';
                        SL.Request__c = 'Request Parameters:: ' + '\n' +
                            'CRMCaseID: '+ CRMCaseID + '\n' +
                            'caseStatus: '+ caseStatus + '\n' +
                            'currentOwner: '+ currentOwner + '\n' +
                            'caseComment: '+ caseComment + '\n';
                        SL.Response__c = 'Failed: ' + ex.getMessage();
                        SL.Success__c = false;
                        insert SL;
                    }
                    r.returnCode = 401;
                    r.message = 'Failed: '+ex.getMessage();
                    r.CRMCaseID = CRMCaseID;
                    return r;
                }
            } else {
                r.returnCode = 401;
                r.message = 'Failed: No Case Found with given CRMCaseId';
                r.CRMCaseID = CRMCaseID;
                return r;
            }
        }
    }
    global class REST_result {
        webservice Integer returnCode;
        webservice String message;
        webservice String CRMCaseId;
    }
}