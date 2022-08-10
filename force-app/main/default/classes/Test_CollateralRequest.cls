@isTest
public class Test_CollateralRequest {
	@isTest
    public static void testGetPincode(){
        List<Id> contactId = new List<Id>();
        contactId.add('0038n000002DETdAAO');
        Flow_GetPincodes.getPincodes(contactId);
    }
    @isTest
    public static void testGetHOD(){
        List<Flow_GetHOD.input> iplist = new List<Flow_GetHOD.input>();
        Flow_GetHOD.input ip = new Flow_GetHOD.input();
        ip.level ='Unit Head';
        ip.pincode ='100001';
        ipList.add(ip);
        Flow_GetHOD.getHOD(ipList);
    }
}