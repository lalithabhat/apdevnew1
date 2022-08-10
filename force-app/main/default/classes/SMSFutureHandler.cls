public class SMSFutureHandler
{
    @future(Callout=true) 
    public static void outboundSMS(set<id> smsIds){
        string myphone = '';
        string mymsg = '';
        string strURL = '';   
        List<System_Log__c> logsToInsert = new List<System_Log__c>();
        if(smsIds != null && smsIds.size() > 0) {
            List<SMS_Schedule_SMS_c__c> smslist = new list<SMS_Schedule_SMS_c__c> ();
            smslist = [SELECT Id,Name,Lead_Lookup__c,Opportunity_Lookup__c,Account_Lookup__c, Sender_Mobile__c,SMS_Long_text__c,  SMS_Text__c FROM 
                       SMS_Schedule_SMS_c__c where Id in :smsIds];
            
            Set<Id> projId = New Set<Id>();
            List <Vendor__c> vendorlist = new List<Vendor__c>();       
            vendorlist = [SELECT id, Name, Vendor_URL__c, Param_1_Name__c, Param_1_Value__c, Param_1_Status__c,
                          Param_2_Name__c, Param_2_Value__c, Param_2_Status__c,
                          Param_3_Name__c, Param_3_Value__c, Param_3_Status__c,
                          Param_4_Name__c, Param_4_Value__c, Param_4_Status__c,
                          Param_5_Name__c, Param_5_Value__c, Param_5_Status__c, 
                          Param_6_Name__c, Param_6_Value__c, Param_6_Status__c,
                          Param_7_Name__c, Param_7_Value__c, Param_7_Status__c,
                          Param_8_Name__c, Param_8_Value__c, Param_8_Status__c
                          FROM Vendor__c WHERE Vendor_Status__c = true limit 1]; 
            
            for(SMS_Schedule_SMS_c__c newsms :smslist) 
            {
                if(newsms.Sender_Mobile__c!= null) {
                    myphone = newsms.Sender_Mobile__c;
                }       
                if(newsms.SMS_Long_text__c!= null) {
                    mymsg = newsms.SMS_Long_text__c;
                }
                
                mymsg = EncodingUtil.URLENCODE(mymsg,'UTF-8');
                mymsg = mymsg.replace('%2B%E2%80%9D','%20');
                mymsg = mymsg.replace('%2B%E2%80%9C','%20');
                mymsg = mymsg.replace('+','%20');
                
                if(vendorlist != null && !vendorlist.isEmpty() && vendorlist[0].Param_1_Status__c == TRUE && 
                   vendorlist[0].Param_2_Status__c == TRUE && vendorlist[0].Param_3_Status__c  == TRUE && 
                   vendorlist[0].Param_4_Status__c == TRUE && vendorlist[0].Param_5_Status__c  == TRUE && 
                   vendorlist[0].Param_7_Status__c == TRUE && vendorlist[0].Param_8_Status__c  == TRUE) {        
                       strURL = vendorlist[0].Vendor_URL__c + 
                           '?' + vendorlist[0].Param_1_Name__c + '=' + vendorlist[0].Param_1_Value__c + 
                           '&' + vendorlist[0].Param_2_Name__c + '=' + vendorlist[0].Param_2_Value__c + 
                           '&' + vendorlist[0].Param_3_Name__c + '=' + vendorlist[0].Param_3_Value__c +  
                           '&' + vendorlist[0].Param_4_Name__c + '=' + vendorlist[0].Param_4_Value__c +  
                           '&' + vendorlist[0].Param_5_Name__c + '=' + vendorlist[0].Param_5_Value__c +
                           '&' + vendorlist[0].Param_6_Name__c + '=' + vendorlist[0].Param_6_Value__c +
                           '&' + vendorlist[0].Param_7_Name__c + '=' + myphone +
                           '&' + vendorlist[0].Param_8_Name__c + '=' + mymsg;
                   }
                //if(!Test.isRunningTest())       
                // System_Log__c SL = new System_Log__c();
                // List<System_Log__c> insertSystemLogList = new List<System_Log__c>();
                
                sendSMSClass.responseWrapper rw =  sendSMSClass.mySMS(strURL); 
                    if(rw.code !='200'){
                        System_Log__c SL = new System_Log__c();
                        //SL.Lead__c = CRMLeadID;
                        SL.API_Name__c  = 'SMS API';
                        SL.Response__c ='Status Code: '+ rw.code +' '+ rw.body;
                        SL.Lead__c = newSms.Lead_Lookup__c;
                        SL.Opportunity__c = newSms.Opportunity_Lookup__c;
                        SL.Account__c = newSMS.Account_Lookup__c;
                        SL.SMS_Schedule_SMS__c = newSMS.Id;
                        logsToInsert.add(SL);
                    }
                
            }
        }
        if(!logsToInsert.isEmpty()) insert logsToInsert;
    } 
}