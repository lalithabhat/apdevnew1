public class APIMangementServices {
    
    Public static List<User> getUserFrom_PositionId(string positionID){
        if(string.isNotBlank(positionID)){
            List<Contact> contactRecord = [select id,name from Contact where PositionID__c =: positionID];
            if(contactRecord != null && !contactRecord.isEmpty()){
                List<User> userRecord = ScheduleAppointmentServices.getCAFromId(contactRecord[0].Id);
                system.debug('userRecord::'+userRecord);
                return userRecord;
            }
        }
        
        return null;
    }
    
    Public static List<Lead> getLeadRecord(string id){
        List<Lead> leadList = new List<Lead>();
        
        DescribeSObjectResult describeResultLead = Lead.getSObjectType().getDescribe();  
        List<String> fieldNamesLead = new List<String>( describeResultLead.fields.getMap().keySet() );
        String query1 = ' SELECT ' + String.join( fieldNamesLead, ',' ) + ',RecordType.Name ' +
            ' FROM ' + describeResultLead.getName() + ' where id=' + '\'' + id + '\' and IsConverted = false';
        
        leadList = Database.query(query1);
        system.debug('leadList::'+leadList);
        return leadList;
    }
    
    Public static List<Opportunity> getOpportunityRecord(string id){
        List<Opportunity> opportunityList = new List<Opportunity>();
        
        DescribeSObjectResult describeResultOpportunity = Opportunity.getSObjectType().getDescribe();  
        List<String> fieldNamesOpportunity = new List<String>( describeResultOpportunity.fields.getMap().keySet() );
        String query1 = ' SELECT ' + String.join( fieldNamesOpportunity, ',' ) + 
            ' FROM ' + describeResultOpportunity.getName() + ' where Lead_Id__c =' + '\'' + id + '\'';
        
        opportunityList = Database.query(query1);
        system.debug('opportunityList::'+opportunityList);
        return opportunityList;
    }
    
    Public static List<Case> getCaseRecord(string id){
        List<Case> caseList = new List<Case>();
        
        DescribeSObjectResult describeResultCase = Case.getSObjectType().getDescribe();  
        List<String> fieldNamesCase = new List<String>( describeResultCase.fields.getMap().keySet() );
        String query1 = ' SELECT ' + String.join( fieldNamesCase, ',' ) + 
            ' FROM ' + describeResultCase.getName() + ' where CaseNumber =' + '\'' + id + '\'';
        
        caseList = Database.query(query1);
        system.debug('caseList::'+caseList);
        return caseList;
    }
    
    Public static List<Opportunity> convertLead(Lead lead){
        if(lead != null){
            string recordtypeName = lead.RecordType.Name;
            Id devRecordTypeId;
            if(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().containsKey(recordtypeName)){
                 devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
            }
            
            Set<Id> accountId = new set<Id>();
            string leadId = lead.Id;
            List <DupResultsDTO> dupResList = new List <DupResultsDTO>();
            List<Lead> leadList = new List<Lead>();
            leadList.add(lead);
            dupResList = LeadManagementServices.leadPreProcessing(leadList, 'BULKLOAD');
            system.debug('DupResList::'+DupResList);
            if(!dupResList.isEmpty()){
                for(DupResultsDTO d: dupResList) {
            		for(String key: d.duplicatesMap.keySet()) {
                		if(key == 'Account') {
                    		system.debug('In exiting Account: '+d.duplicatesMap.get(Key));
                    		accountId = d.duplicatesMap.get(Key);
                		}
                    }
                }
            }
            
            List<Opportunity> optyList = new List<Opportunity>();
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadId);
            if(!accountId.isEmpty()){
            	lc.setAccountId((new list<Id>(accountId) )[0] );    
            }
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            Database.LeadConvertResult lcr = Database.convertLead(lc,dml);
            if(lcr.isSuccess()){
                Id OpportunityId=[select ConvertedOpportunityId from Lead where id=:leadId].ConvertedOpportunityId;
                system.debug('ConvertedOpportunityId::'+OpportunityId);
                optyList = getOpportunityRecord(leadId);
                if(devRecordTypeId != null){
                    optyList[0].RecordtypeId = devRecordTypeId;
                    update optyList[0];
                	return optyList;
                }
                
            }else{
                
            }
            
        }
        return null;
    }

}