@isTest
public class Test_Bot_getContactDetails {
    Public static testMethod void doTest1() {
        Test.startTest();
        Contact con = New Contact();
        con.LastName = 'Test'; 
        con.MobilePhone = '0601202101'; 
        con.Email = 't.0601202101@stetig.in'; 
        con.Pincode__c = '222222'; 
        insert con;
        List<Bot_getContactDetails.PrechatInput> ipList = New List<Bot_getContactDetails.PrechatInput>();
        Bot_getContactDetails.PrechatInput c = new Bot_getContactDetails.PrechatInput();
        c.ContactId = con.Id; 
        
        ipList.add(c);
        List<Bot_getContactDetails.PrechatOutput> Docs = Bot_getContactDetails.getContactDetails(ipList);
        Test.stopTest();
    }
}