public Class sendSMSClass
{    public class responseWrapper{
    
    public string code {get;set;}
    public string body {get;set;}
}
 public static responseWrapper mySMS(String strURL)
 {
     system.debug(strURL);
     responseWrapper response = new responseWrapper();
     HttpRequest req = new HttpRequest();
     req.setEndpoint (strURL);
     req.setMethod ('GET');
     try{
         Http http = new Http();
        // if(!Test.isRunningTest()){ 
             HTTPResponse res = http.send(req);
             system.debug(res.getStatusCode());
             system.debug(res.getBody());
             response.code = String.valueof(res.getStatusCode());
             response.body = res.getBody();
             
        // }
     }
     catch(exception e){
         system.debug(e);
         response.code = '0';
         response.body = e.getMessage() + '\n' +e.getLineNumber();
         
     }
     return response;
     
     
 }
}