public class AP_BotManagementServices {
    public static Id createBotLead(String cName, String cMobile, String cEmail, String cPincode, String cService, String cOriginalBU) {
        Id leadId;
        List<Lead> leadList = new List<Lead>();
        List<Campaign> cList = [Select Id, Name, BU__c, Sub_Service__c, Source__c, Digital_Marketing_Campaign_Code__c From Campaign 
                                where Digital_Marketing_Campaign_Code__c =: 'CHATBOT_'+cService AND isActive = true];
        
        Lead l = new Lead();
        l.RecordTypeId = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByName().get(cService).getRecordTypeId();
        l.LastName = cName;
        l.MobilePhone = cMobile;
        l.Email = cEmail;
        l.Pincode__c = cPincode;
        l.Skills__c = cService;
        l.is_Bot__c = True;
        l.LeadSource = 'Chat';
        l.Bot_Journey__c = 'Initiate';
        if(!cList.isEmpty() && cList != null) {
            l.CampaignName__c = cList[0].Id;
            l.Campaign_Code__c = cList[0].Digital_Marketing_Campaign_Code__c;
        }
        if(cService == 'BHS'){
            if(cOriginalBU == 'BHS'){
                l.Process_Type__c = 'BHS_BHS';
                System.debug('BHS_BHS');
            }
        }
        else if(cService == 'SPS'){
            if(cOriginalBU == 'BHS'){
                l.Process_Type__c = 'REGRETBHS_SPS';
                System.debug('REGRETBHS_SPS');
            }
            else if(cOriginalBU == 'SPS'){
                l.Process_Type__c = 'SPS_SPS';
                System.debug('SPS_SPS');
            }
        }
        else if(cService == 'General Enquiry' && cOriginalBU == 'SPS'){
            l.Process_Type__c = 'REGRETSPS_GENERALENQUIRY';
            System.debug('REGRETSPS_GENERALENQUIRY');
        }
        else if(cService == 'General Enquiry' && cOriginalBU == 'BHS'){
            l.Process_Type__c = 'REGRETBHS_GENERALENQUIRY';
            System.debug('REGRETBHS_GENERALENQUIRY');
        }
        
        leadList.add(l);
        
        if(!leadList.isEmpty()) {
            try {
                List<DupResultsDTO> dupList = LeadManagementServices.leadPreprocessing(leadList, 'WEB');
                if (dupList.isEmpty()) {
                    try {
                        Database.DMLOptions dml = new Database.DMLOptions();
                        dml.DuplicateRuleHeader.AllowSave = true;
                        Database.saveResult[] srList = Database.insert(leadList, dml);
                        for (Database.SaveResult sr: srList) {
                            if (sr.isSuccess()) {
                                system.debug('Inserted Lead Id: ' + sr.getId());
                                leadId = sr.getId();
                            } else {
                                String msg = null;
                                for (Database.Error err: sr.getErrors()) {
                                    msg = 'Lead Insert Failed :' + err.getMessage();
                                }
                                system.debug('Error: '+msg);
                            }
                        }
                    } catch (System.DmlException ex) {
                        String msg = null;
                        for (Integer i = 0; i < ex.getNumDml(); i++) {
                            msg = 'Lead Insert Failed :' + ex.getMessage();
                        }
                        system.debug('Insert failed: '+msg);
                    }
                } else {
                    Map<Boolean, String> resultMap = EnquiryManagementServices.leadProcessingBot(dupList, leadList);
                    system.debug('resultMap: '+resultMap);
                    
                    if(!resultMap.isEmpty()) {
                        for(Boolean b: resultMap.keySet()) {
                            if(b == true) {
                                try {
                                    Database.DMLOptions dml = new Database.DMLOptions();
                                    dml.DuplicateRuleHeader.AllowSave = true;
                                    Database.saveResult[] srList = Database.insert(leadList, dml);
                                    for (Database.SaveResult sr: srList) {
                                        if (sr.isSuccess()) {
                                            system.debug('Inserted Lead Id: ' + sr.getId());
                                            leadId = sr.getId();
                                        } else {
                                            String msg = null;
                                            for (Database.Error err: sr.getErrors()) {
                                                msg = 'Lead Insert Failed :' + err.getMessage();
                                            }
                                            system.debug('Error: '+msg);
                                        }
                                    }
                                } catch (System.DmlException ex) {
                                    String msg = null;
                                    for (Integer i = 0; i < ex.getNumDml(); i++) {
                                        msg = 'Lead Insert Failed :' + ex.getMessage();
                                    }
                                    system.debug('Insert failed: '+msg);
                                }
                            } else {
                                leadId = resultMap.get(False);
                            }
                        }
                    } else {
                        system.debug('Result Map is Empty');
                    }
                }
            } catch (GlobalException g) {
                System.debug('Global Exception catch: '+g.getErrorMsg()[0]);
            }
        }
        return leadId;
    }
    /*
public static Id CreateMessagingUser(Id LeadId) {

List<MessagingEndUser> messageuserList = New List<MessagingEndUser>();
MessagingEndUser messageuser = new MessagingEndUser();
List<MessagingEndUser> MsgU = new List<MessagingEndUser>();

Lead l = [SELECT Id,Name,MobilePhone FROM Lead WHERE Id=:LeadId];

if(l != NULL){

messageuserList=[select id, Accountid,Name,IsFullyOptedIn,MessagingConsentStatus 
from MessagingEndUser where Lead__c=: l.Id AND IsFullyOptedIn = True];
if(messageuserList != NULL && messageuserList.size()>0){
System.debug('User Lead Already Exists');
String Mesg = 'User Lead Already Exists';
return messageuserList[0].id;
}
else{
MsgU = [SELECT Id,Name FROM MessagingEndUser WHERE MessagingPlatformKey =: 'whatsapp:+91'+lead.MobilePhone];
system.debug('MsgU : ' +MsgU);
if(MsgU != NULL && MsgU.size()>0){
MsgU[0].MessagingConsentStatus = 'ExplicitlyOptedIn';
update MsgU;
system.debug('MsgU : ' +MsgU);
return MsgU[0].id;
}
else{
messageuser.Name = l.Name;
messageuser.Lead__c = l.id;
messageuser.MessagingPlatformKey = 'whatsapp:+91'+l.MobilePhone ;messageuser.MessageType = 'Whatsapp';
messageuser.MessagingChannelId = '0Mj720000000001CAA'; // Sandbox = 0Mj720000000001CAA Production = 0Mj8n0000000001CAA
messageuser.MessagingConsentStatus = 'ExplicitlyOptedIn';
insert messageuser;    
system.debug('messageuser : ' +messageuser);
return messageuser.Id;
} 
}
}
return null;
}

public static void InitiateJourney(String LeadId) {

Lead l = [SELECT Id,Name,MobilePhone FROM Lead WHERE Id=:LeadId];

if(l != NULL){
Id MessagingUserId = AP_BotManagementServices.CreateMessagingUser(l.Id);
l.Bot_Journey__c = 'Initiated';
update l;
}
}
*/
    public static void initiateJourney(Set<Id> leadIdSet) {
        Map<Id, MessagingEndUser> messageEndUserLeadMap = new Map<Id, MessagingEndUser>();
        Map<String, List<Lead>> mobileLeadMap = new Map<String, List<Lead>>();
        List<Lead> updateLeadList = new List<Lead>();
        
        List<Lead> leadList = [Select Id, Name, MobilePhone, Email, Bot_Journey__c from Lead where Id IN: leadIdSet];
        
        if(!leadList.isEmpty()) {
            for(Lead l: leadList) {
                if(!mobileLeadMap.containsKey(l.MobilePhone)) {
                    List<Lead> newLeadList = new List<Lead>();
                    newLeadList.add(l);
                    mobileLeadMap.put(l.MobilePhone, newLeadList);
                } else {
                    mobileLeadMap.get(l.MobilePhone).add(l);
                }
            }
            if(mobileLeadMap != null)
                AP_BotManagementServices.createMessagingUser(mobileLeadMap);
            
            for(Lead l: leadList) {
                l.Bot_Journey__c = 'Initiated';
                updateLeadList.add(l);    
            }
            if(!updateLeadList.isEmpty())
                update updateLeadList;
        }
    }
    
