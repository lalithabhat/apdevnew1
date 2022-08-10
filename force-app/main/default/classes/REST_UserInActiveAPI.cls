@RestResource(urlMapping='/UserContactStatusUpdate/*')
global class REST_UserInActiveAPI {
    @HttpPost
    global static REST_Result getUpdate(REST_Request[] updateContactMasterStatus)
    {
         REST_Result r = new REST_Result();
         for(REST_Request req: updateContactMasterStatus)
         {
         	if((String.isBlank(req.firstName)) || (String.isBlank(req.lastName)) || (String.isBlank(req.phone)) || (String.isBlank(req.email)) || (String.isBlank(req.status)) || (String.isBlank(req.sfUserId)))
         	{
             	r.returnCode=400;
             	r.message='Required fields are missing';
         	}
         	else
         	{
             try
             {
              	
                 
                 User userlist=[SELECT ContactId, Id, LastName, FirstName, PositionID__c, Contact.FirstName, Contact.LastName, Contact.PositionID__c, Contact.Email, Contact.MobilePhone, Contact.Active__c FROM User WHERE Id=:req.sfUserId]; 
                 userlist.MobilePhone=req.phone;
                 userlist.Email=req.email;
                 userlist.FirstName = req.firstName;
                 userlist.LastName = req.lastName;
                 userlist.PositionID__c = req.positionId;
                 Id c_id = userlist.ContactId;
                 //userlist.Contact.FirstName = req.firstName;
                 //userlist.Contact.LastName = req.lastName;
                 //userlist.Contact.MobilePhone=req.phone;
                 //userlist.Contact.Email=req.email;
                 //userlist.Contact.PositionID__c=req.positionId;
                 if(req.status.equalsIgnoreCase('false') || req.status.equalsIgnoreCase('FALSE') || req.status.equalsIgnoreCase('False'))
                 {
                 	userlist.IsActive=false;
                    userlist.Contact.Active__c=false;
                 }
                 else
                 {
                     userlist.IsActive=true;
                     userlist.Contact.Active__c=true;
                 }
                  userlist.Contact.LastName = req.lastName;
                 userlist.Contact.FirstName = req.firstName;
                 userlist.Contact.MobilePhone=req.phone;
                 userlist.Contact.Email=req.email;
                 userlist.Contact.PositionID__c=req.positionId;
                 //userlist.Contact.LastName = req.lastName;
                 update userlist;
                 r.returnCode=201;
             	 r.message='Success';
                 System.debug('List updated');
                 
             }catch(Exception e)
             {
                 r.returnCode=400;
             	 r.message=req.firstName+' '+req.lastName+' with id '+req.sfUserId+' User is not present';
                 System.debug(e.getMessage());
             }
             
             
         }
         }
         return r;
    }
    global class REST_Request {
        webservice String positionId;
        webservice String sfUserId;
        webservice String firstName;
        webservice String lastName;
        webservice String email;
        webservice String phone;
        webservice String status;
    }
	global class REST_Result {
        webservice Integer returnCode;
        webservice String message;
    }

}