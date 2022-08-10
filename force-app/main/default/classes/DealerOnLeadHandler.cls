public without sharing class  DealerOnLeadHandler {

    @AuraEnabled
    public static Map<Id,String> getDealer(String leadId){
        Map<Id,String> dealerMap = new Map<Id,String>();
        Lead l = [SELECT Pincode__c, recordType.developerName FROM Lead WHERE ID =: leadId][0];
        
        for(SA_Pincode_Mapping__c pinMap : [SELECT Service_Master__r.Service__c, SA__r.Account.Name, SA__r.Account.Id  
                                            FROM SA_Pincode_Mapping__c 
                                            WHERE Pincode__c =: l.Pincode__c
                                           AND Service_Master__r.Service__c =: l.RecordType.developerName]){
            dealerMap.put(pinMap.SA__r.Account.Id,  pinMap.SA__r.Account.Name);
        }
        return dealerMap;
    }
    @Auraenabled
    public static void updateLead(String leadId, String dealerId){
        Lead l = new Lead(id=leadId, dealer__c = dealerId, Status = 'Allocation Done');
        update l;
    }
}