@isTest
public class TestExternalBHSSystemJSONtoApex {
    static testMethod void testParse() {
        String json = '{'+
        '   \"access_token\" : \"9b1aa5b0-8dd4-450b-b546-ed8fb579d4b5\",'+
        '   \"token_type\" : \"bearer\",'+
        '   \"expires_in\" : \"21835\",'+
        '   \"scope\" : \"basic openid\"'+
        '}';
        ExternalBHSSystemJSONtoApex obj = ExternalBHSSystemJSONtoApex.parse(json);
        System.assert(obj != null);
    }
}