    public static void createMessagingUser(Map<String, List<Lead>> mobileLeadMap) {
        Map<String, MessagingEndUser> messageEndUserMobileMap = new Map<String, MessagingEndUser>();
        List<MessagingEndUser> insertMessagingEndUserList = new List<MessagingEndUser>();
        List<MessagingEndUser> updateMessagingEndUserList = new List<MessagingEndUser>();
        
        List<MessagingEndUser> messagingEndUserList = [Select Id, Name, Mobile__c, MessagingConsentStatus/*, Count__c*/ From MessagingEndUser Where Mobile__c IN: mobileLeadMap.keySet()];
        if(!messagingEndUserList.isEmpty()) {
            for(MessagingEndUser msgEndUser: messagingEndUserList) {
                messageEndUserMobileMap.put(msgEndUser.Mobile__c, msgEndUser);
            }
        }
        List<MessagingChannel> mc = [SELECT ID FROM MessagingChannel];
        
        for(String mob: mobileLeadMap.keySet()) {
            List<Lead> leadList = mobileLeadMap.get(mob);
            
            for(Lead l: leadList) {
                if(messageEndUserMobileMap != null) {
                    if(!messageEndUserMobileMap.containsKey(l.MobilePhone)) {
                        MessagingEndUser messageEndUser = new MessagingEndUser();
                        messageEndUser.Name = l.Name;
                        //messageEndUser.Lead__c = l.id;
                        messageEndUser.MessagingPlatformKey = 'whatsapp:+91'+l.MobilePhone;
                        messageEndUser.MessageType = 'Whatsapp';
                        if(mc != null && !mc.isEmpty()){
                            messageEndUser.MessagingChannelId = mc[0].Id; // Sandbox = 0Mj720000000001CAA Production = 0Mj8n0000000001CAA
                        }
                        messageEndUser.MessagingConsentStatus = 'ExplicitlyOptedIn';
                        messageEndUser.Mobile__c = l.MobilePhone;
                        insertMessagingEndUserList.add(messageEndUser);
                    } else {
                        MessagingEndUser getMessageEndUser = messageEndUserMobileMap.get(l.MobilePhone);
                        getMessageEndUser.MessagingConsentStatus = 'ExplicitlyOptedIn';
                        /*if(getMessageEndUser.Count__c != null && getMessageEndUser.Count__c != 0)
getMessageEndUser.Count__c = getMessageEndUser.Count__c + 1;
else
getMessageEndUser.Count__c = 1;*/
                        updateMessagingEndUserList.add(getMessageEndUser);
                    }
                } else {
                    MessagingEndUser messageEndUser = new MessagingEndUser();
                    messageEndUser.Name = l.Name;
                    //messageEndUser.Lead__c = l.id;
                    messageEndUser.MessagingPlatformKey = 'whatsapp:+91'+l.MobilePhone;
                    messageEndUser.MessageType = 'Whatsapp';
                    if(mc != null && !mc.isEmpty()){
                        messageEndUser.MessagingChannelId = mc[0].Id; // Sandbox = 0Mj720000000001CAA Production = 0Mj8n0000000001CAA
                    }
                    messageEndUser.MessagingConsentStatus = 'ExplicitlyOptedIn';
                    messageEndUser.Mobile__c = l.MobilePhone;
                    insertMessagingEndUserList.add(messageEndUser);    
                }
                break;
            }
        }
        if(!insertMessagingEndUserList.isEmpty() && !test.isRunningTest() && !mc.isEmpty())
            insert insertMessagingEndUserList;
        if(!updateMessagingEndUserList.isEmpty())
            update updateMessagingEndUserList;
    }
    
