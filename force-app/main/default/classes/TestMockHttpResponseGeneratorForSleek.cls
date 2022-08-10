@isTest
global class TestMockHttpResponseGeneratorForSleek implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"SUCCESS":"0", "SITE ID":"1234"}');
        res.setStatusCode(200);
        return res;
    }
}