@isTest
public class Test_Bot_getLeadId {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        List<Bot_getLeadId.PrechatInput> ipList = New List<Bot_getLeadId.PrechatInput>();
        Bot_getLeadId.PrechatInput c = new Bot_getLeadId.PrechatInput();
        c.Name = 'Test'; 
        c.Mobile = '0601202101'; 
        c.Email = 't.0601202101@stetig.in'; 
        c.BU = 'SPS'; 
        c.Pincode = '222222'; 
        c.WhatsappOptin = 'Yes'; 
        c.OriginalBU = 'SPS'; 
        
        ipList.add(c);
        List<Bot_getLeadId.PrechatOutput> Docs = Bot_getLeadId.getLeadId(ipList);
        Test.stopTest();
    }
}