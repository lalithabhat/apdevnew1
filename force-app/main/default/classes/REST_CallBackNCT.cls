@RestResource(urlMapping='/CallBackNCT/*')
global class REST_CallBackNCT {
    @HttpPOST
    global static REST_result createCall(List<REST_Request> reqList) {
        REST_Result r = new REST_Result();
        Map<String, Set<Id>> leadIdMap = new Map<String, Set<Id>>();
        List<Task> taskList = new List<Task>();
        List<Id> aSet = new List<Id>();
        List<Id> lSet = new List<Id>();
        Map<Id, Account> accDetails = new Map<Id, Account>();
        Map<Id, Lead> leadDetails = new Map<Id, Lead>();

        if(!reqList.isEmpty()) {
            for(REST_Request req: reqList) {
                if(String.isBlank(req.SFDC_LEAD_ID) || String.isBlank(req.SERVICE_ID) || String.isBlank(req.MOBILE_NO) || String.isBlank(req.CALL_TIME) || String.isBlank(req.DISPOSITION)) {
                    r.returnCode = 400;
                    r.message = 'Please Provide Required Details for Index: '+reqList.indexOf(req);
                    return r;
                } else {
                    if(Id.Valueof(req.SFDC_LEAD_ID).getSObjectType().getDescribe().getName() == 'Account') {
                        aSet.add(Id.Valueof(req.SFDC_LEAD_ID));
                    } else if(Id.Valueof(req.SFDC_LEAD_ID).getSObjectType().getDescribe().getName() == 'Lead') {
                        lSet.add(Id.Valueof(req.SFDC_LEAD_ID));
                    }
                }
            }
            
            // if the task is to be associated with an person account, then the personcontactId has to be mapped in whoId
            if(!aSet.isEmpty()) {
                accDetails = new Map<Id, Account>([Select Id, PersonContactId, OwnerId from Account where Id IN: aSet]);
            }
            if(!lset.isEmpty()) {
                leadDetails = new Map<Id, Lead>([Select Id, OwnerId from Lead where Id IN: lSet]);
            }
            
            for(REST_Request req: reqList) {
                Task t = new Task();
                t.Subject = 'NCT Call';
                t.Priority = 'Normal';
                t.Status = 'Completed';
                t.ActivityDate = system.today();
                t.Disposition__c = req.DISPOSITION;
                t.Mobile__c = req.MOBILE_NO;
                t.Call_Time__c = req.CALL_TIME;
                t.Service_Id__c = req.SERVICE_ID;
                
                if(Id.Valueof(req.SFDC_LEAD_ID).getSObjectType().getDescribe().getName() == 'Lead') {
                    t.whoId = Id.Valueof(req.SFDC_LEAD_ID);
                    t.OwnerId = leadDetails.get(Id.Valueof(req.SFDC_LEAD_ID)).OwnerId;
                } else if(Id.Valueof(req.SFDC_LEAD_ID).getSObjectType().getDescribe().getName() == 'Account') {
                    t.whoId = accDetails.get(Id.Valueof(req.SFDC_LEAD_ID)).PersonContactId;
                    t.ownerId = accDetails.get(Id.Valueof(req.SFDC_LEAD_ID)).OwnerId;
                    t.whatId = Id.Valueof(req.SFDC_LEAD_ID);
                } else {
                    t.whoId = '';
                    t.ownerId = '';
                }
                taskList.add(t);
            }
            try {
                if(!taskList.isEmpty())
                    insert taskList;
                
                List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                if(isEnabled[0].Enable_Logs__c){
                    System_Log__c SL = new System_Log__c();
                    SL.API_Name__c  = 'Call Back NCT';
                    SL.Request__c = JSON.serialize(reqList);
                    SL.Response__c = 'Success';
                    SL.Success__c = true;
                    insert SL;
                }
                r.returnCode = 201;
                r.message = 'Success';
                return r;
            } catch(Exception ex) {
                List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                if(isEnabled[0].Enable_Logs__c){
                    System_Log__c SL = new System_Log__c();
                    SL.API_Name__c  = 'Call Back NCT';
                    SL.Request__c = JSON.serialize(reqList);
                    SL.Response__c = ex.getMessage();
                    SL.Success__c = false;
                    insert SL;
                }
                r.returnCode = 400;
                r.message = ex.getMessage();
                return r;
            }
        } else {
            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
            if(isEnabled[0].Enable_Logs__c){
                System_Log__c SL = new System_Log__c();
                SL.API_Name__c  = 'Call Back NCT';
                SL.Request__c = JSON.serialize(reqList);
                SL.Response__c = 'Request is empty';
                SL.Success__c = true;
                insert SL;
            }
            
            r.returnCode = 400;
            r.message = 'Please Provide Request';
            return r;
        }
    }
    global class REST_Result {
        webservice Integer returnCode;
        webservice String message;
        //webservice String SFDC_TASK_ID;
    }
    global class REST_Request {
        webservice String SFDC_LEAD_ID;
        webservice String SERVICE_ID;
        webservice String MOBILE_NO;
        webservice String CALL_TIME;
        webservice String DISPOSITION;
    }
}