@isTest
public class TestDataSetup {
    public static Lead createLeadTemplate(String recordType, String firstName, String lastName, String email, String mobile, String pincode) {
        Lead l = new Lead(RecordTypeId = recordType, FirstName = firstName, LastName = lastName, Email= email, 
                          MobilePhone= mobile, Pincode__c = pincode);
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        Database.saveResult srLead = Database.insert(l, dml);
        return l;
    }
    
    public static Account createAccountTemplate(String accName, String email, String mobile) {
        RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
        Account a = new Account(LastName = accName, personEmail = email, personMobilePhone = mobile, RecordType = personAccountRecordType);
        insert a;
        return a;
    }
    
    public static Opportunity createSPSOpportunityTemplate(Id accId, Id recordType, String pincode, String owner, String skill) {
        Opportunity op = new Opportunity(RecordTypeId = recordType, Name = 'John Cena', AccountId = accId, LeadSource = 'Print', StageName = 'Site Booked', 
                                         CloseDate = system.today(), Pincode__c = pinCode, Skills__c = skill, OwnerId = owner);
        insert op;
        return op;
    }
    
    public static Opportunity createBHSOpportunityTemplate(Id accId, Id recordType, String pincode, String owner, String skill) {
        Opportunity op = new Opportunity(RecordTypeId = recordType, Name = 'John Cena', AccountId = accId, LeadSource = 'Print', StageName = 'Design', 
                                         CloseDate = system.today(), Pincode__c = pinCode, Skills__c = skill, OwnerId = owner);
        insert op;
        return op;
    }
    
    public static void createServiceabilitySetup() {
        List<Lead_Service__c> lsList = new List<Lead_Service__c>();
        lslist.add(new Lead_Service__c(Name = 'BHS', Backup_Service__c = 'BH Store', Bot_Consider__c = true));
        lslist.add(new Lead_Service__c(Name = 'BH_Store', Backup_Service__c = 'SPS', Bot_Consider__c = false));
        lslist.add(new Lead_Service__c(Name = 'SPS', Backup_Service__c = 'TCS', Bot_Consider__c = true));
        //lslist.add(new Lead_Service__c(Name = 'SLEEK'));
        lslist.add(new Lead_Service__c(Name = 'TCS'));
        insert lsList;
    }
    
