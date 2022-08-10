public with sharing class convertProductSales {
 @AuraEnabled(cacheable=false)
    public static convertlead.ResponseWrapper convert(Id leadId){
        convertlead.ResponseWrapper rw = new convertlead.ResponseWrapper();
        List<Account> accList = new List<Account>();
        List<Enquiry__c> updateEnquiryList = new List<Enquiry__c>();
        List<Case> updateCaseList = new List<Case>();
        
        List<Lead> leadList = [Select Id, Name, RecordTypeId, RecordType.Name, MobilePhone, Email, OTP_Verified__c, isConverted from Lead Where Id =: leadId];
        system.debug('leadList: '+leadList);
        
        if(!leadList.isEmpty() && leadList.size() > 0) {
            if(!leadList[0].OTP_Verified__c){
                rw.success = false;
                rw.message = 'Error : OTP Verification pending. Leads can be converted only after OTP verification.';
                rw.recId = null;
                rw.isError = true;
                return rw;
            }
                try {
                    String recordtypeName = leadList[0].RecordType.Name;
                    Id devRecordTypeId;
                    if(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().containsKey(recordtypeName)){
                         devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordtypeName).getRecordTypeId();
                    }
                    
                    accList = convertlead.getDupAccountList(leadList[0]);
                    system.debug('accList: '+accList);
                    
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(leadList[0].Id);
                    if(!accList.isEmpty() && accList.size() > 0) {
                        lc.setAccountId(accList[0].Id);
                        lc.setContactId(accList[0].PersonContactId);
                    }
                    LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
                    lc.setConvertedStatus(convertStatus.MasterLabel);
                    Database.DMLOptions dml = new Database.DMLOptions();
                    dml.DuplicateRuleHeader.AllowSave = true;
                    Database.LeadConvertResult lcr = Database.convertLead(lc, dml);
                    system.debug('Lead conver error:'+lcr.getErrors());
                    List<Lead> ConvertedLeadlist = new List<Lead>();
                    ConvertedLeadlist = [select Id, Name, Address, Street, City, State, Country, PostalCode, IsConverted, ConvertedAccountId, 
                                         ConvertedOpportunityId, ConvertedContactId from Lead
                                         where Id =: leadList[0].Id and Isconverted = true ORDER by LastModifiedDate Desc limit 1];
                    //system.debug('ConvertedLeadlist[0].ConvertedOpportunityId: '+ConvertedLeadlist[0].ConvertedOpportunityId);
                    
                    if(!convertedLeadList.isEmpty()) {
                    	List<Opportunity> oppList = convertlead.getOpportunityList(ConvertedLeadlist[0].ConvertedOpportunityId);
                        if(oppList != null) {
                            if(devRecordTypeId != null)
                            	oppList[0].RecordTypeId = devRecordTypeId;
                            if(ConvertedLeadlist[0].Street != null)
                                oppList[0].Address__c = ConvertedLeadlist[0].Street+' ';
                            if(ConvertedLeadlist[0].City != null)
                                oppList[0].Address__c += ConvertedLeadlist[0].City+', ';
                            if(ConvertedLeadlist[0].State != null)
                                oppList[0].Address__c += ConvertedLeadlist[0].State+' ';
                            if(ConvertedLeadlist[0].PostalCode != null)
                                oppList[0].Address__c += ConvertedLeadlist[0].PostalCode+' ';
                            if(ConvertedLeadlist[0].Country != null)
                                oppList[0].Address__c += ConvertedLeadlist[0].Country;
                            update oppList[0];
                        }
                    }
                    
                    List<Enquiry__c> enquiryList = convertlead.getEnquiriesofLead(leadList[0].Id);
                    if(enquiryList != null) {
                        for(Enquiry__c eq: enquiryList) {
                            eq.Account__c = ConvertedLeadlist[0].ConvertedAccountId;
                            eq.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                            updateEnquiryList.add(eq);
                        }
                    }
                    
                    List<Case> caseList = convertlead.getCasesofLead(leadList[0].Id);
                    if(caseList != null) {
                        for(Case c: caseList) {
                            c.AccountId = ConvertedLeadlist[0].ConvertedAccountId;
                            if(String.isNotBlank(ConvertedLeadlist[0].ConvertedContactId))
                                c.ContactId = ConvertedLeadlist[0].ConvertedContactId;
                            c.Opportunity__c = ConvertedLeadlist[0].ConvertedOpportunityId;
                            updateCaseList.add(c);
                        }
                    }
                    if(!updateEnquiryList.isEmpty() && updateEnquiryList.size() > 0)
                        update updateEnquiryList;
                    if(!updateCaseList.isEmpty() && updateCaseList.size() > 0)
                        update updateCaseList;
                    
                    rw.success = true;
                    rw.message = 'Lead has been converted';
                    rw.recId = ConvertedLeadlist[0].ConvertedOpportunityId;
                    return rw;
                } catch(Exception ex) {
                    System.Debug('Exception [' + ex.getMessage() + ']');
                    rw.success = false;
                    rw.message = 'Unknown exception occured. Please contact system administrator.'; //ex.getMessage()+ 
                    rw.recId = null;
                    rw.isError = false;
                    return rw;
                }
           
        } else {
            rw.success = false;
            rw.message = 'Unexpected error occurred while converting the lead.';
            rw.recId = null;
            rw.isError = true;
            return rw;
        }
    }
    
}