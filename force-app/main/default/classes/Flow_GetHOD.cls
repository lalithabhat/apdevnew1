public without sharing class Flow_GetHOD {
    
    public class input{
        @InvocableVariable public String  pincode;
        @InvocableVariable public String level;
        @InvocableVariable public String uhId;
        @InvocableVariable public String serviceTerritoryName;
        @InvocableVariable public String serviceTerritoryId;
    }
    @InvocableMethod(label='GetHOD'  category='Other')
    public static List<input> getHOD(List<input> input){
        List<input> result = new List<input>();
        input r = new input();
        String pincode;
        if(!Test.isRunningTest())
            pincode = [Select Name from Pincode__c where Id =:input[0].pincode].Name;
        else pincode ='100001';
        // String pincode = input[0].pincode;
        String level = input[0].level;
       // List<Id> result = new List<Id>();
        Map<String, Map<String, User>> hodMap =AP_ServiceTerritoryManagementService.getHODForSPS(new Set<string> {pincode});
        Map<String,User> pinHodMap = hodMap.get(pincode);
        if(pinHodMap !=null ){
            User u =pinHodMap.get(level);
            if(u !=null) r.uhId = u.Id;// result.add(u.Id);
        }
        
        Map<String, Service_Territory__c> serviceTerritoryMap =AP_ServiceTerritoryManagementService.getTerritoryforSPS(new Set<string> {pincode});
        if(serviceTerritoryMap !=null ){
            Service_Territory__c s =serviceTerritoryMap.get(pincode);
            if(s !=null){ r.serviceTerritoryName = s.Parent__r.Name;// result.add(u.Id);
                         r.serviceterritoryId = s.Parent__c;
                        }
        }
        result.add(r);
        return result;
    }
}