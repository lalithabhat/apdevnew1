/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 26-08-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and filter all the Opportunity based on the trigger actions.
*********************************************************************************************************/
public class AP_OpportunityTriggerHandler {
	public static void onBeforeInsert(List<Opportunity> opportunityList) {
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> ownerId = new Set<Id>();
        
        for(Opportunity op: opportunityList) {
            if(!op.Is_Converted__c) {
                oppList.add(op);
                ownerId.add(op.OwnerId);
            }
        }
        if(!oppList.isEmpty() && oppList != null)
            AP_OpportunityManagementService.tagServiceTerritoryDetail(oppList);
        if(!ownerId.isEmpty() && !oppList.isEmpty())
            AP_OpportunityManagementService.updateAssignmentDateTime(ownerId, oppList);
    }
    
    public static void onAfterInsert(Map<Id, Opportunity> newOpportunityMap) {
        List<Opportunity> BhChildOpportunities = new List<Opportunity>(); //by raghu
        List<Opportunity> OpptList = new List<Opportunity>();
        Map<Id, Set<Id>> apexShareUserMap = new Map<Id, Set<Id>>();
        //Map<Id, Set<Id>> apexShareUserAccountMap = new Map<Id, Set<Id>>();
         OpptList = [Select Id,BH_Store_Opportunity__c, Name, RecordTypeId from Opportunity where Id IN: newOpportunityMap.keySet()];//BH_Store_Opportunity__c  --- added
       if(!OpptList.isEmpty()) {
            for(Opportunity opp: OpptList) {
                if(opp.BH_Store_Opportunity__c != Null){
                    BhChildOpportunities.add(opp);
                }
            }
       }
        
        for(Opportunity op: newOpportunityMap.values()) {
            // Create Apex Sharing With TL1 & TL2 //
            if(op.Team_Lead_1_TL1__c != null) {
                if(apexShareUserMap.containsKey(op.Id)) {
                    apexShareUserMap.get(op.Id).add(op.Team_Lead_1_TL1__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(op.Team_Lead_1_TL1__c);
                    apexShareUserMap.put(op.Id, idSet);
                }
                /*if(apexShareUserAccountMap.containsKey(op.AccountId)) {
                    apexShareUserAccountMap.get(op.AccountId).add(op.Team_Lead_1_TL1__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(op.Team_Lead_1_TL1__c);
                    apexShareUserAccountMap.put(op.AccountId, idSet);
                }*/
            }
            if(op.Team_Lead_2_TL2__c != null) {
                if(apexShareUserMap.containsKey(op.Id)) {
                    apexShareUserMap.get(op.Id).add(op.Team_Lead_2_TL2__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(op.Team_Lead_2_TL2__c);
                    apexShareUserMap.put(op.Id, idSet);
                }
                /*if(apexShareUserAccountMap.containsKey(op.AccountId)) {
                    apexShareUserAccountMap.get(op.AccountId).add(op.Team_Lead_2_TL2__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(op.Team_Lead_2_TL2__c);
                    apexShareUserAccountMap.put(op.AccountId, idSet);
                }*/
            }
            /*if(op.SSO__c != null) {
                if(apexShareUserAccountMap.containsKey(op.AccountId)) {
                    apexShareUserAccountMap.get(op.AccountId).add(op.SSO__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(op.SSO__c);
                    apexShareUserAccountMap.put(op.AccountId, idSet);
                }
            }
            if(op.Division_Head_DH__c != null) {
                if(apexShareUserAccountMap.containsKey(op.AccountId)) {
                    apexShareUserAccountMap.get(op.AccountId).add(op.Division_Head_DH__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(op.Division_Head_DH__c);
                    apexShareUserAccountMap.put(op.AccountId, idSet);
                }
            }
            if(op.Unit_Head_UH__c != null) {
                if(apexShareUserAccountMap.containsKey(op.AccountId)) {
                    apexShareUserAccountMap.get(op.AccountId).add(op.Unit_Head_UH__c);
                } else {
                    Set<Id> idSet = new Set<Id>();
                    idSet.add(op.Unit_Head_UH__c);
                    apexShareUserAccountMap.put(op.AccountId, idSet);
                }
            }*/
        }
        if(!BhChildOpportunities.isEmpty()){
            AP_OpportunityManagementService.updateChildOpportunities(BhChildOpportunities);
        }
        if(apexShareUserMap != null)
            AP_ApexSharingService.opportunityApexShare(apexShareUserMap);
        //if(apexShareUserAccountMap != null)
            //AP_ApexSharingService.accountApexShare(apexShareUserAccountMap);
    }
	
	public static void onBeforeUpdate(Map<Id, Opportunity> oldOpportunityMap, Map<Id, Opportunity> newOpportunityMap) {
        Id recId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> ownerId = new Set<Id>();
        
        for(Opportunity opportunity : newOpportunityMap.values()) {
            Opportunity oldOpportunity = oldOpportunityMap.get(opportunity.Id);
            if(opportunity.RecordTypeId == recId && opportunity.OwnerId != oldOpportunity.OwnerId) {
            	ownerId.add(opportunity.OwnerId);
            	oppList.add(opportunity);
            }
        }
        if(!ownerId.isEmpty() && !oppList.isEmpty())
            AP_OpportunityManagementService.updateAssignmentDateTime(ownerId, oppList);
    }
    
    
    public static void onAfterUpdate(Map<Id, Opportunity> oldOpportunityMap, Map<Id, Opportunity> newOpportunityMap) {
        List<Opportunity> BhChildOpportunities = new List<Opportunity>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        Id recId = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Set<Id> oppIds = new Set<Id>();
        Set<Id> userId = new Set<Id>();
        Set<Id> contractorIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id, Set<Id>> apexShareUserMap = new Map<Id, Set<Id>>();
        //Map<Id, Set<Id>> apexShareUserAccountMap = new Map<Id, Set<Id>>();
        
        //This code is for Sum of amount from child opportunity to parent Opportunity Field Total "Amount" in the updation event
        for(Opportunity opp: newOpportunityMap.values()){
             if(opp.BH_Store_Opportunity__c != null && opp.Amount != oldOpportunityMap.get(opp.Id).Amount){
                 oppIds.add(opp.BH_Store_Opportunity__c);
             }
         }
            List<Opportunity> oppToBeUpdated = new List<Opportunity>();
            if(!oppIds.isEmpty() && oppIds.size() > 0){
            for(AggregateResult ar : [SELECT BH_Store_Opportunity__c OpportunityId,Sum(Amount) AmountSum FROM Opportunity WHERE BH_Store_Opportunity__c in:oppIds GROUP BY BH_Store_Opportunity__c]){
            Opportunity opp = new Opportunity();
            opp.id = (Id) ar.get('OpportunityId');
            opp.Amount = (Decimal) ar.get('AmountSum');
            oppToBeUpdated.add(opp);
        }
        }
        Update oppToBeUpdated;   
        
        opportunityList = [Select Id, BH_Store_Opportunity__c,Name,Amount, RecordTypeId, StageName, Primary_Contractor__c, Owner.Profile.UserLicense.Name, Owner.ContactId,
                           Team_Lead_1_TL1__c, Team_Lead_2_TL2__c, SSO__c, Division_Head_DH__c, Unit_Head_UH__c, AccountId
                           from Opportunity where Id IN: newOpportunityMap.keySet() AND RecordTypeId =: recId ];
        
        if(!opportunityList.isEmpty()) {
            for(Opportunity opp : opportunityList) {
               if(opp.BH_Store_Opportunity__c != Null){
                    BhChildOpportunities.add(opp);
                }
               /* for(Opportunity opp1 : oldOpportunityMap.values()){
                if(opp1.BH_Store_Opportunity__c != Null && opp1.BH_Store_Opportunity__c != newOpportunityMap.get(opp1.Id).BH_Store_Opportunity__c){
                    BhChildOpportunities.add(opp1);
                }
                }  */ 
        	for(Opportunity opportunity : opportunityList) {
            	Opportunity oldOpportunity = oldOpportunityMap.get(opportunity.Id);
                /* 
                ** Scenarios for dealer blocked capacity:
                1] Opportunity moved to closed stages.
                2] Assigning / Reassigning primary contractor 
                */
                if(opportunity.StageName != oldOpportunity.StageName && opportunity.Primary_Contractor__c != null && (opportunity.StageName == 'Closed Won' || opportunity.StageName == 'Closed Lost'))
                    contractorIdSet.add(opportunity.Primary_Contractor__c);
                if(opportunity.Primary_Contractor__c != oldOpportunity.Primary_Contractor__c && opportunity.Primary_Contractor__c != null) {
                    contractorIdSet.add(opportunity.Primary_Contractor__c);
                    if(oldOpportunity.Primary_Contractor__c != null)
                        contractorIdSet.add(oldOpportunity.Primary_Contractor__c);
                }
                /* 
                ** Scenarios for dealer open opportunity, last assignment datetime, last 7 day count:
                1] Opportunity moved closed stages.
                2] Assigning / Reassigning owner (SA-CA, CA1-CA2).
                */
                if(opportunity.StageName != oldOpportunity.StageName && (opportunity.StageName == 'Closed Won' || opportunity.StageName == 'Closed Lost')) {
                    if(opportunity.Owner.Profile.UserLicense.Name == 'Partner Community')
                    	contactIdSet.add(opportunity.Owner.ContactId);
                }
                if(opportunity.OwnerId != oldOpportunity.OwnerId) {
                    if(opportunity.Owner.Profile.UserLicense.Name == 'Partner Community') {
                    	contactIdSet.add(opportunity.Owner.ContactId);
                    	userId.add(opportunity.OwnerId);
                    }
                    if(oldOpportunity.Owner.Profile.UserLicense.Name == 'Partner Community') {
                    	contactIdSet.add(oldOpportunity.Owner.ContactId);
                    	userId.add(oldOpportunity.OwnerId);    
                    }
                }
                // Create Apex Sharing With TL1 & TL2 //
                if(opportunity.Team_Lead_1_TL1__c != oldOpportunity.Team_Lead_1_TL1__c) {
                    if(apexShareUserMap.containsKey(opportunity.Id)) {
                        apexShareUserMap.get(opportunity.Id).add(opportunity.Team_Lead_1_TL1__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(opportunity.Team_Lead_1_TL1__c);
                        apexShareUserMap.put(opportunity.Id, idSet);
                    }
                    /*if(apexShareUserAccountMap.containsKey(opportunity.AccountId)) {
                        apexShareUserAccountMap.get(opportunity.AccountId).add(opportunity.Team_Lead_1_TL1__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(opportunity.Team_Lead_1_TL1__c);
                        apexShareUserAccountMap.put(opportunity.AccountId, idSet);
                    }*/
                }
                if(opportunity.Team_Lead_2_TL2__c != oldOpportunity.Team_Lead_2_TL2__c) {
                    if(apexShareUserMap.containsKey(opportunity.Id)) {
                        apexShareUserMap.get(opportunity.Id).add(opportunity.Team_Lead_2_TL2__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(opportunity.Team_Lead_2_TL2__c);
                        apexShareUserMap.put(opportunity.Id, idSet);
                    }
                    /*if(apexShareUserAccountMap.containsKey(opportunity.AccountId)) {
                        apexShareUserAccountMap.get(opportunity.AccountId).add(opportunity.Team_Lead_2_TL2__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(opportunity.Team_Lead_2_TL2__c);
                        apexShareUserAccountMap.put(opportunity.AccountId, idSet);
                    }*/
                }
                /*if(opportunity.SSO__c != oldOpportunity.SSO__c) {
                    if(apexShareUserAccountMap.containsKey(opportunity.AccountId)) {
                        apexShareUserAccountMap.get(opportunity.AccountId).add(opportunity.SSO__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(opportunity.SSO__c);
                        apexShareUserAccountMap.put(opportunity.AccountId, idSet);
                    }
                }
                if(opportunity.Division_Head_DH__c != oldOpportunity.Division_Head_DH__c) {
                    if(apexShareUserAccountMap.containsKey(opportunity.AccountId)) {
                        apexShareUserAccountMap.get(opportunity.AccountId).add(opportunity.Division_Head_DH__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(opportunity.Division_Head_DH__c);
                        apexShareUserAccountMap.put(opportunity.AccountId, idSet);
                    }
                }
                if(opportunity.Unit_Head_UH__c != oldOpportunity.Unit_Head_UH__c) {
                    if(apexShareUserAccountMap.containsKey(opportunity.AccountId)) {
                        apexShareUserAccountMap.get(opportunity.AccountId).add(opportunity.Unit_Head_UH__c);
                    } else {
                        Set<Id> idSet = new Set<Id>();
                        idSet.add(opportunity.Unit_Head_UH__c);
                        apexShareUserAccountMap.put(opportunity.AccountId, idSet);
                    }
                }*/
            }
            }
             
        if(!BhChildOpportunities.isEmpty())
            AP_OpportunityManagementService.updateChildOpportunities(BhChildOpportunities);    
        if(!contractorIdSet.isEmpty() && contractorIdSet != null)
            AP_OpportunityManagementService.updateDealerBlockedCapacity(contractorIdSet);
        if(!contactIdSet.isEmpty() && contactIdSet != null)
            AP_OpportunityManagementService.calculateLeadOpporunityInfo(contactIdSet);
        if(!userId.isEmpty() && userId != null)
            AP_OpportunityManagementService.updateDealerAndCALastAssignment(userId);
        if(apexShareUserMap != null)
            AP_ApexSharingService.opportunityApexShare(apexShareUserMap);
        //if(apexShareUserAccountMap != null)
            //AP_ApexSharingService.accountApexShare(apexShareUserAccountMap);
    }
}
    
  /*  Public static void AfterUpdateChild(Map<Id, Opportunity> oldOpportunityMap, Map<Id, Opportunity> newOpportunityMap){
        Set<Id> oppIds = new Set<Id>();
       //  List<Opportunity> oppToBeUpdated = new List<Opportunity>();
         
         for(Opportunity opp: newOpportunityMap.values()){
             if(opp.BH_Store_Opportunity__c != null && opp.Amount != oldOpportunityMap.get(opp.Id).Amount){
                 oppIds.add(opp.BH_Store_Opportunity__c);
             }
         }
        List<Opportunity> oppToBeUpdated = new List<Opportunity>();
        
        if(!oppIds.isEmpty() && oppIds.size() > 0){
            for(AggregateResult ar : [SELECT BH_Store_Opportunity__c OpportunityId,Sum(Amount) AmountSum FROM Opportunity WHERE BH_Store_Opportunity__c in:oppIds GROUP BY BH_Store_Opportunity__c]){
            Opportunity opp = new Opportunity();
            opp.id = (Id) ar.get('OpportunityId');
            opp.Amount = (Decimal) ar.get('AmountSum');
            oppToBeUpdated.add(opp);
        }
        }
       Update oppToBeUpdated;
    }*/

    
     public static void onAfterDelete(List<Opportunity> oldOpportunity){
        List<Opportunity> BhChildOpportunities = new List<Opportunity>();
       //  List<Opportunity> OpptList = new List<Opportunity>();
        
        // OpptList = [Select Id,BH_Store_Lead__c, Name, RecordTypeId from Lead where Id IN: oldLeadMap.keySet()];
        System.debug('Old Opportunities deleted:'+ oldOpportunity);
        //  if(!OpptList.isEmpty()) {
        for(Opportunity opp: oldOpportunity) {
            if(opp.BH_Store_Opportunity__c != Null){
                BhChildOpportunities.add(opp);
          }
       // }
        
        
        System.debug('BhOpportunities deleted:'+ BhChildOpportunities );
        }
        if(!BhChildOpportunities.isEmpty()){
            AP_OpportunityManagementService.updateChildOpportunities(BhChildOpportunities);
             System.debug('BhOpportunities deleted:'+ BhChildOpportunities );
        }
    }
}