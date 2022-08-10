@isTest
global class TestMockHttpResponseGeneratorForCTIIssue implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"ResponseCode":"00"}');
        res.setStatusCode(100);
        return res;
    }
}