public with sharing class CampaignManagementServices {
    public static void AssignCampaignInfoToLead(Lead l) {
        List<Campaign> CampaignList = [Select Id, Name, BU__c, Sub_Service__c, Source__c, Digital_Marketing_Campaign_Code__c From Campaign 
                                       where Digital_Marketing_Campaign_Code__c =: l.Campaign_Code__c AND isActive = true]; 
        System.debug('CampaignList: '+CampaignList);
        
        if(!CampaignList.isEmpty()) {
            l.CampaignName__c = CampaignList[0].Id;
            l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get(CampaignList[0].BU__c).getRecordTypeId();
            //l.Service__c = campaignList[0].BU__c;
            l.Skills__c = campaignList[0].Sub_Service__c;
            l.LeadSource = campaignList[0].Source__c;
        } else {
            l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        }
    }
    
    public static void AddCampaignToLead(List<Lead> leadList) {
        //Based on EnquiryMode for CALLS
        Map<String,List<String>> campaignDetails = new Map<String,List<String>>();
        
        //collect the campaign codes or toll free numbers into a list and put them into appropriate buckets [mapkeys]
        for(lead l:leadList) {
            if(l.Campaign_Code__c != null)  {
                if(campaignDetails.containsKey('CAMPAIGNCODE')) {
                    campaignDetails.get('CAMPAIGNCODE').add(l.Campaign_Code__C);
                } else {
                    List<String> codeList = new List<String>();
                    codeList.add(l.Campaign_Code__C);
                    campaignDetails.put('CAMPAIGNCODE', codeList);
                }
            }
        }
        Map<String,Campaign> searchResults = new Map<String,Campaign>();
        
        System.debug('CampaignDetails:' + CampaignDetails);
        if(campaignDetails != null && !campaignDetails.isEmpty())   
            searchResults = searchCampaign(CampaignDetails);
        
        // create a Map like below
        // [campaingnA, [List of Lead to add to that campaign]
        //   campaignB, [List of leads to add to that campaign]]
        Map<Campaign,List<lead>> campaignMap = new Map<Campaign,List<Lead>>();
        
        for(lead l: leadList) {
            if(searchResults.containsKey(l.Campaign_Code__c)) {
                Campaign c= searchResults.get(l.Campaign_Code__c);
                if(campaignMap.containsKey(c)){
                    campaignMap.get(c).add(l);
                } else {
                    List<lead> ll = new List<Lead>();
                    ll.add(l);
                    campaignMap.put(c,ll);
                }
            }            
        }
        addCampaignToLead(campaignMap);
    }
    
    /* Method searches campaign details based on tollfree number, campaign code or campaign Id
  
    /* send a map bucketed by fieldName and the list of campaign codes 
    to search from the campaign object. For example:
    TollFreeNumber, [18002525,1800555]
    CampaignCode,[1234,2222,8888] 
    CampaignId, [CrecordId1, CRecordId2]*/

    public static Map < String, Campaign > searchCampaign(Map < String, List < String >> campaignDetails) {
        List < Campaign > searchRes1 = new List < Campaign > ();
        List < Campaign > searchRes2 = new List < Campaign > ();
        List < Campaign > searchRes3 = new List < Campaign > ();

        if (!campaignDetails.isEmpty() && campaignDetails.containsKey('CAMPAIGNCODE')) {
            for (Integer i = 0; i < campaignDetails.get('CAMPAIGNCODE').size(); i++) {
                if (campaignDetails.get('CAMPAIGNCODE').get(i) == null) {
                    campaignDetails.get('CAMPAIGNCODE').remove(i);
                }
            }
            searchRes2 = [select Name, CreatedDate, isActive, StartDate, EndDate, Digital_Marketing_Campaign_Code__c from
                Campaign where Digital_Marketing_Campaign_Code__c in : campaignDetails.get('CAMPAIGNCODE') and isActive = true];
        }

        // added logic to search by campaign id
        Map < String, Campaign > searchResponse = new Map < String, Campaign > ();
        for (campaign c: searchRes2) {
            if (!searchResponse.containsKey(c.Digital_Marketing_Campaign_Code__c)) searchResponse.put(c.Digital_Marketing_Campaign_Code__c, c);
        }
        return searchResponse;
    }

    public static void AddCampaignToLead(Map < Campaign, List < Lead >> campaignMap) {
        List < CampaignMember > cmList = new List < campaignMember > ();

        if (campaignMap != null && !campaignMap.isEmpty()) {
            for (Campaign c: campaignMap.keyset()) {
                for (lead eachLead: campaignMap.get(c)) {
                    CampaignMember cm = new CampaignMember(CampaignId = c.Id, LeadId = eachLead.Id, Status = 'Responded');
                    cmList.add(cm);
                }
            }
        }
        try {
            Database.saveResult[] srList = Database.insert(cmList, false);
            List < String > customMsgList = new List < String > ();

            for (Database.SaveResult sr: srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted members. member ID: ' + sr.getId());
                } else {
                    // Operation failed, so get all errors  
                    for (Database.Error err: sr.getErrors()) {
                        if (err.getMessage().equals('This entity is already a member of this campaign') || err.getMessage().contains('more than once')) {
                            System.debug('Ignore error: Lead already a member error');
                        } else {
                            customMsgList.add(err.getMessage());
                        }
                    }
                }
            }
            if (customMsgList != null && !customMsgList.isEmpty()) {
                System.debug('Campaign Member Insert Error:' + customMsgList);
                throw new GlobalException(customMsgList, '', 'CampaignManagmentServices.AddCampaignToLead()');
            }
        } catch (System.DmlException ex) {
            List < String > customMsgList = new List < String > ();
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                String msg = 'Campaign Member Insert Failed :' + ex.getMessage();
                customMsgList.add(msg);
            }
            throw new GlobalException(customMsgList, '', 'CampaignManagmentServices.AddCampaignToLead()');
        }
    }
}