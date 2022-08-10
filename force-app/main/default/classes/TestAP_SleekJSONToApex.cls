@isTest
public class TestAP_SleekJSONToApex {
    static testMethod void testParse() {
        String json = '{'+
        '   \"SUCCESS\" : \"1\",'+
        '   \"RESPONSE_MESSAGE\" : \"OK\",'+
        '   \"USER_DATA\" : \"21835\"'+
        '}';
        AP_SleekJSONToApex obj = AP_SleekJSONToApex.parse(json);
        System.assert(obj != null);
    }
}