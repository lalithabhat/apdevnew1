@isTest
public class Test_Bot_FetchMobileWhatsapp {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        insert l;
        
        MessagingEndUser m = New MessagingEndUser();
        m.Name = 'abc';
        m.MessageType = 'Phone';
        m.MessagingChannelId = '0Mj8n0000000001CAA';// sandbox = 0Mj720000000001CAA ; UAT = 0Mj6F000000GmjfSAC; Production = 0Mj8n0000000001CAA
        m.MessagingPlatformKey = 'whatsapp:+918275404075';
        insert m;
        List<MessagingEndUser> M1 = New List<MessagingEndUser>();
        m1 = [select Id from MessagingEndUser where id =: m.id ];
        
        Messagingsession ms = New Messagingsession();        
        ms.Status = 'Ended';
        ms.MessagingChannelId = '0Mj8n0000000001CAA';// sandbox = 0Mj720000000001CAA ; UAT = 0Mj6F000000GmjfSAC; Production = 0Mj8n0000000001CAA
        ms.MessagingEndUserId = m.id;
        insert ms;
        
        List<Messagingsession> M2 = New List<Messagingsession>();
        m2 = [select Id from Messagingsession where id =: ms.id ];
        List<Bot_FetchMobileWhatsapp.PrechatInput> ipList = New List<Bot_FetchMobileWhatsapp.PrechatInput>();
        Bot_FetchMobileWhatsapp.PrechatInput c = new Bot_FetchMobileWhatsapp.PrechatInput();
        
        c.MessagingEndUserId = m1[0].id;
        c.MessagingSessionId = m2[0].id;
        ipList.add(c);
        List<Bot_FetchMobileWhatsapp.PrechatOutput> Docs = Bot_FetchMobileWhatsapp.FetchMobileWhatsapp(ipList);
        Test.stopTest();
    }
}