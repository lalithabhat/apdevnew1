@isTest
public class TEST_RESTUserInActiveAPI {
    //for checking true
   @isTest(SeeAllData=false)
	public static void successNewUser1()
    {
        
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UserContactStatusUpdate/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        //User u = [SELECT Federation_Id__c,FirstName,Id,IsActive,LastName,MobilePhone,PositionID__c FROM User];
        User u = new User();
        u.Federation_Id__c='p00111111';
        u.FirstName='Meerafirstname';
        u.LastName='Meeralastname';
        u.IsActive=true;
        u.PositionID__c='Z00222181';
        u.Email='testt1@gmail.com';
        u.Phone='1234567890';
        u.Username='test111@ap.com';
        u.Alias='testtt1';
        u.TimeZoneSidKey='Asia/Kolkata';
        u.LocaleSidKey='en_IN';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        Profile[] p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u.ProfileId=p[0].Id;
		insert u;
        String uid=u.Id;
        
        
        //Contact c = [SELECT Active__c,Email,Employee_Code__c,FirstName,Id,LastName,Phone,PositionID__c FROM Contact];
        Contact c = new Contact();
        c.FirstName='Meerafirstname';
        c.LastName='Meeralastname';
        c.Active__c=true;
        c.Email='test@gmail.com';
        c.Employee_Code__c=u.Federation_Id__c;
        c.Phone='1234567890';
		
        c.PositionID__c=u.Federation_Id__c;
        //c.AccountId='';
        insert c; 
        String cid=c.Id;
        
        REST_UserInActiveAPI.REST_Request req1 = new REST_UserInActiveAPI.REST_Request();
        List<REST_UserInActiveAPI.REST_Request> reqq = new List<REST_UserInActiveAPI.REST_Request>();
        REST_UserInActiveAPI.REST_Request userreq = new REST_UserInActiveAPI.REST_Request();
        
        User u1=[SELECT Federation_Id__c,FirstName,Id,IsActive,LastName,MobilePhone,PositionID__c  FROM User WHERE Id=:uid];
       
        userreq.email='meera@gmail.com';
        userreq.firstName='Meera6Fname';
        userreq.lastName='Meera6Lname';
       	userreq.positionId='Z0000001';
       	userreq.lastName='MeeraLname';
       	userreq.sfUserId=u1.Id;
       	userreq.status='true';
       	userreq.phone='9190909091';
        reqq.add(userreq);
        
        REST_UserInActiveAPI.REST_Result r = REST_UserInActiveAPI.getUpdate(reqq);
        //System.assertEquals(201, r.returnCode);
        //System.assertEquals('Success', r.message);
        System.debug('message = '+r.message);
        Test.stopTest();
        
    }
    
    //for checking status false
    @isTest(SeeAllData=false)
	public static void successNewUser2()
    {
       
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UserContactStatusUpdate/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        //User u = [SELECT Federation_Id__c,FirstName,Id,IsActive,LastName,MobilePhone,PositionID__c FROM User];
        User u = new User();
        u.Federation_Id__c='p00111111';
        u.FirstName='Meera5firstname';
        u.LastName='Meera5lastname';
        u.IsActive=true;
        u.PositionID__c='Q00122281';
        u.Email='test2@gmail.com';
        u.Phone='2234567891';
        u.Username='test2222222@ap.com';
        u.Alias='testtt2';
        u.TimeZoneSidKey='Asia/Kolkata';
        u.LocaleSidKey='en_IN';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        Profile[] p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u.ProfileId=p[0].Id;
		insert u;
        String uid=u.Id;
        
        
        //Contact c = [SELECT Active__c,Email,Employee_Code__c,FirstName,Id,LastName,Phone,PositionID__c FROM Contact];
        Contact c = new Contact();
        c.FirstName='Meera2first name';
        c.LastName='Meera2last name';
        c.Active__c=true;
        c.Email='meera2@gmail.com';
        c.Employee_Code__c=u.Federation_Id__c;
        c.Phone='2333567890';
        
        c.PositionID__c=u.Federation_Id__c;
        //c.AccountId='';
        insert c; 
        String cid=c.Id;
        
        REST_UserInActiveAPI.REST_Request req1 = new REST_UserInActiveAPI.REST_Request();
        List<REST_UserInActiveAPI.REST_Request> reqq = new List<REST_UserInActiveAPI.REST_Request>();
        REST_UserInActiveAPI.REST_Request userreq = new REST_UserInActiveAPI.REST_Request();
        
        User u1=[SELECT Federation_Id__c,FirstName,Id,IsActive,LastName,MobilePhone,PositionID__c  FROM User WHERE Id=:uid];
       
        
        
        userreq.email='meera2@gmail.com';
        userreq.firstName='Meera2Fname';
       	userreq.positionId='Q00222281';
       	userreq.lastName='Meera2Lname';
       	userreq.sfUserId=u1.Id;
       	userreq.status='false';
       	userreq.phone='9091909090';
        
        reqq.add(userreq);
        
        REST_UserInActiveAPI.REST_Result r = REST_UserInActiveAPI.getUpdate(reqq);
        //System.assertEquals(201, r.returnCode);
        //System.assertEquals('Success', r.message);
        System.debug('message = '+r.message);
        Test.stopTest();
        
    }

