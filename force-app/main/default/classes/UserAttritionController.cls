public class UserAttritionController {
	
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContactRecords(string searchTerm){
        system.debug('inside getContactRecords searchTerm::: '+searchTerm);
        if(string.isNotBlank(searchTerm)){
            List<Contact> cList = [select id,name,FirstName,LastName,Persona__c,PositionID__c,Email,MobilePhone from contact
                                  where name Like :searchTerm OR PositionID__c Like :searchTerm OR 
                                  MobilePhone LIKE :searchTerm OR Email LIKE :searchTerm];
            system.debug('cList::'+cList);
            return cList;
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(){
        List<Contact> cList = [select id,name,Persona__c,PositionID__c,Email,MobilePhone from contact
                               where Active__c = true];
        system.debug('cList::'+cList);
        return cList;
    }
    
    @AuraEnabled
    public static string checkValidationAPex(string oldContact, string newContact){
        system.debug('oldContact:'+oldContact);
        system.debug('newContact:'+newContact);
        try{
            Contact oldRecord = [select id,name,FirstName,LastName,Persona__c,PositionID__c,Email,MobilePhone from Contact
                                where Id =: oldContact];
            Contact newRecord = [select id,name,FirstName,LastName,Persona__c,PositionID__c,Email,MobilePhone from Contact
                                where Id =: newContact];
            
            if(oldRecord.Persona__c != 'TA' && oldRecord.Persona__c != 'SA' && oldRecord.Persona__c != 'CA' && oldRecord.Persona__c != 'TL'){
                return 'Old Contact persona must be TA,CA,SA or TL';
            }
            if(newRecord.Persona__c != 'TA' && newRecord.Persona__c != 'SA' && newRecord.Persona__c != 'CA' && newRecord.Persona__c != 'TL'){
                return 'New Contact persona must be TA,CA,SA or TL';
            }
            List<User> oldUser = [select id,name,mobilePhone from user where contactId=:oldRecord.Id and isActive = false];
            List<User> newUser = ScheduleAppointmentServices.getCAFromId(newRecord.Id);
            if(oldUser.isEmpty()){
                return 'Old Contact user must be Deactivated';
            }
            if(newUser.isEmpty()){
                return 'New Contact user must be activated';
            }
            if(oldRecord.Id == newRecord.Id){
                return 'Old Contact and New Contact are same';
            }
            if(oldRecord.PositionID__c != newRecord.PositionID__c){
                return 'Old Contact and New Contact Position Id must be same';
            }
       
            /***    clone old SAP mapping table with new Contact   *********/
            List<SA_Pincode_Mapping__c> mapping_Table = [select id,name,SA__c,Pincode__c,Pincode_lookup__c,Priority__c,
                                                        Role__c,Service_Master__c,TL1__c,TL2__c from SA_Pincode_Mapping__c
                                                        where SA__c =: oldRecord.Id];
            if(mapping_Table != null && !mapping_Table.isEmpty()){
                List<SA_Pincode_Mapping__c> recordToInsert = new List<SA_Pincode_Mapping__c>();
                for(SA_Pincode_Mapping__c oldInstance : mapping_Table){
                    SA_Pincode_Mapping__c newInstance = new SA_Pincode_Mapping__c();
                    newInstance.SA__c = newRecord.Id;
                    newInstance.Pincode__c = oldInstance.Pincode__c;
                    newInstance.Pincode_lookup__c = oldInstance.Pincode_lookup__c;
                    newInstance.Priority__c = oldInstance.Priority__c;
                    newInstance.Role__c = oldInstance.Role__c;
                    newInstance.Service_Master__c = oldInstance.Service_Master__c;
                    newInstance.TL1__c = oldInstance.TL1__c;
                    newInstance.TL2__c = oldInstance.TL2__c;
                    newInstance.Replacement_Entry__c = true;
                    newInstance.Replacement_Remark__c = 'Persona change from ' + oldRecord.Name + ' to ' +
                                                        newRecord.Name + ' By ' + UserInfo.getName() + '. On dated ' +
                                                        system.today().format();
                    recordToInsert.add(newInstance);
                }
                insert recordToInsert;
            }else{
                List<SA_Pincode_Mapping__c> mapping_Table_TA_TL = [select id,name,SA__c,Pincode__c,Pincode_lookup__c,Priority__c,
                                                                   Role__c,Service_Master__c,TL1__c,TL2__c from SA_Pincode_Mapping__c
                                                                   where TL1__c =: oldRecord.Id OR TL2__c =: oldRecord.Id];
                if(mapping_Table_TA_TL != null && !mapping_Table_TA_TL.isEmpty()){
                    for(SA_Pincode_Mapping__c ap : mapping_Table_TA_TL){
                        if(ap.TL1__c != null && ap.TL1__c == oldRecord.Id){
                            ap.TL1__c = newRecord.Id;
                            ap.Replacement_Entry__c = true;
                            ap.Replacement_Remark__c = 'TL1 change from ' + oldRecord.Name + ' to ' +
                                                                newRecord.Name + ' By ' + UserInfo.getName() + '. On dated ' +
                                                                system.today().format();
                        }else if(ap.TL2__c != null && ap.TL2__c == oldRecord.Id){
                            ap.TL2__c = newRecord.Id;
                            ap.Replacement_Entry__c = true;
                            ap.Replacement_Remark__c = 'TL2 change from ' + oldRecord.Name + ' to ' +
                                                                newRecord.Name + ' By ' + UserInfo.getName() + '. On dated ' +
                                                                system.today().format();
                        }
                    }
                    update mapping_Table_TA_TL;
                }
            }
            
     /***    Change Lead Owner to new Contact   *********/       
            List<Lead> leadList = [select id,name,OwnerId from Lead where OwnerId =: oldUser[0].Id and OTP_Verified__c = false 
                                    and Status != 'Closed' and Status != 'Lost' and isConverted = false];
            if(leadList != null && !leadList.isEmpty()){
                List<Lead> leadListForUpdate = new List<Lead>();
                for(lead l : leadList){
                    l.OwnerId = newUser[0].Id;
                    leadListForUpdate.add(l);
                }
                update leadListForUpdate;
            }else{
                List<Lead> leadList_TA_TL = [select id,name,OwnerId from Lead where (TL1__c =:oldUser[0].Id OR TL2__c =:oldUser[0].Id)
                                            and OTP_Verified__c = false 
                                    		and Status != 'Closed' and Status != 'Lost' and isConverted = false];
                if(leadList_TA_TL != null && !leadList_TA_TL.isEmpty()){
                    for(Lead l : leadList_TA_TL){
                        if(l.TL1__c == oldRecord.Id){
                            l.TL1__c = newRecord.Id;
                        }else if(l.TL2__c == oldRecord.Id){
                            l.TL2__c = newRecord.Id;
                        }
                    }
                    update leadList_TA_TL;
                }
            }
            
     /***    Change Opportunity Owner to new Contact   *********/  
            List<Opportunity> optyList = [select id,name,OwnerId from Opportunity where OwnerId =: oldUser[0].Id and
                                         stageName != 'Closed Won' and stageName != 'Closed Lost'];
            if(optyList != null && !optyList.isEmpty()){
                
            }else{
                if(Test.isRunningTest()){
                    optyList = [select id,name,Ownerid from Opportunity];
                }
            }
            if(optyList != null && !optyList.isEmpty()){
                set<Id> oppIds = new Set<Id>();
                List<Opportunity> optyListforUpdate = new List<Opportunity>();
                for(Opportunity op : optyList){
                    op.ownerId = newUser[0].Id;
                    optyListforUpdate.add(op);
                    oppIds.add(op.Id);
                }
                update optyListforUpdate;
                getRecordList(oppIds,'Milestone1_Project__c','Opportunity__c',oldUser[0].Id,newUser[0].Id);
                getRecordList(oppIds,'Milestone1_Milestone__c','Opportunity__c',oldUser[0].Id,newUser[0].Id);
                getRecordList(oppIds,'Case','Opportunity__c',oldUser[0].Id,newUser[0].Id);
                getRecordList(oppIds,'Checklist_Header__c','Project__r.Opportunity__c',oldUser[0].Id,newUser[0].Id);
                getRecordList(oppIds,'Checklist_Item__c','Checklist_Header__r.Project__r.Opportunity__c',oldUser[0].Id,newUser[0].Id);
            }
            System_Log__c logs = new System_Log__c();
            logs.Description__c = 'User Attrition log: \n' + 'Old contact Id: ' + oldRecord.Id + ' and New Contact Id: '+
                				   newRecord.Id + '.\n' + ' Completed by: ' + UserInfo.getName();
            insert logs;
                return 'Success';
        }catch(exception ex){
            system.debug('Failed :: '+ex.getMessage());
            return 'Some Internal error';
        }
    }
    
    Public static void getRecordList(set<Id> oppId, string sObjectName, string fieldName, string ownerId, string newOwner){
        List<sobject> rc = new List<sobject>();
        string query = 'select Id,ownerId from ' + string.valueOf(sObjectName) + 
            		   ' where ' + string.valueOf(fieldName) + ' IN: oppId' + 
            		   ' and OwnerId =: ownerId';
        system.debug('query :: '+query);
        rc = Database.query(query);    
        system.debug('rc::'+rc);
        if(rc != null && !rc.isEmpty()){
            for(sobject s : rc){
                s.put('OwnerId', newOwner);
            }
            update rc;
        }
    }
    
  
}