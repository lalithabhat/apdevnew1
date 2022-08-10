@isTest
public class TestCreateEventForUser {
	@isTest  
    private static void TestMethod1() {
                
        
        Test.startTest();
        CreateEventForUser.createEvent(system.Now(),system.Now()+1,'Holiday','U2','Unit__C');
        CreateEventForUser.createEvent(system.Now(),system.Now()+1,'Holiday','U0','Unit__C');	
        Test.stopTest();
    }
}