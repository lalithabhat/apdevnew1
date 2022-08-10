@isTest
public class Test_SamplePostChatPageController {
    Public static testMethod void doTest1() {
        Test.startTest();
                
        Id createBotLeadID = AP_BotManagementServices.createBotLead('Test','2401202201','t.2401202201@stetig.in','441904','SPS');
        String inputText1 = 'test';
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        //lct.Name = 'Test';
        lct.ChatKey = 'abc';
        lct.LeadId = createBotLeadID;
        lct.Survey_Liked__c = True;
        lct.Survey_Comment__c = 'Testing';
        lct.LiveChatVisitorId = lcv.id;
        insert lct;
        
        SamplePostChatPageController spc = new SamplePostChatPageController();
        spc.Feedback = '1';
        spc.chatKey = 'abc';
        spc.save();
        Test.stopTest();
    }
}