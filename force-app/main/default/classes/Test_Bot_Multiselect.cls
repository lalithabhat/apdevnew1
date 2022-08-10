@isTest
public class Test_Bot_Multiselect {
Public static testMethod void doTest1() {
        Test.startTest();
    
        List<Bot_Multiselect.PrechatInput> ipList = New List<Bot_Multiselect.PrechatInput>();
        Bot_Multiselect.PrechatInput c = new Bot_Multiselect.PrechatInput();
        c.InputString = '1,2,3,4,5,6,7'; 
        c.Option1 = '1'; 
        c.Option2 = '1'; 
        c.Option3 = '1'; 
        c.Option4 = '1'; 
        c.Option5 = '1'; 
        c.Option6 = '1'; 
        c.Option7 = '1'; 
        
        ipList.add(c);
        List<Bot_Multiselect.PrechatOutput> Docs = Bot_Multiselect.Multiselect(ipList);
        Test.stopTest();
    }
}