    public static Map<String, Id> createSPSLeadCreationSetup() {
        Map<String, Id> resultMap = new Map<String, Id>();
        resultMap = createUserDetails();
        
        Service_Master__c sm1 = new Service_Master__c();
        sm1.Service__c = 'SPS';
        sm1.Skills__c = 'SPS';
        sm1.Slot_Duration_in_Hours__c = 1.00;
        insert sm1;
        
        Service_Master__c sm2 = new Service_Master__c();
        sm2.Service__c = 'BHS';
        sm2.Skills__c = 'BHS';
        sm2.Slot_Duration_in_Hours__c = 1.00;
        insert sm2;
        
        Pincode__c p = new Pincode__c();
        p.Name = '111111';
        p.City__c = 'PUNE';
        p.State__c = 'MAHARASHTRA';
        p.Country__c = 'India';
        p.Pincode_Ext__c = '111111';
        p.Country_Code__c = 'IN';
        insert p;
        
        Pincode__c p1 = new Pincode__c();
        p1.Name = '333333';
        p1.City__c = 'PUNE';
        p1.State__c = 'MAHARASHTRA';
        p1.Country__c = 'India';
        p1.Pincode_Ext__c = '333333';
        p1.Country_Code__c = 'IN';
        insert p1;
        
        SA_Pincode_Mapping__c pm = new SA_Pincode_Mapping__c();
        pm.Pincode__c = '111111';
        pm.Pincode_lookup__c = p.Id;
        pm.Role__c = 'CA';
        pm.Priority__c = 1;
        pm.SA__c = resultMap.get('CA CONTACT');
        pm.Service_Master__c = sm1.Id;
        pm.TL1__c = resultMap.get('TL CONTACT');
        pm.TL2__c = resultMap.get('TA CONTACT');
        insert pm;
        
        SA_Pincode_Mapping__c pm1 = new SA_Pincode_Mapping__c();
        pm1.Pincode__c = '111111';
        pm1.Pincode_lookup__c = p.Id;
        pm1.Role__c = 'CA';
        pm1.Priority__c = 1;
        pm1.SA__c = resultMap.get('CA CONTACT');
        pm1.Service_Master__c = sm1.Id;
        pm1.TL1__c = resultMap.get('TL CONTACT');
        pm1.TL2__c = resultMap.get('TA CONTACT');
        insert pm1;
        
        SA_Pincode_Mapping__c pm2 = new SA_Pincode_Mapping__c();
        pm2.Pincode__c = '333333';
        pm2.Pincode_lookup__c = p1.Id;
        pm2.Role__c = 'CES';
        pm2.Priority__c = 1;
        pm2.SA__c = resultMap.get('CES CONTACT');
        pm2.Service_Master__c = sm2.Id;
        insert pm2;
        
        Service_Territory__c service = new Service_Territory__c();
        service.Name = 'SPS';
        service.Service__c = 'SPS';
        service.Type__c = 'Service';
        service.Valid_From__c = system.today() - 10;
        service.Valid_Till__c = system.today().addDays(20);
        insert service;
        resultMap.put('SPS Service Territory', service.Id);
        
        Service_Territory__c division = new Service_Territory__c();
        division.Name = 'SPS Division';
        division.Service__c = 'SPS';
        division.Type__c = 'Division';
        division.Parent__c = service.Id;
        division.HOD__c = resultMap.get('DM CONTACT');
        division.Valid_From__c = system.today() - 10;
        division.Valid_Till__c = system.today().addDays(20);
        insert division;
        resultMap.put('SPS Division Territory', division.Id);
        
        Service_Territory__c unit = new Service_Territory__c();
        unit.Name = 'SPS Unit';
        unit.Service__c = 'SPS';
        unit.Type__c = 'Unit';
        unit.Parent__c = division.Id;
        unit.HOD__c = resultMap.get('UH CONTACT');
        unit.Valid_From__c = system.today() - 10;
        unit.Valid_Till__c = system.today().addDays(20);
        insert unit;
        resultMap.put('SPS Unit Territory', unit.Id);
        
        Service_Territory__c region = new Service_Territory__c();
        region.Name = 'SPS Region';
        region.Service__c = 'SPS';
        region.Type__c = 'Region';
        region.Parent__c = unit.Id;
        region.Business_Hour_start__c = Time.newInstance(10, 00, 00, 00);
        region.Business_Hour_End__c = Time.newInstance(18, 00, 00, 00);
        region.HOD__c = resultMap.get('SSO CONTACT');
        region.Valid_From__c = system.today() - 10;
        region.Valid_Till__c = system.today().addDays(20);
        insert region;
        resultMap.put('SPS Region Territory', region.Id);
        
        Service_Territory__c pincode = new Service_Territory__c();
        pincode.Name = '111111';
        pincode.Service__c = 'SPS';
        pincode.Type__c = 'Pincode';
        pincode.Parent__c = region.Id;
        pincode.Pincode__c = p.Id;
        pincode.Valid_From__c = system.today() - 10;
        pincode.Valid_Till__c = system.today().addDays(20);
        insert pincode;
        resultMap.put('SPS Pincode Territory', pincode.Id);
        
        Service_Territory__c service1 = new Service_Territory__c();
        service1.Name = 'BHS';
        service1.Service__c = 'BHS';
        service1.Type__c = 'Service';
        service1.Valid_From__c = system.today() - 10;
        service1.Valid_Till__c = system.today().addDays(20);
        insert service1;
        resultMap.put('BHS Service Territory', service1.Id);
        
        Service_Territory__c region1 = new Service_Territory__c();
        region1.Name = 'BHS Region';
        region1.Service__c = 'BHS';
        region1.Type__c = 'Region';
        region1.Parent__c = service1.Id;
        region1.Business_Hour_start__c = Time.newInstance(10, 00, 00, 00);
        region1.Business_Hour_End__c = Time.newInstance(18, 00, 00, 00);
        region1.HOD__c = resultMap.get('TL CONTACT');
        region1.Valid_From__c = system.today() - 10;
        region1.Valid_Till__c = system.today().addDays(20);
        insert region1;
        resultMap.put('BHS Region Territory', region1.Id);
        
        Service_Territory__c unit1 = new Service_Territory__c();
        unit1.Name = 'BHS Unit';
        unit1.Service__c = 'BHS';
        unit1.Type__c = 'Unit';
        unit1.Parent__c = region1.Id;
        unit1.HOD__c = resultMap.get('TL CONTACT');
        unit1.Valid_From__c = system.today() - 10;
        unit1.Valid_Till__c = system.today().addDays(20);
        insert unit1;
        resultMap.put('BHS Unit Territory', unit1.Id);
        
        Service_Territory__c city1 = new Service_Territory__c();
        city1.Name = 'BHS City';
        city1.Service__c = 'BHS';
        city1.Type__c = 'Territory';
        city1.Parent__c = unit1.Id;
        city1.HOD__c = resultMap.get('TA CONTACT');
        city1.Valid_From__c = system.today() - 10;
        city1.Valid_Till__c = system.today().addDays(20);
        city1.Business_Hour_start__c = Time.newInstance(10, 00, 00, 00);
        city1.Business_Hour_End__c = Time.newInstance(18, 00, 00, 00);
        insert city1;
        resultMap.put('BHS City Territory', city1.Id);
        
        Service_Territory__c pincode1 = new Service_Territory__c();
        pincode1.Name = '333333';
        pincode1.Service__c = 'BHS';
        pincode1.Type__c = 'Pincode';
        pincode1.Parent__c = city1.Id;
        pincode1.Pincode__c = p1.Id;
        pincode1.Valid_From__c = system.today() - 10;
        pincode1.Valid_Till__c = system.today().addDays(20);
        insert pincode1;
        resultMap.put('BHS Pincode Territory', pincode1.Id);
        
        return resultMap;
    }
    
