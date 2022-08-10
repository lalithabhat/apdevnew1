@isTest
public class Test_FlowInvocable {
    @isTest
    static void test(){
        OTP_Generator.getOTP();
       
        
        List<AddBU.leadWrapper> leadDataList = new List<AddBU.leadWrapper>();
        AddBU.leadWrapper leadData = new AddBU.leadWrapper();
        leadData.BHS = true;
        leadData.SLEEK =true;
        leadData.SPS = true;
        leadData.BH_Store = true;
        leadData.TCS =true;
        
        leadData.originalLeadId = TestDataFactory.createLead('8000090000', 'email@email.com', '422101', Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SPS').getRecordTypeId(), null).Id;
        leadDataList.add(leadData);
        AddBU.getBUList(leadDataList);    
        
     /*   Enquiry__c e = new Enquiry__c(Mobile__c = '8000070000', customer_Name__c = 'Test',Lead__c = TestDataFactory.createLead('8500090000', 'email12@email.com', '422102', Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SPS').getRecordTypeId(), null).Id);
        insert e;
        List<EnquiryToLead.ioWrapper> eList = new List<EnquiryToLead.ioWrapper>();
        EnquiryToLead.ioWrapper eio= new EnquiryToLead.ioWrapper();
        eio.entityId =  e.Id;
        eio.pincode = '422100';
        eio.service = 'SPS';
        eList.add(eio);
        EnquiryToLead.convertEnquiry(eList);
        ServiceabilityInvocable.checkService(eList);*/
    }
    
    @isTest
    static void  testDealerAssingment(){
       /* campaign c = TestDataFactory.createCampaign('SPS','Nilaya');
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        
        Lead l = TestDataFactory.createLead('1234567234','email@stetig.in','123457',string.valueOf(devRecordTypeId),c.Id);
        Account dealer = TestDataFactory.createDealerAccount('Dealer1',  '1234567890',  '123', 'CI');
        DealerOnLeadHandler.getDealer(l.Id);
        DealerOnLeadHandler.updateLead(l.id, dealer.Id);*/
    }
}