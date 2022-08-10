@isTest
global class TestMockHttpResponseGeneratorForBHS implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"acvrjajwq123", "status_Code":"201","object_Id":"123456789"}');
        res.setStatusCode(200);
        return res;
    }
}