public with sharing class EnquiryToLead {
     public class ioWrapper{
        @InvocableVariable public String entityId;
        @InvocableVariable public Boolean isSuccess;
        @InvocableVariable public String service;
        @InvocableVariable public String pincode;
        @InvocableVariable public String errorMsg;
         
     }
   
    @InvocableMethod(label='convertEnquiry'  category='Other')
    public static List<ioWrapper> convertEnquiry(List<ioWrapper> enqList){
        String eid = enqList[0].entityId;
         // Enquiry__c eList = [SELECT ID,Customer_Name__c, Lead__c, Pincode__c,Mobile__c, Email__c,Campaign__c,LeadSource__c  FROM Enquiry__c WHERE ID =: enqList[0].entityId][0];
          List<Enquiry__c> e = new List<Enquiry__c>();
            DescribeSObjectResult describeResult = Enquiry__c.getSObjectType().getDescribe();  
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNames, ',' ) + 
                ' FROM ' + describeResult.getName() + ' where Id =' + '\'' + eid + '\'';
            
            e = Database.query(query1);
           
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 	
        Lead l = new Lead();
        
		l.LastName = e[0].Customer_Name__c;
        l.LeadSource = e[0].LeadSource__c;
        l.Account_ID__c = e[0].Account__c;
        l.Budget__c = e[0].Budget__c;
        l.CampaignName__c = e[0].Campaign__c;
        l.Campaign_Code__c = e[0].Campaign_Code__c;
        l.LastName = e[0].Customer_Name__c;
        l.Dealer__c = e[0].Dealer__c;
        l.Email = e[0].Email__c;
        l.RO_BP__c = e[0].RO_BP__c;
        l.RO_Mobile__c = e[0].RO_Mobile__c;
        l.RO_Name__c = e[0].RO_Name__c;
        l.External_Lead_Creator_Position_Code__c = e[0].External_Lead_Creator_Position_Code__c;
        l.External_Lead_ID__c = e[0].External_System_Lead_Id__c;
        l.Firm_BP__c = e[0].Firm_BP__c;
        l.Firm_Mobile__c = e[0].Firm_Mobile__c;
        l.Firm_Name__c = e[0].Firm_Name__c;
        l.Floor__c = e[0].floor__c;
        l.House__c = e[0].House__c;
        l.Initiator_BP__c = e[0].Initiator_BP__c;
        l.Initiator_Mobile__c = e[0].Initiator_Mobile__c;
        l.Initiator_Name__c = e[0].Initiator_Name__c;
        l.Integration_Source__c = e[0].Integration_Source__c;
        l.IP_Address__c = e[0].IP_Address__c;
        l.LeadSource = e[0].LeadSource__c;
        l.MobilePhone = e[0].Mobile__c;
        l.Page_Url__c = e[0].Page_URL__c;
        l.Pincode__c = e[0].Pincode__c;
        l.Priority__c = e[0].Priority__c;
        l.Probable_Conversion_Date__c = e[0].Probable_Conversion_Date__c;
        l.Project_Type__c = e[0].Project_Type__c;
        l.Referral_Type__c = e[0].Referral_Type__c;
        l.Referrer_Mobile__c = e[0].Referrer_Mobile__c;
        l.Referrer_Name__c = e[0].Referrer_Name__c;
        l.Referrer_Email__c = e[0].Referrer_Email__c;
       	l.Skip_Calling__c = e[0].Skip_Calling__c;
        l.Summary_of_Work__c = e[0].Summary_of_Work__c;
        l.UTM_Device__c = e[0].UTM_Device__c;
        l.UTM_Medium__c = e[0].UTM_Medium__c;
        l.Visitor_Id__c = e[0].Visitor_Id__c;
        l.Is_Local__c = true;
        if(e[0].Service__c != null && !String.isBlank(e[0].Service__c)){
            if(Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(e[0].Service__c).getRecordTypeId() !=null){
                l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(e[0].Service__c).getRecordTypeId();
       
            }
        }
        
        
        Database.SaveResult sr = Database.insert(l,dml);
         System.debug(sr.isSuccess() +' '+ sr.getErrors());
        if(sr.isSuccess()){
       
        enqList[0].entityId = sr.getId();
              enqList[0].isSuccess = true;
        }
        else {
            enqList[0].isSuccess = false;
            enqList[0].errorMsg = sr.getErrors()[0].getMessage();
        }
        return enqList;
    }
}