@isTest
public class Test_My_Team_View {
	@isTest
    public static void test(){
        Map<String,Id> userMap = TestDataSetup.createUserDetails();
        SA_Pincode_Mapping__c s = new SA_Pincode_Mapping__c();
        s.SA__c = userMap.get('CA CONTACT');
        s.TL1__c = userMap.get('TL CONTACT');
        insert s;
        User u = [Select Id from User where Id =: userMap.get('TL USER')];
        System.runAs(u){
        MyTeam_View_Controller.getMyTeam();
        }
    }
}