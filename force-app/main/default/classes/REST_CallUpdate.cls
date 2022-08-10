@RestResource(urlMapping='/CallUpdate/*')
global class REST_CallUpdate {
    @HttpPOST
    global static REST_result callUpdate(REST_Request req) {
        REST_Result r = new REST_Result();
        List<Task> taskList = new List<Task>();
        List<User> uList = new List<User>();
        List<Task> updateTaskList = new List<Task>();
        
        if(String.isBlank(req.SFDC_LEAD_ID) || String.isBlank(req.SFDC_TASK_ID) || String.isBlank(req.CALL_RECORDING) || String.isBlank(req.CALL_DURATION) || String.isBlank(req.CALL_START_TIME) ||
           String.isBlank(req.CALL_END_TIME) || String.isBlank(req.REQUEST_NO) || String.isBlank(req.CALL_TYPE) || String.isBlank(req.AGENT_ID)) 
        {
            List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
            if(isEnabled[0].Enable_Logs__c){
                System_Log__c SL = new System_Log__c();
                SL.API_Name__c  = 'Call Update API';
                SL.Request__c = JSON.serialize(req);
                SL.Success__c = false;
                insert SL;
            }
        	r.returnCode = 400;
            r.message = 'Please Provide Required Details';
            return r;
        } else {
            taskList = [Select Id, OwnerId, WhoId, WhatId, Call_Recording__c, Call_Recording_New__c, Call_Duration__c, Start_Time__c, End_Time__c, Request_No__c, Call_Type__c from Task where Id =: req.SFDC_TASK_ID];
            system.debug('taskList: '+taskList);
            
            if(!taskList.isEmpty()) {
                uList = [Select Id, Name from User where Id =: req.AGENT_ID];
                system.debug('uList: '+uList);
                if(!uList.isEmpty())
                	taskList[0].OwnerId = uList[0].Id;
                taskList[0].Call_Recording__c = req.CALL_RECORDING;
                taskList[0].Call_Recording_New__c = req.CALL_RECORDING;
                taskList[0].Call_Duration__c = req.CALL_DURATION;
                taskList[0].Start_Time__c = req.CALL_START_TIME;
                taskList[0].End_Time__c = req.CALL_END_TIME;
                taskList[0].Request_No__c = req.REQUEST_NO;
                taskList[0].Call_Type__c = req.CALL_TYPE;
                updateTaskList.add(taskList[0]);
                
                try {
                    if(!updateTaskList.isEmpty())
                        update updateTaskList;
                    
                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                    if(isEnabled[0].Enable_Logs__c){
                        System_Log__c SL = new System_Log__c();
                        SL.API_Name__c  = 'Call Update API';
                        SL.Request__c = JSON.serialize(req);
                        SL.Response__c = 'Call Updated Successfully';
                        SL.Success__c = true;
                        insert SL;
                    }
                    
                    r.returnCode = 201;
                    r.message = 'Success';
                    r.SFDC_TASK_ID = req.SFDC_TASK_ID;
                    return r;
                } catch(Exception ex) {
                    system.debug('Error: '+ex.getMessage());
                    
                    List<Application_Logs__c> isEnabled = Application_Logs__c.getAll().values();
                    if(isEnabled[0].Enable_Logs__c){
                        System_Log__c SL = new System_Log__c();
                        SL.API_Name__c  = 'Call Update API';
                        SL.Request__c = JSON.serialize(req);
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
                    SL.API_Name__c  = 'Call Update API';
                    SL.Request__c = JSON.serialize(req);
                    SL.Response__c = 'Call Log Not Found';
                    SL.Success__c = false;
                    insert SL;
                }
                
                r.returnCode = 400;
                r.message = 'Call log not found';
                return r;
            }
        }
    }
    global class REST_Result {
        webservice Integer returnCode;
        webservice String message;
        webservice String SFDC_TASK_ID;
    }
    global class REST_Request {
        webservice String SFDC_LEAD_ID;
        webservice String SFDC_TASK_ID;
        webservice String CALL_RECORDING;
        webservice String CALL_DURATION;
        webservice String CALL_START_TIME;
        webservice String CALL_END_TIME;
        webservice String REQUEST_NO;
        webservice String CALL_TYPE;
        webservice String AGENT_ID;
    }
}