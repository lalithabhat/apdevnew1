@isTest
global class YM_LeadAPI_Mock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://app.yellowmessenger.com/integrations/yellowmessenger/receive', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"from" : "919876543251", "to" : "x1562578220660","source" : "whatsapp","data" : {"event" : {"code" : "WELCOME_MESSAGE",'
                    +'"data" : {"countryCode" : "","mobile" : "919876543251","name" : "Vivek Test", "pincode" : "441904", "campaignId" : "",'
                    +'"bpNumber" : "","zconId" : "00Q72000002QfrBEAS","email" : "","Soa" : "YWL"}}}}');
        res.setStatusCode(200);
        return res;
    }
}