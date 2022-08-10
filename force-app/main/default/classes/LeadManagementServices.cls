public class LeadManagementServices{

    public static List<DupResultsDTO> leadPreProcessing(List<Lead> LeadList, String context){
       
        Map<Lead,List<Lead>> leadEmailDupMap = DedupeChecker.findLeadDupeforLeads('EMAIL', leadList);
        system.debug('leadEmailDupMap: '+leadEmailDupMap);
        Map<Lead,List<Account>> personAccountEmailDup = DedupeChecker.findPADupeforLeads('EMAIL',leadList);
        system.debug('personAccountEmailDup: '+personAccountEmailDup);
        /*Map<Lead,List<Lead>> leadAltEmailDupMap = DedupeChecker.findLeadDupeforLeads('ALTEMAIL', leadList);
      
        Map<Lead,List<Account>> personAccountAltEmailDup = DedupeChecker.findPADupeforLeads('ALTEMAIL',leadList);*/
        
        Map<Lead, List<Lead>> leadMobileDupMap  = DedupeChecker.findLeadDupeforLeads('MOBILE', leadList);
        system.debug('leadMobileDupMap: '+leadMobileDupMap);
        Map<Lead,List<Account>>  PAMobileDupMap = DedupeChecker.findPADupeforLeads('MOBILE',leadList);
        system.debug('PAMobileDupMap: '+PAMobileDupMap);
        /*Map<Lead, List<Lead>> leadAltMobileDupMap  = DedupeChecker.findLeadDupeforLeads('ALTMOBILE', leadList);
              
        Map<Lead,List<Account>>  PAAltMobileDupMap = DedupeChecker.findPADupeforLeads('ALTMOBILE',leadList);*/
      
        Map<Lead, Map<String, List<Id>>> leadDupAgg = DedupeChecker.aggregateLeadDuplicates(leadEmailDupMap, leadMobileDupMap, personAccountEmailDup, PAMobileDupMap/*, leadAltEmailDupMap, leadAltMobileDupMap,personAccountAltEmailDup, PAAltMobileDupMap*/ );
        system.debug('leadDupAgg: '+leadDupAgg);
        List<DupResultsDTO> dupResults = new List<DupResultsDTO>();
        if(leadDupAgg!=null & !leadDupAgg.isEmpty()) {
            dupResults = DedupeChecker.dupHandler(leadDupAgg, context);
        }
        return dupResults;
    }  
    
    public static Map<Id, String> validateLeadDetails(List<Lead> leadList) {
        //Used for validation purpose
        Map<Id, String> leadValidationMap = new Map<Id, String>();
        String regex = '^[a-z A-Z]*$'; // String to check if there are only alphabets in the string
        
        for(Lead l: leadList) {
            if(!String.isBlank(l.FirstName)) {
                system.debug('In First Name');
                Matcher mFirstName = Pattern.compile(regex).matcher(l.FirstName); // This will check if the Firstname is only string
                if(!mFirstName.matches()) {
                    leadValidationMap.put(l.Id, 'Please Enter Only Text in First Name.');
                }
            }
            if(String.isBlank(l.LastName)) {
                system.debug('In Last Name Blank');
                leadValidationMap.put(l.Id, 'Please Provide Last Name.');
            } else {
                system.debug('In Last Name');
                Matcher mLastName = Pattern.compile(regex).matcher(l.LastName); // This will check if the Lastname is only string
                if(!mLastName.matches()) {
                    leadValidationMap.put(l.Id, 'Please Enter Only Text in Last Name.');
                }
            }
            if(l.MobilePhone == null || l.MobilePhone == '') {
                system.debug('In Mobile Blank');
                leadValidationMap.put(l.Id, 'Please Provide Mobile No.');
            } else {
                system.debug('In Mobile');
                if(!l.MobilePhone.isNumeric()) {
                    leadValidationMap.put(l.Id, 'Please Provide Valid Mobile No.');
                } else if(l.MobilePhone.length() != 10) {
                    leadValidationMap.put(l.Id, 'Please Provide 10 Digit Mobile No.');
                }
            } 
            if(!String.isBlank(l.Email)) { //l.Email != null && l.Email != ''
                system.debug('In Email');
                if(!Pattern.matches('([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})', l.Email)) {
                    leadValidationMap.put(l.Id, 'Please Provide Valid Email Address.');
                }
            }
            if(!String.isBlank(l.Pincode__c)) {
                if(l.Pincode__c.length() != 6) {
                    leadValidationMap.put(l.Id, 'Please Provide Valid Pincode');
                }
            }
            if(!String.isBlank(l.Referral_Type__c)) { //l.Referral_Type__c != null && l.Referral_Type__c != ''
                system.debug('In Referral');
                if(String.isBlank(l.Referrer_Name__c)) { // l.Referrer_Name__c == null || l.Referrer_Name__c == ''
                    leadValidationMap.put(l.Id, 'Please Provide Referrer Name');
                }
                if(String.isBlank(l.Referrer_Mobile__c)) { //l.Referrer_Mobile__c == null || l.Referrer_Mobile__c == ''
                    leadValidationMap.put(l.Id, 'Please Provide Referrer Mobile');
                }
            }
        }
        return leadValidationMap;
    }

    Public static Map<Lead,AOD_Master__c> getServiceId(List<Lead> llist){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name='Lead Creation Business Hours'];
        set<string> pincodes = new set<string>();
        map<string,string> stateMap = new Map<string,string>();
        set<Id> campaignIds = new Set<Id>();
        if(llist != null && !llist.isEmpty()){
            for(lead l : llist){
                if(l.Pincode__c != null){
                    pincodes.add(l.Pincode__c);
                }
                if(l.CampaignName__c != null){
                    campaignIds.add(l.CampaignName__c);
                }
            }
        }
        system.debug('pincodes:: '+pincodes);
        system.debug('campaignIds:: '+campaignIds);
        if(!pincodes.isEmpty()){
            for(Pincode__c p : [select id,name,State__c from Pincode__C where Name IN: pincodes]){
                stateMap.put(p.name,p.State__c);
            }
        }
        
        Map<string,AOD_Master__c> AOD_Map = new Map<string, AOD_Master__c>();
        for(AOD_Master__c ad : [select id,name,State__c,Service_Id__c,Campaign__c,Schedule__c,
                               Concatenation__c from AOD_Master__c where Campaign__c IN:campaignIds]){
            AOD_Map.put(ad.Concatenation__c,ad);
        }
        system.debug('stateMap:: '+stateMap);
        system.debug('AOD_Map:: '+AOD_Map);
        
        Map<Lead,AOD_Master__c> lead_AOD_Map = new Map<Lead,AOD_Master__c>();
        for(lead l : llist){
            system.debug('Inside for Loop-->'+l);
            string schedule;
            if(BusinessHours.isWithin(bh.id, system.now())){ //l.CreatedDate
                schedule = 'IN';
            }else{
                schedule = 'OUT';
            }
            string state = '';
            if(stateMap.containskey(l.Pincode__c)){
               state = stateMap.get(l.Pincode__c);
            }
            string process_Type = '';
            process_Type = l.Process_Type__c;
            system.debug('l.CampaignName__c-->'+l.CampaignName__c);
            string campaignId =  string.valueOf(l.CampaignName__c).substring(0,string.valueOf(l.CampaignName__c).length()-3);
            string key = '';
            if(string.isNotBlank(campaignId) && string.isNotBlank(schedule) && string.isNotBlank(process_Type) 
               && string.isNotBlank(state)){
                key = campaignId + schedule + state + process_Type;
            }
            system.debug('key::'+key);
            if(string.isNotBlank(key) && AOD_Map.containsKey(key)){
                lead_AOD_Map.put(l, AOD_Map.get(key) );
            }else if(string.isNotBlank(state) && AOD_Map.containsKey(campaignId + state + process_Type)){
                lead_AOD_Map.put(l, AOD_Map.get(campaignId + state + process_Type) );
            }else if(string.isNotBlank(state) && AOD_Map.containsKey(campaignId + schedule + state)){
                lead_AOD_Map.put(l, AOD_Map.get(campaignId + schedule + state) );
            }else if(string.isNotBlank(state) && AOD_Map.containsKey(campaignId + state)){
                lead_AOD_Map.put(l, AOD_Map.get(campaignId + state) );
            }else if(AOD_Map.containsKey(campaignId + schedule + process_Type)){
                lead_AOD_Map.put(l, AOD_Map.get(campaignId + schedule + process_Type) );
            }else if(AOD_Map.containsKey(campaignId + schedule)){
                lead_AOD_Map.put(l, AOD_Map.get(campaignId + schedule) );
            }else if(AOD_Map.containsKey(campaignId + process_Type)){
                lead_AOD_Map.put(l, AOD_Map.get(campaignId + process_Type) );
            }else if(AOD_Map.containsKey(campaignId)){
                lead_AOD_Map.put(l, AOD_Map.get(campaignId) );
            }else{
                
            }
        }
        
        system.debug('lead_AOD_Map:: '+lead_AOD_Map);
        
        return lead_AOD_Map;
    } 
}