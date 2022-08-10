public class LeadReAssign {
    
    @InvocableMethod(label='Get Users'  category='Other')
    public static List<List<User>> getUsers(List<Id> LeadId){
        Lead l = [Select Pincode__c,ownerid, TL2__r.ContactId from Lead where Id =: LeadId[0]];
        
        Set<Id> contactSet = new Set<Id>();
        List<SA_Pincode_Mapping__c > pinMap = new List<SA_Pincode_Mapping__c>();
        if(l.TL2__r.ContactId == null){
            pinMap =  [Select SA__c from SA_pincode_mapping__c where service__c ='SPS' AND Pincode_lookup__r.Name = : l.Pincode__c ];
                }    
        
        else{
            pinMap =  [Select SA__c from SA_pincode_mapping__c where service__c ='SPS' AND Pincode_lookup__r.Name = : l.Pincode__c AND TL2__c = : l.TL2__r.ContactId];
                
                }
        for(SA_Pincode_Mapping__c p : pinMap){
            contactSet.add(p.SA__c);
        }
        List<User> uL = [Select id, name, User_Name__c from User where ContactId IN : contactSet AND isActive =True AND ID !=: l.ownerId];
        
        List<List<user>> ull= new List<List<user>>();
        ull.add(ul);
        
        return ull;
    }
    
}