public without sharing class AddBU {
    public class leadWrapper{
        @InvocableVariable public String  originalLeadId;
        @InvocableVariable public Boolean SPS;
        @InvocableVariable public Boolean BHS;
        @InvocableVariable public Boolean SLEEK;
        @InvocableVariable public Boolean BH_Store;
        @InvocableVariable public Boolean General_Enquiry;
        @InvocableVariable public Boolean TCS;
    }
    
    public class resultWrapper{
        @InvocableVariable public String SPS_url;
        @InvocableVariable public String BHS_url;
        @InvocableVariable public String SLEEK_url;
        @InvocableVariable public String BH_Store_url;
        @InvocableVariable public String General_Enquiry_url;
        @InvocableVariable public String TCS_url;
        @InvocableVariable public String error;
    }
    @InvocableMethod(label='Add BU Lead'  category='Other')
    public static List<resultWrapper> getBUList(List<leadWrapper> leadData){
        List<resultWrapper> rwList = new List<resultWrapper>();
        resultWrapper rw = new resultWrapper();
        rw.SPS_url = '';
        rw.BHS_url = '';
        rw.SLEEk_url = '';
        rw.BH_Store_url ='';
        rw.General_Enquiry_url = '';
        rw.TCS_url ='';
        rw.error = '';
        system.debug(leaddata);
        Boolean isPortalUser = [Select Id,IsPortalEnabled from User WHERE Id =: userinfo.getUserId()][0].isPortalEnabled;
        String crossSellBy = 'Helpline';
        String urlPrefix = '/';
        if(isPortalUser) {
            crossSellBy = 'Field Team';
            urlPrefix ='/PaintAssist/s/lead/';
        }
        Lead lList =[SELECT ID, FirstName, LastName, Pincode__c, MobilePhone, Email,CampaignName__c FROM Lead WHERE ID =: leadData[0].originalLeadId][0];
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true; 
        dml.optAllOrNone = true;
        List<Lead> leadsToInsert= new List<Lead>();
        Savepoint sp = Database.setSavepoint();
        try{
            if(leadData[0].BHS){
                Lead l =  lList.clone(false, false, false, false);
                l.RecordTypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('BHS').getRecordTypeId();
                l.Cross_Sell_By__c = crossSellBy;
                l.Inter_Related_BU_1__c = lList.Id;
                l.Status = 'New';
                leadsToInsert.add(l);
                Database.SaveResult sr = Database.insert(l,dml);
                rw.BHS_url = urlPrefix+sr.getId();
            }
            if(leadData[0].SPS){
                Lead l =  lList.clone(false, false, false, false);
                l.RecordTypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SPS').getRecordTypeId();
                l.Cross_Sell_By__c = crossSellBy;
                l.Inter_Related_BU_1__c = lList.Id;
                l.Status = 'New';
                leadsToInsert.add(l);
                Database.SaveResult sr = Database.insert(l,dml);
                rw.SPS_url = urlPrefix+sr.getId();
            }
            if(leadData[0].SLEEK){
                Lead l =  lList.clone(false, false, false, false);
                l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SLEEK').getRecordTypeId();
                l.Cross_Sell_By__c = crossSellBy;
                l.Inter_Related_BU_1__c = lList.Id;
                l.Status = 'New';
                leadsToInsert.add(l);
                Database.SaveResult sr = Database.insert(l,dml);
                rw.SLEEK_url = urlPrefix+sr.getId();
            }
            if(leadData[0].BH_Store){
                Lead l =  lList.clone(false, false, false, false);
                l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('BH_Store').getRecordTypeId();
                l.Cross_Sell_By__c = crossSellBy;
                l.Inter_Related_BU_1__c = lList.Id;
                l.Status = 'New';
                leadsToInsert.add(l);
                Database.SaveResult sr = Database.insert(l,dml);
                rw.BH_Store_url = urlPrefix+sr.getId();
            }
            /* if(leadData[0].General_Enquiry){
Lead l =  lList.clone(false, false, false, false);
l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('General_Enquiry').getRecordTypeId();
l.Cross_Sell_By__c = 'Helpline';
l.Inter_Related_BU_1__c = lList.Id;
leadsToInsert.add(l);
Database.SaveResult sr = Database.insert(l,dml);
rw.General_Enquiry_url = '/'+sr.getId();
}*/
            if(leadData[0].TCS){
                Lead l =  lList.clone(false, false, false, false);
                l.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('General_Enquiry').getRecordTypeId();
                l.Cross_Sell_By__c = crossSellBy;
                l.Inter_Related_BU_1__c = lList.Id;
                l.Status = 'New';
                leadsToInsert.add(l);
                Database.SaveResult sr = Database.insert(l,dml);
                rw.TCS_url = urlPrefix+sr.getId();
            }
        }
        catch(Exception e){
            Database.rollback(sp);
            rw.error = e.getMessage();
        }
        
        
        
        rwList.add(rw);
        return rwList;
    }
}