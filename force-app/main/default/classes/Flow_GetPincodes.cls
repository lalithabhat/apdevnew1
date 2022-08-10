public without sharing class Flow_GetPincodes {
    
    
    @InvocableMethod(label='GetPincodes'  category='Other')
    public static List<List<SA_Pincode_Mapping__c>> getPincodes(List<Id> contactId){
        system.debug('contactId :'+contactId[0]);
        List<List<SA_Pincode_Mapping__c>> result = new List<List<SA_Pincode_Mapping__c>>();
        List<SA_Pincode_Mapping__c> pm = [Select Id,Pincode__c, Pincode_lookup__c from SA_Pincode_Mapping__c WHERE SA__c = : contactId[0] AND SA__c !=null];
        result.add(pm);
        return result;
    }
}