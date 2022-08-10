/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 26-10-2021
*Created By - Sankalp Tiwari
*---------------------------------------------------------------------------------------------------------
*Description - Apex class to handle and update all the MessagingEndUser based on the trigger actions.
*********************************************************************************************************/
public class AP_MessagingEndUserTriggerHandler {
    public static void onAfterInsert(List<MessagingEndUser> messagingEndUserList) {
        Map<String, MessagingEndUser> messagingEndUserMobileMap = new Map<String, MessagingEndUser>();
        
        for(MessagingEndUser msg: messagingEndUserList) {
            messagingEndUserMobileMap.put(msg.Mobile__c, msg);
        }
        if(messagingEndUserMobileMap != null)
            Ap_BotManagementServices.updateMessagingEndUserOnLeadAndAccount(messagingEndUserMobileMap);
    }
}