    //for checking blanks
    @isTest(SeeAllData=false)
	public static void successNewUser3()
    {
        
        
        String JSONMsg = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/UserContactStatusUpdate/*';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JSONMsg);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        //User u = [SELECT Federation_Id__c,FirstName,Id,IsActive,LastName,MobilePhone,PositionID__c FROM User];
        User u = new User();
        u.Federation_Id__c='Q00112111';
        u.FirstName='Meera3first name';
        u.LastName='Meera3last name';
        u.IsActive=true;
        u.PositionID__c='Q00112111';
        u.Email='meera3@gmail.com';
        u.Phone='2234567890';
        u.Username='test3@ap.com';
        u.Alias='testtt3';
        u.TimeZoneSidKey='Asia/Kolkata';
        u.LocaleSidKey='en_IN';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        Profile[] p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u.ProfileId=p[0].Id;
		insert u;
        String uid=u.Id;
        
        
        //Contact c = [SELECT Active__c,Email,Employee_Code__c,FirstName,Id,LastName,Phone,PositionID__c FROM Contact];
        Contact c= new Contact(); 
        c.FirstName='Meera4firstname';
        c.LastName='Meera4lastname';
        c.Active__c=true;
        c.Email='meera4@gmail.com';
        c.Employee_Code__c=u.Federation_Id__c;
       
        c.PositionID__c=u.Federation_Id__c;
        //c.AccountId='';
        c.Phone='2235567890';
        insert c; 
        String cid=c.Id;
        
        REST_UserInActiveAPI.REST_Request req1 = new REST_UserInActiveAPI.REST_Request();
        List<REST_UserInActiveAPI.REST_Request> reqq = new List<REST_UserInActiveAPI.REST_Request>();
        REST_UserInActiveAPI.REST_Request userreq = new REST_UserInActiveAPI.REST_Request();
        
        User u1=[SELECT Federation_Id__c,FirstName,Id,IsActive,LastName,MobilePhone,PositionID__c  FROM User WHERE Id=:uid];
       
        
        
        userreq.email='';
        userreq.firstName='Meera4first name';
       	userreq.positionId='Q00112111';
       	userreq.lastName='Meera4last name';
       	userreq.sfUserId=u1.Id;
       	userreq.status='true';
       	userreq.phone='9090919090';
        reqq.add(userreq);
        
        REST_UserInActiveAPI.REST_Result r = REST_UserInActiveAPI.getUpdate(reqq);
        //System.assertEquals(400, r.returnCode);
        //System.assertEquals('Required fields are missing', r.message);
        System.debug('message = '+r.message);
        Test.stopTest();
        
    }
    
    
    
     @isTest(SeeAllData=false)
	public static void successNewUser4()
    {
        
        
        
        Test.startTest();
        //User u = [SELECT Federation_Id__c,FirstName,Id,IsActive,LastName,MobilePhone,PositionID__c FROM User];
        User u = new User();
        u.Federation_Id__c='Q00112111';
        u.FirstName='Meera3first name';
        u.LastName='Meera3last name';
        u.IsActive=true;
        u.PositionID__c='Q00112111';
        u.Email='meera3@gmail.com';
        u.Phone='2234567890';
        u.Username='test5@ap.com';
        u.Alias='testtt5';
        u.TimeZoneSidKey='Asia/Kolkata';
        u.LocaleSidKey='en_IN';
        u.EmailEncodingKey='UTF-8';
        u.LanguageLocaleKey='en_US';
        Profile[] p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        u.ProfileId=p[0].Id;
		insert u;
        String uid=u.Id;
        
        
        //Contact c = [SELECT Active__c,Email,Employee_Code__c,FirstName,Id,LastName,Phone,PositionID__c FROM Contact];
        Contact c= new Contact(); 
        c.FirstName='Meera4firstname';
        c.LastName='Meera4lastname';
        c.Active__c=true;
        c.Email='meera4@gmail.com';
        c.Employee_Code__c=u.Federation_Id__c;
       
        c.PositionID__c=u.Federation_Id__c;
        //c.AccountId='';
        c.Phone='2235567890';
        insert c; 
        String cid=c.Id;
        
       
        REST_UserInActiveAPI.REST_Request req1 = new REST_UserInActiveAPI.REST_Request();
        List<REST_UserInActiveAPI.REST_Request> reqq = new List<REST_UserInActiveAPI.REST_Request>();
        REST_UserInActiveAPI.REST_Request userreq = new REST_UserInActiveAPI.REST_Request();
        
        User u1=[SELECT Federation_Id__c,FirstName,Id,IsActive,LastName,MobilePhone,Email,PositionID__c  FROM User WHERE Id=:uid];
       
        
        
        userreq.email='test5@gmail.com';
        userreq.firstName='Meera4first name';
       	userreq.positionId='Q00112111';
       	userreq.lastName='Meera4last name';
       	userreq.sfUserId=u1.Id;
       	userreq.status='true';
       	userreq.phone='9090919090';
        reqq.add(userreq);
        
        REST_UserInActiveAPI.REST_Result r = REST_UserInActiveAPI.getUpdate(reqq);
        //System.assertEquals(400, r.returnCode);
        //System.assertEquals('Required fields are missing', r.message);
        System.debug('message = '+r.message);
        Test.stopTest();
        
    }
    
    
     @isTest(SeeAllData=false)
	public static void successNewUser5()
    {
        
        Test.startTest();
        
        
        
        Map<string,string> resultMap = new Map<string,string>();
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = 'testAccount';
        
        a.Phone = '1234567123';
        a.Dealer_Code__c = 'D12345';
        a.RecordTypeId = devRecordTypeId;
        a.OwnerId = u.Id;
        insert a;
        
        contact c1 = new Contact();
        c1.FirstName = 'First';
        c1.LastName = 'testcontact';
        c1.mobilePhone = '1234567123';
        c1.Email = 'test@contact.in';
        c1.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c1.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c1.Active__c = true;
        c1.AccountId = a.Id;
        insert c1;
        resultMap.put('CA',c1.Id);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;       
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerAutoResponseEmail = false;       
        dmo.optAllOrNone = false;
        
       
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Associate (SA)' Limit 1];
        string nick = c1.email!=null?c1.email.substring(0, c1.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        User newUser1 = new User(alias=c1.firstName, email = c1.email, emailencodingkey = 'UTF-8', 
                                 firstname = c1.firstName, lastname = c1.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c1.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = c1.email,CommunityNickname = nick,ProfileId =portalProfile.Id, IsActive = true);
        newUser1.setOptions(dmo);
        insert newUser1;
        REST_UserInActiveAPI.REST_Request req1 = new REST_UserInActiveAPI.REST_Request();
        List<REST_UserInActiveAPI.REST_Request> reqq = new List<REST_UserInActiveAPI.REST_Request>();
        REST_UserInActiveAPI.REST_Request userreq = new REST_UserInActiveAPI.REST_Request();
        
       
        
        
        userreq.email=newUser1.Email;
        userreq.firstName= newUser1.FirstName;
       	userreq.positionId=newUser1.PositionID__c;
       	userreq.lastName=newUser1.LastName;
       	userreq.sfUserId=newUser1.Id;
       	userreq.status='true';
       	userreq.phone=newUser1.MobilePhone;
        reqq.add(userreq);
        
        REST_UserInActiveAPI.REST_Result r = REST_UserInActiveAPI.getUpdate(reqq);
        //System.assertEquals(r.returnCode, 201);
        
        Test.stopTest();
        
    }
}