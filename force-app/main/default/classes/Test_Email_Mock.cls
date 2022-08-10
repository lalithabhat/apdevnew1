@isTest
public class Test_Email_Mock implements HttpCalloutMock {

   
public HTTPResponse respond(HTTPRequest req) {
    HttpResponse response = new HttpResponse();

    response.setStatusCode(200);
    response.setBody('{"requestStatus":"success","statusCode":"200","statusDesc":"Request accepted successfully","ackId":"","messageId":"3141923133525708000","custRef":null}');

    return response;
}
}