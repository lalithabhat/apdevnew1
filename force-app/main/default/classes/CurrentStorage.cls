public class CurrentStorage {
    @Future(callout=true)
    public static void getStorage() {
        String sid = Login.login('integration.user@ap.prod.devnew','apDevNew@123hdrODuruBtvmdRn7JRomtrgj00D72000001V5MF!AQEAQAZueLJZBnejas6y6_Iyuwc4cGuCU9q0P1VR4_fx6lo905I_ATIp77HQjGeiz32nrMLY9r1qlc2EaAlniv4OBEn4L094');
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint('https://1ap--devnew.sandbox.my.salesforce.com/services/data/v53.0/limits');
        req.setHeader('Authorization', 'OAuth '+ sid);
        system.debug('sid:: '+sid);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        Map<String, Object> m = (Map<String,
                                 Object>)JSON.deserializeUntyped(res.getBody());
        Map<String, Object> dataStorage = (Map<String,
                                           Object>)m.get('DataStorageMB');
        System.debug('Current Storage: ' + dataStorage.get('Remaining'));
        system.debug('class executed');
        return;
    }
}