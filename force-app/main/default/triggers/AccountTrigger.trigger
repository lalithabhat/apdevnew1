trigger AccountTrigger on Account(before Insert) {
    if(Trigger.IsInsert) {   
        if(Trigger.isBefore) {
            List<DupResultsDTO> dupResList = new List<DupResultsDTO>();
            Map<lead, Account> leadaccMap = new Map<lead, Account>();
            Map<Boolean, String> resultMap = new Map<Boolean, String>();
            String errMsg = '';
            
            if(!(System.isBatch())) {
                List<Lead> leadList=new List<Lead>();
                Id AccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
                for(Account acc: Trigger.New) {
                    if(acc.RecordTypeId == AccRecordTypeId && !acc.Legacy_Upload__c) {
                        system.debug('In Person Account');
                        Lead leadObj = new Lead();
                        leadObj.lastName = acc.lastName;
                        leadObj.MobilePhone = acc.PersonMobilePhone;
                        leadObj.Email = acc.PersonEmail;
                        //leadObj.Account_ID__c = acc.Id;
                        leadList.add(leadObj);
                        leadaccMap.put(leadObj, acc);
                    }
                }
                if(!leadList.isEmpty()) {
                    dupResList = LeadManagementServices.leadPreProcessing(leadList, 'BULKLOAD');
                    system.debug('dupResList: '+dupResList);
                    
                    if(!dupResList.isEmpty()) {
                        resultMap = EnquiryManagementServices.leadProcessing(dupResList, leadList, 'Account');
                        system.debug('resultMap: '+resultMap);
                        
                        for(Lead l: leadList) {
                            System.debug('Trigger.new: ' + l); 
                            if(resultMap.containsKey(FALSE)) {
                                errMsg = 'Duplicates exists for:' + l.lastName + '\n'+'you cannot create duplicates';
                                leadAccMap.get(l).addError(errMsg);
                            }                      
                        }
                    }
                }
            }
        }
    }
}