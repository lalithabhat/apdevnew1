public class ServiceabilityManagement {
    public static void checkLeadServiceability(List<Lead> leadList) {
        // Find all the services & backup services from custom setting
        Map<String, Lead_Service__c> leadServiceMap = Lead_Service__c.getAll();
        //Find all the record type
        Map<Id,Schema.RecordTypeInfo> rtMap = Lead.sobjectType.getDescribe().getRecordTypeInfosById();
        
        for(Lead l: leadList) {
            Integer count = 1;
            Boolean result = false;
            String requestedRTName = rtMap.get(l.RecordTypeId).getDeveloperName();
            
            do {
                if(count == 1) {
                    l.Process_Type__c = requestedRTName+'_'+requestedRTName;	//l.Skills__c;
                    result = getLeadServiceable(l, rtMap);
                } else {
                    if(leadServiceMap.containsKey(rtMap.get(l.RecordTypeId).getDeveloperName())) {
                        if(leadServiceMap.get(rtMap.get(l.RecordTypeId).getDeveloperName()).Backup_Service__c != null) {
                            String service = leadServiceMap.get(rtMap.get(l.RecordTypeId).getDeveloperName()).Backup_Service__c;
                            l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get(service).getRecordTypeId();
                            l.Skills__c = service;
                            l.Process_Type__c = 'REGRET'+requestedRTName+'_'+rtMap.get(l.RecordTypeId).getDeveloperName();
                            result = getLeadServiceable(l, rtMap);
                        } else {
                            result = true;
                        }
                    } else {
                        //Logic will not go in this if all services & respective backup services maintained in custom setting
                        l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('TCS').getRecordTypeId();
                        l.Skills__c = 'TCS';
                        l.Process_Type__c = 'REGRET'+requestedRTName+'_'+rtMap.get(l.RecordTypeId).getDeveloperName();
                        result = true;
                    }
                }
                count++;
            } while (!result);
        }
    }
    
    public static void assignBotProcessTypeonLead(List<Lead> leadList) {
        Map<String, Map<String, Set<String>>> pincodeCoverageMap = new Map<String, Map<String, Set<String>>>();
        Map<Id,Schema.RecordTypeInfo> rtMap = Lead.sobjectType.getDescribe().getRecordTypeInfosById();
        Map<String, Lead_Service__c> leadServiceMapforBot = getLeadServicesforBot();
        Set<String> servicePincodeSet = new Set<String>();
        
        for(Lead l: leadList) {
            if(leadServiceMapforBot.containsKey(rtMap.get(l.RecordTypeId).getDeveloperName())) {
                servicePincodeSet.add(l.Pincode__c);
            }
        }
        
        if(servicePincodeSet != null && leadServiceMapforBot != null)
            pincodeCoverageMap = getBotProcessTypeforLead(servicePincodeSet, leadServiceMapforBot.keySet());
        
        for(Lead l: leadList) {
            if(!pincodeCoverageMap.isEmpty()) {
                if(pincodeCoverageMap.containsKey(l.Pincode__c)) {
                    Map<String, Set<String>> innerPincodeCoverageMap = pincodeCoverageMap.get(l.Pincode__c);
                	
                    if(rtMap.get(l.RecordTypeId).getDeveloperName().equalsIgnoreCase('BHS')) {
                    	if(innerPincodeCoverageMap.containsKey('BHS')) {
                            if(innerPincodeCoverageMap.containsKey('SPS')) {
                                if(innerPincodeCoverageMap.get('SPS').contains('SA')) {
                                    l.Bot_Process_Type__c = 'BHS_SPS_SA';
                                    l.YM_Campaign_Code__c = 'BHS_SPS_SA';
                                } else if(innerPincodeCoverageMap.get('SPS').contains('CA')) {
                                    l.Bot_Process_Type__c = 'BHS_SPS_CA';
                                    l.YM_Campaign_Code__c = 'BHS_SPS_CA';
                                } else {
                                    l.Bot_Process_Type__c = 'BHS_NO_SERVICE';
                                    l.YM_Campaign_Code__c = 'BHS_NO_SERVICE';
                                }
                            } else {
                                l.Bot_Process_Type__c = 'BHS_NO_SERVICE';
                                l.YM_Campaign_Code__c = 'BHS_NO_SERVICE';
                            }
                        } else {
                            if(innerPincodeCoverageMap.containsKey('SPS')) {
                                if(innerPincodeCoverageMap.get('SPS').contains('SA')) {
                                    l.Bot_Process_Type__c = 'REGRETBHS_SA';
                                    l.YM_Campaign_Code__c = 'REGRETBHS_SA';
                                } else if(innerPincodeCoverageMap.get('SPS').contains('CA')) {
                                    l.Bot_Process_Type__c = 'REGRETBHS_CA';
                                    l.YM_Campaign_Code__c = 'REGRETBHS_CA';
                                }
                            }
                        }
                    } else if(rtMap.get(l.RecordTypeId).getDeveloperName().equalsIgnoreCase('SPS')) {
                        if(innerPincodeCoverageMap.containsKey('SPS')) {
                            if(innerPincodeCoverageMap.containsKey('BHS')) {
                                if(innerPincodeCoverageMap.get('SPS').contains('SA')) {
                                    l.Bot_Process_Type__c = 'BHSINTRO_SPS_SA';
                                    l.YM_Campaign_Code__c = 'BHSINTRO_SPS_SA';
                                } else if(innerPincodeCoverageMap.get('SPS').contains('CA')) {
                                    l.Bot_Process_Type__c = 'BHSINTRO_SPS_CA';
                                    l.YM_Campaign_Code__c = 'BHSINTRO_SPS_CA';
                                }
                            } else {
                                if(innerPincodeCoverageMap.get('SPS').contains('SA')) {
                                    l.Bot_Process_Type__c = 'SPS_SA';
                                    l.YM_Campaign_Code__c = 'SPS_SA';
                                } else if(innerPincodeCoverageMap.get('SPS').contains('CA')) {
                                    l.Bot_Process_Type__c = 'SPS_CA';
                                    l.YM_Campaign_Code__c = 'SPS_CA';
                                } else {
                                    l.Bot_Process_Type__c = 'NO_SERVICE';
                                    l.YM_Campaign_Code__c = 'NO_SERVICE';
                                }
                            }
                        } else {
                            l.Bot_Process_Type__c = 'NO_SERVICE';
                            l.YM_Campaign_Code__c = 'NO_SERVICE';
                        }
                    }
                }
            } else {
                if(rtMap.get(l.RecordTypeId).getDeveloperName().equalsIgnoreCase('SPS')) {
                    l.Bot_Process_Type__c = 'NO_SERVICE';
                	l.YM_Campaign_Code__c = 'NO_SERVICE';
                }
            }
        }
    }
    
    public static Map<String, Map<String, Set<String>>> getBotProcessTypeforLead(Set<String> servicePincodeSet, Set<String> servicesSet) {
        Map<String, Map<String, Set<String>>> pincodeCoverageMap = new Map<String, Map<String, Set<String>>>();
        
        List<SA_Pincode_Mapping__c> pincodeList = [Select Id, Service__c, Pincode__c, SA__r.Persona__c from SA_Pincode_Mapping__c 
                                                   where Service__c IN: servicesSet AND Pincode__c IN: servicePincodeSet];
        
        if(pincodeList != null) {
            for(SA_Pincode_Mapping__c p: pincodeList) {
                if(!pincodeCoverageMap.containsKey(p.Pincode__c)) {
                    Map<String, Set<String>> newMap = new Map<String, Set<String>>();
                    Set<String> roleSet = new Set<String>();
                    roleSet.add(p.SA__r.Persona__c);
                    newMap.put(p.Service__c, roleSet);
                    pincodeCoverageMap.put(p.Pincode__c, newMap);
                } else {
                    Map<String, Set<String>> getMap = pincodeCoverageMap.get(p.Pincode__c);
                    
                    if(!getMap.containsKey(p.Service__c)) {
                        Set<String> roleSet = new Set<String>();
                        roleSet.add(p.SA__r.Persona__c);
                        getMap.put(p.Service__c, roleSet);
                    } else {
                        getMap.get(p.Service__c).add(p.SA__r.Persona__c);
                    }
                    pincodeCoverageMap.put(p.Pincode__c, getMap);
                }
            }
        }
        return pincodeCoverageMap;
    }
    
    public static Map<String, Lead_Service__c> getLeadServicesforBot() {
        Map<String, Lead_Service__c> leadServiceMapforBot = new Map<String, Lead_Service__c>();
        List<Lead_Service__c> leadServiceList = [Select Id, Name, Backup_Service__c, Bot_Consider__c from Lead_Service__c where Bot_Consider__c = true
                                                 ORDER BY Name ASC];
        
        if(leadServiceList != null) {
            for(Lead_Service__c ls: leadServiceList) {
                leadServiceMapforBot.put(ls.Name, ls);
            }
        }
        return leadServiceMapforBot;
    }
    
    public static boolean getLeadServiceable(Lead l, Map<Id,Schema.RecordTypeInfo> rtMap) {
        List<SA_Pincode_Mapping__c> pincodeList = new List<SA_Pincode_Mapping__c>();
        String recTypeName = rtMap.get(l.RecordTypeId).getDeveloperName();
        
        pincodeList = [Select Id from SA_Pincode_Mapping__c where Service__c =: recTypeName AND Pincode__c =: l.Pincode__c AND SA__r.Active__c = True];
        system.debug('pincodeList: '+pincodeList);
        
        if(!pincodeList.isEmpty())
            return true;
        else
            return false;
    }
    
    public static boolean getLeadServiceableFromBot(String pincode, String BU) {
        List<SA_Pincode_Mapping__c> pincodeList = [Select Id from SA_Pincode_Mapping__c where Service__c =: BU AND Pincode__c =: pincode  AND SA__r.Active__c = True];
        system.debug('pincodeList: '+pincodeList);
         
        if(!pincodeList.isEmpty())
            return true;
        else
            return false;
    }
    
    public static boolean IsExistingLeadAvailable(String pincode, String BU, string mobile) {
        system.debug('pincode::'+pincode);
        system.debug('BU::'+BU);
        system.debug('mobile::'+mobile);
        List<Lead> leadList = [select id,name,recordType.Name from Lead where MobilePhone =: mobile and
                              recordType.Name =: BU and pincode__c =: pincode and isConverted = false AND Active__c = true];
        system.debug('leadList::'+leadList);
        if(leadList != null && !leadList.isEmpty()){
            return true;
        }else{
            return false;
        }
        
    }
    
    public static string createCrossLead(Lead originalLead, string BU, string leadRating, string description, boolean WtsSendFlag) {
        try{
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true; 
            dml.optAllOrNone = true;
            Lead lList =[SELECT ID, FirstName, LastName, Pincode__c, MobilePhone, Email, CampaignName__c, Pincode_lookup__c,
                         Campaign_Code__c, LeadSource
                         FROM Lead WHERE ID =: originalLead.Id][0];
            Lead l =  lList.clone(false, false, false, false);
            system.debug('RecordTypeId::'+Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(BU).getRecordTypeId());
            l.RecordTypeId =  Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(BU).getRecordTypeId();
            l.Cross_Sell_By__c = 'YM API';
            l.Inter_Related_BU_1__c = originalLead.Id;
            l.Rating = leadRating;
            l.Whatsapp_Notification__c = WtsSendFlag;
            l.description = description;
            l.Pincode__c = lList.Pincode__c;
            l.Pincode_lookup__c = lList.Pincode_lookup__c;
            //l.Service_Territory__c = lList.Service_Territory__c;
            /*if(BU == 'BHS'){
                set<string> pincodeSet = new set<string>();
                pincodeSet.add(l.Pincode__c);
                system.debug('pincodeSet::'+pincodeSet);
            	Map<String, Service_Territory__c> bhsMap = AP_ServiceTerritoryManagementService.getTerritoryforBHS(pincodeSet);
                system.debug('bhsMap::'+bhsMap);
                if(bhsMap != null && !bhsMap.isEmpty() && bhsMap.containsKey(l.Pincode__c)){
                    system.debug('hi:::');
                    if(bhsMap.get(l.Pincode__c).Parent__c != null){
                        system.debug('bye:::');
                        l.Service_Territory__c = bhsMap.get(l.Pincode__c).Parent__r.Id;
                    }
                }
        	}*/
            Database.SaveResult sr = Database.insert(l,dml);
            return sr.getId();
        }catch(Exception ex){
            return 'Failed';
        }
        
    }
}