    public static Map<String, Id> createUserDetails() {
        Map<String, Id> resultMap = new Map<String, Id>();
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id dealerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = 'Test Dealer';
        a.Type__c = 'CI';
        a.Phone = '1234567123';
        a.Dealer_Code__c = 'D44444';
        a.RecordTypeId = dealerRecordTypeId;
        a.OwnerId = u.Id;
        insert a;
        resultMap.put('DEALER', a.Id);
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'CA 1';
        c.MobilePhone = '5500220033';
        c.Email = 'ca1@test.in';
        c.Start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c.Active__c = true;
        c.AccountId = a.Id;
        c.Persona__c = 'CA';
        c.LOB__c = 'SPS';
        c.PositionID__c = 'CA1';
        c.Employee_Code__c = 'CA1';
        c.OwnerId = u.Id;
        insert c;
        resultMap.put('CA CONTACT', c.Id);
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;       
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerAutoResponseEmail = false;       
        dmo.optAllOrNone = false;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Customer Associate (CA)' Limit 1];
        String nick = c.email!=null?c.email.substring(0, c.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        
        User newUser = new User(alias=c.firstName, email = c.email, emailencodingkey = 'UTF-8', 
                                 firstname = c.firstName, lastname = c.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c.Id,timezonesidkey = 'Asia/Kolkata', PositionId__c=c.PositionID__c,
                                 username = c.email,CommunityNickname = nick,ProfileId =portalProfile.Id, IsActive = true);
        newUser.setOptions(dmo);
        insert newUser;
        resultMap.put('CA USER', newUser.Id);
        
        Id contractorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contractors').getRecordTypeId();
        Account contractor1 = new Account();
        contractor1.Name = 'Test Contractor';
        contractor1.RecordTypeId = contractorRecordTypeId;
        contractor1.OwnerId = u.Id;
        contractor1.Capacity__c = 5;
        contractor1.Phone = '1234512345';
        insert contractor1;
        resultMap.put('CONTRACTOR 1', contractor1.Id);
        
        Dealer_Contractor_Mapping__c dcm1 = new Dealer_Contractor_Mapping__c();
        dcm1.Dealer__c = a.Id;
        dcm1.Contractor__c = contractor1.Id;
        dcm1.Relation_Status__c = 'Active';
        dcm1.Relationship_type__c = 'Dealer_Contractor';
        insert dcm1;
        
        dcm1.Relation_Status__c = 'Inactive';
        update dcm1;
        
        Id companyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Asian Paints').getRecordTypeId();
        Account a1 = new Account();
        a1.Name = 'Test Company';
        a1.Phone = '1234567123';
        a1.RecordTypeId = companyRecordTypeId;
        a1.OwnerId = u.Id;
        insert a1;
        resultMap.put('COMPANY', a1.Id);
        
        Contact tl = new Contact();
        tl.FirstName = 'Test';
        tl.LastName = 'TL';
        tl.MobilePhone = '4400440011';
        tl.Email = 'tl@test.in';
        tl.Active__c = true;
        tl.AccountId = a1.Id;
        tl.Persona__c = 'TL';
        tl.LOB__c = 'SPS';
        tl.OwnerId = u.Id;
        insert tl;
        resultMap.put('TL CONTACT', tl.Id);
        
        Profile portalProfileTeam = [SELECT Id FROM Profile WHERE Name = 'Team Lead' Limit 1];
        String nicktl = tl.email!=null?tl.email.substring(0, tl.email.indexOf('@')):'';
        nicktl += Datetime.now().getTime();
        
        User teamLead = new User(alias=tl.firstName, email = tl.email, emailencodingkey = 'UTF-8', 
                                 firstname = tl.firstName, lastname = tl.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = tl.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = tl.email,CommunityNickname = nicktl,ProfileId = portalProfileTeam.Id, IsActive = true);
        teamLead.setOptions(dmo);
        insert teamLead;
        resultMap.put('TL USER', teamLead.Id);
        
        Contact ta = new Contact();
        ta.FirstName = 'Test';
        ta.LastName = 'TA';
        ta.MobilePhone = '4400440022';
        ta.Email = 'ta@test.in';
        ta.Active__c = true;
        ta.AccountId = a1.Id;
        ta.Persona__c = 'TA';
        ta.LOB__c = 'SPS';
        ta.OwnerId = u.Id;
        insert ta;
        resultMap.put('TA CONTACT', ta.Id);
        
        String nickta = ta.email!=null?ta.email.substring(0, ta.email.indexOf('@')):'';
        nickta += Datetime.now().getTime();
        
        User teamA = new User(alias=ta.firstName, email = ta.email, emailencodingkey = 'UTF-8', 
                                 firstname = ta.firstName, lastname = ta.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = ta.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = ta.email,CommunityNickname = nickta,ProfileId = portalProfileTeam.Id, IsActive = true);
        teamA.setOptions(dmo);
        insert teamA;
        resultMap.put('TA USER', teamA.Id);
        
        Contact sso = new Contact();
        sso.FirstName = 'Test';
        sso.LastName = 'SSO';
        sso.MobilePhone = '4400440099';
        sso.Email = 'sso@test.in';
        sso.Active__c = true;
        sso.AccountId = a1.Id;
        sso.Persona__c = 'SSO';
        sso.LOB__c = 'SPS';
        sso.PositionID__c = 'SSO';
        sso.OwnerId = u.Id;
        insert sso;
        resultMap.put('SSO CONTACT', sso.Id);
        
        Profile hodProfile = [SELECT Id FROM Profile WHERE Name = 'HOD' Limit 1];
        String nickSSO = sso.email!=null?sso.email.substring(0, sso.email.indexOf('@')):'';
        nickSSO += Datetime.now().getTime();
        
        User ssoUser = new User(alias=sso.firstName, email = sso.email, emailencodingkey = 'UTF-8', 
                                 firstname = sso.firstName, lastname = sso.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US', timezonesidkey = 'Asia/Kolkata',PositionID__c =sso.PositionID__c,
                                 username = sso.email,CommunityNickname = nickSSO,ProfileId =hodProfile.Id, IsActive = true);
        ssoUser.setOptions(dmo);
        insert ssoUser;
        resultMap.put('SSO USER', ssoUser.Id);
        
        Contact uh = new Contact();
        uh.FirstName = 'Test';
        uh.LastName = 'UH';
        uh.MobilePhone = '4400440088';
        uh.Email = 'uh@test.in';
        uh.Active__c = true;
        uh.AccountId = a1.Id;
        uh.Persona__c = 'UH';
        uh.LOB__c = 'SPS';
        uh.PositionID__c = 'UH';
        uh.OwnerId = u.Id;
        insert uh;
        resultMap.put('UH CONTACT', uh.Id);
        
        String nickUH = uh.email!=null?uh.email.substring(0, uh.email.indexOf('@')):'';
        nickUH += Datetime.now().getTime();
        
        User uhUser = new User(alias=uh.firstName, email = uh.email, emailencodingkey = 'UTF-8',
                                 firstname = uh.firstName, lastname = uh.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US', timezonesidkey = 'Asia/Kolkata',PositionID__c =uh.PositionID__c,
                                 username = uh.email,CommunityNickname = nickUH,ProfileId =hodProfile.Id, IsActive = true);
        uhUser.setOptions(dmo);
        insert uhUser;
        resultMap.put('UH USER', uhUser.Id);
        
        Contact dm = new Contact();
        dm.FirstName = 'Test';
        dm.LastName = 'DM';
        dm.MobilePhone = '4400440088';
        dm.Email = 'dm@test.in';
        dm.Active__c = true;
        dm.AccountId = a1.Id;
        dm.Persona__c = 'DM';
        dm.LOB__c = 'SPS';
        dm.PositionID__c = 'DM';
        dm.OwnerId = u.Id;
        insert dm;
        resultMap.put('DM CONTACT', dm.Id);
        
        String nickDM = dm.email!=null?dm.email.substring(0, dm.email.indexOf('@')):'';
        nickDM += Datetime.now().getTime();
        
        User dmUser = new User(alias=dm.firstName, email = dm.email, emailencodingkey = 'UTF-8', 
                                 firstname = dm.firstName, lastname = dm.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US', timezonesidkey = 'Asia/Kolkata',PositionID__c =dm.PositionID__c,
                                 username = dm.email,CommunityNickname = nickDM,ProfileId =hodProfile.Id, IsActive = true);
        dmUser.setOptions(dmo);
        insert dmUser;
        resultMap.put('DM USER', dmUser.Id);
        
        Contact ces = new Contact();
        ces.FirstName = 'Test';
        ces.LastName = 'CES';
        ces.MobilePhone = '4400440099';
        ces.Email = 'ces@test.in';
        ces.Active__c = true;
        ces.AccountId = a1.Id;
        ces.Persona__c = 'CES A';
        ces.LOB__c = 'BHS';
        ces.OwnerId = u.Id;
        ces.PositionID__c = '12345';
        insert ces;
        resultMap.put('CES CONTACT', ces.Id);
        
        Profile cesProfileTeam = [SELECT Id FROM Profile WHERE Name = 'CES Agent (CES)' Limit 1];
        String nickces = ces.email!=null?ces.email.substring(0, ces.email.indexOf('@')):'';
        nickces += Datetime.now().getTime();
        
        User cesUser = new User(alias=ces.firstName, email = ces.email, emailencodingkey = 'UTF-8', PositionID__c = ces.PositionID__c,
                                 firstname = ces.firstName, lastname = ces.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = ces.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = ces.email,CommunityNickname = nickces, ProfileId = cesProfileTeam.Id, IsActive = true);
        cesUser.setOptions(dmo);
        insert cesUser;
        resultMap.put('CES USER', cesUser.Id);
        
        return resultMap;
    }
    
    public static void enableApplicationLog() {
        Application_Logs__c ap = new Application_Logs__c();
        ap.Name = 'Application Log';
        ap.Enable_Logs__c = true;
        insert ap;
    }
    
    public static void createAODSetup(Campaign c) {
        AOD_Master__c am = new AOD_Master__c();
        am.Campaign__c = c.Id;
        am.Service_Id__c = '1';
        insert am;
    }
    
    public static Campaign createCampaign(String service, String subService){
        Campaign c = new Campaign();
        c.Name = 'Test Campaign';
        c.IsActive = true;
        c.StartDate = system.today();
        c.EndDate = system.today().addDays(60);
        c.BU__c = service;
        c.Source__c = 'Advertisement';
        c.Sub_Service__c = subservice;
        c.Status = 'In Progress';
        c.Digital_Marketing_Campaign_Code__c = service;
        c.Taggable_Campaign__c = true;
        insert c;
        return c;
    }
}