    public static void updateMessagingEndUserOnLeadAndAccount(Map<String, MessagingEndUser> messagingEndUserMobileMap) {
        List<Lead> leadList = new List<Lead>();
        List<Lead> updateLeadList = new List<Lead>();
        List<Account> accountList = new List<Account>();
        List<Account> updateAccountList = new List<Account>();
        
        
        leadList = [Select Id, MobilePhone, Messaging_User__c from Lead where MobilePhone IN: messagingEndUserMobileMap.keySet() AND IsConverted = false 
                    AND Messaging_User__c = null AND Whatsapp_Notification__c = true];
        accountList = [Select Id, PersonMobilePhone, Messaging_User__c from Account where PersonMobilePhone IN: messagingEndUserMobileMap.keySet() AND IsPersonAccount = true 
                       AND Messaging_User__c = null];
        
        if(!leadList.isEmpty()) {
            for(Lead l: leadList) {
                if(messagingEndUserMobileMap.containsKey(l.MobilePhone)) {
                    l.Messaging_User__c = messagingEndUserMobileMap.get(l.MobilePhone).Id;
                    updateLeadList.add(l);
                }
            }
        }
        
        if(!accountList.isEmpty()) {
            for(Account a: accountList) {
                if(messagingEndUserMobileMap.containsKey(a.PersonMobilePhone)) {
                    a.Messaging_User__c = messagingEndUserMobileMap.get(a.PersonMobilePhone).Id;
                    updateAccountList.add(a);
                }
            }
        }
        
        if(!updateLeadList.isEmpty())
            update updateLeadList;
        if(!updateAccountList.isEmpty())
            update updateAccountList;
    }   
}