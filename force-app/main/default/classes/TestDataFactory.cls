@isTest
public class TestDataFactory {
	
    Public static campaign createCampaign(string service, string subservice){
    	campaign c = new Campaign();
        c.Name = 'test campaign';
        c.IsActive = true;
        c.StartDate = system.today();
        c.EndDate = system.today().addDays(60);
        c.BU__c = service;
        c.Source__c = 'Advertisement';
        c.Sub_Service__c = subservice;
        c.Status = 'In Progress';  
        c.Taggable_Campaign__c =true;
        insert c;
        return c;
    }
    
    Public Static Lead createLead_For_YM(string mobile, string email, string pincode, string recordtype, string campaign,
                                        boolean consentWhatsapp){
        Service_Territory__c st = new Service_Territory__c();
        st.Name = 'Test Territory';
        st.Type__c = 'Region';
        st.Business_Hour_start__c = Time.newInstance(10, 00, 00, 00);
        st.Business_Hour_End__c = Time.newInstance(18, 00, 00, 00);
        st.Service__c = 'SPS';
        st.Valid_From__c = system.today();
        st.Valid_Till__c = system.today().addDays(30);
        insert st;
        
        Lead lead = new Lead(lastname = 'Last Name', MobilePhone = mobile, 
                             RecordTypeId = recordtype,Email = email, 
                             Pincode__c = pincode, YM_Campaign_Code__c = 'SPS_SA',
                             Status = 'New', Service_Territory__c = st.Id,
                             Consent_for_Whatsapp__c = consentWhatsapp,
                             House__c = '101', Floor__c='1',
                             street = 'ABC', City = 'Pune',
                             State = 'Maharashtra', Country = 'India',
                             Last_Appointment_Start_Date_Time__c = system.now().addHours(2),
                             Last_Appointment_End_Date_Time__c = system.now().addHours(2)
                            );
        insert lead;
        return lead;
    }
    
    Public static Pincode__c createPincodeRecord(string pincode){
        Pincode__c pin = new Pincode__c();
        pin.Name = pincode;
        pin.City__c = 'AHMEDABAD';
        pin.Country__c = 'India';
        pin.Country_Code__c = 'IN';
        pin.State__c = 'Maharashtra';
        pin.Pincode_Ext__c = pincode;
        insert pin;
        return pin;
    } 
    
    Public static Lead createLead(string mobile, string email, string pincode, string recordtype, string campaign){
        
        Service_Territory__c st = new Service_Territory__c();
        st.Name = 'Test Territory';
        st.Type__c = 'Region';
        st.Business_Hour_start__c = Time.newInstance(10, 00, 00, 00);
        st.Business_Hour_End__c = Time.newInstance(18, 00, 00, 00);
        st.Service__c = 'SPS';
        st.Valid_From__c = system.today();
        st.Valid_Till__c = system.today().addDays(30);
        insert st;
        
     	Lead l = new Lead();
        l.LastName = 'Last Name';
        l.Pincode__c = pincode;
        l.MobilePhone = mobile;
        l.Email = email;
        l.RecordTypeId = recordtype;
        l.CampaignName__c = campaign;
        //l.Skills__c = 'San Assure;';
        l.Status = 'New';
        l.Service_Territory__c = st.Id;
        insert l;
        return l;
    }
    
    Public static Account createPersonAccount(string mobile, string email){
        Account a = new Account();
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        a.FirstName = 'firstName';
        a.LastName = 'lastName';
        a.PersonMobilePhone = mobile;
        a.PersonEmail = email;
        a.RecordTypeId = devRecordTypeId;
        a.PersonMailingStreet = 'street';
        a.PersonMailingCity = 'Pune';
        a.PersonMailingState = 'Maharashtra';
        a.PersonMailingCountry = 'India';
        insert a;
        return a;
    }
    
    Public static Opportunity createOpportunity(string aId, string recordTypeId, string pincode){
        Opportunity op = new Opportunity();
        op.Name = 'testOpty';
        op.AccountId = aId;
        op.RecordTypeId = recordTypeId;
        op.CloseDate = system.today().addDays(30);
        op.StageName = 'Associate Checked - In';
        op.Pincode__c = '123456';
        op.Pincode_lookup__c = pincode;
        insert op;
        return op;
    }
    
    Public static Map<String,string> createContact(){
        //createUser();
        Map<string,string> resultMap = new Map<string,string>();
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = 'testAccount';
        a.Type__c = 'CI';
        a.Phone = '1234567123';
        a.Dealer_Code__c = 'D12345';
        a.RecordTypeId = devRecordTypeId;
        a.OwnerId = u.Id;
        insert a;
        resultMap.put('DEALER',a.Id);
        
        Id contractorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contractors').getRecordTypeId();
        Account con1 = new Account();
        con1.RecordTypeId = contractorRecordTypeId;
        con1.Name = 'Contractor 1 Dealer 1';
        con1.Phone = '1100885544';
        con1.Capacity__c = 10;
        con1.OwnerId = u.Id;
        insert con1;
        
        Dealer_Contractor_Mapping__c dCon1 = new Dealer_Contractor_Mapping__c();
        dCon1.Dealer__c = a.Id;
        dCon1.Contractor__c = con1.Id;
        dCon1.Relation_Status__c = 'Active';
        dCon1.Relationship_type__c = 'Dealer_Contractor';
        dCon1.Sub_Type__c = 'Primary';
        insert dCon1;
        
        Account con2 = new Account();
        con2.RecordTypeId = contractorRecordTypeId;
        con2.Name = 'Contractor 2 Dealer 1';
        con2.Phone = '1100885599';
        con2.Capacity__c = 10;
        con2.OwnerId = u.Id;
        insert con2;
        
        Dealer_Contractor_Mapping__c dCon2 = new Dealer_Contractor_Mapping__c();
        dCon2.Dealer__c = a.Id;
        dCon2.Contractor__c = con2.Id;
        dCon2.Relation_Status__c = 'Active';
        dCon2.Relationship_type__c = 'Dealer_Contractor';
        dCon2.Sub_Type__c = 'Primary';
        insert dCon2;
        
        contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'test contact';
        c.mobilePhone = '1234567123';
        c.email = 'test@contact.in';
        c.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c.Active__c = true;
        c.AccountId = a.Id;
        insert c;
        resultMap.put('CA',c.Id);
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;       
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerAutoResponseEmail = false;       
        dmo.optAllOrNone = false;
        
        system.debug('c::'+c.Id);
        // create portal user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Associate (SA)' Limit 1];
        string nick = c.email!=null?c.email.substring(0, c.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        //Profile p = [select Id from Profile where Name = ''];
        User newUser1 = new User(alias=c.firstName, email = c.email, emailencodingkey = 'UTF-8', 
                                 firstname = c.firstName, lastname = c.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = c.email,CommunityNickname = nick,ProfileId =portalProfile.Id, IsActive = true);
        newUser1.setOptions(dmo);
        insert newUser1;
        
        Service_Master__c sm = new Service_Master__c();
        sm.Service__c = 'SPS';
        sm.Skills__c = 'Nilaya';
        sm.Slot_Duration_in_Hours__c = 1.00;
        insert sm;
        
        Service_Master__c sm3 = new Service_Master__c();
        sm3.Service__c = 'SPS';
        sm3.Skills__c = 'SPS';
        sm3.Slot_Duration_in_Hours__c = 1.00;
        insert sm3;
        
        Service_Master__c sm2 = new Service_Master__c();
        sm2.Service__c = 'BHS';
        sm2.Skills__c = 'BHS';
        sm2.Slot_Duration_in_Hours__c = 1.00;
        insert sm2;
        
        SA_Pincode_Mapping__c pm = new SA_Pincode_Mapping__c();
        pm.Pincode__c = '123456';
        pm.Role__c = 'SA';
        pm.Priority__c = 1;
        pm.SA__c = c.Id;
        pm.Service_Master__c = sm.Id;
        insert pm;
        //returnMap.put('SA',pm.Id);
        
        SA_Pincode_Mapping__c pm2 = new SA_Pincode_Mapping__c();
        pm2.Pincode__c = '123457';
        pm2.Role__c = 'CA';
        pm2.Priority__c = 1;
        pm2.SA__c = c.Id;
        pm2.Service_Master__c = sm.Id;
        insert pm2;
        //returnMap.put('CA',pm2.Id);
        
        SA_Pincode_Mapping__c pm3 = new SA_Pincode_Mapping__c();
        pm3.Pincode__c = '123458';
        pm3.Role__c = 'CES';
        pm3.Priority__c = 1;
        pm3.SA__c = c.Id;
        pm3.Service_Master__c = sm2.Id;
        insert pm3;
        
        Service_Territory__c service = new Service_Territory__c();
        service.Name = 'SPS';
        service.Service__c = 'SPS';
        service.Type__c = 'Service';
        service.Valid_Till__c = system.today().addDays(30);
        service.Valid_From__c = system.today();
        insert service;
        
        Service_Territory__c division = new Service_Territory__c();
        division.Name = 'East';
        division.Type__c = 'Division';
        division.Service__c = 'SPS';
        division.Parent__c = service.Id;
        division.Valid_Till__c = system.today().addDays(30);
        division.Valid_From__c = system.today();
        //vision.HOD__c = userInfo.getUserId();
        insert division;
        
        Service_Territory__c unit = new Service_Territory__c();
        unit.Name = 'UTest';
        unit.Type__c = 'Unit';
        unit.Service__c = 'SPS';
        unit.Parent__c = division.Id;
        unit.Valid_Till__c = system.today().addDays(30);
        unit.Valid_From__c = system.today();
        //it.HOD__c = userInfo.getUserId();
        insert unit;
        resultMap.put('UNIT',unit.Id);
        
        Service_Territory__c region = new Service_Territory__c();
        region.Name = 'RegionTest';
        region.Type__c = 'Region';
        region.Service__c = 'SPS';
        region.Parent__c = unit.Id;
        region.Valid_Till__c = system.today().addDays(30);
        region.Valid_From__c = system.today();
        //gion.HOD__c = userInfo.getUserId();
        region.Business_Hour_start__c = Time.newInstance(10, 00, 00, 00);
        region.Business_Hour_End__c = Time.newInstance(18, 00, 00, 00);
        insert region;
        
        Pincode__c pin = new Pincode__c();
        pin.Name = '123456';
        pin.City__c = 'AHMEDABAD';
        pin.Country__c = 'India';
        pin.Country_Code__c = 'IN';
        pin.Pincode_Ext__c = '123456';
        insert pin;
        resultMap.put('PINCODE',pin.Id);
        
        Service_Territory__c pincode = new Service_Territory__c();
        pincode.Name = 'UTest';
        pincode.Type__c = 'Pincode';
        pincode.Service__c = 'SPS';
        pincode.Parent__c = region.Id;
        pincode.Valid_Till__c = system.today().addDays(30);
        pincode.Valid_From__c = system.today();
        ///ncode.HOD__c = userInfo.getUserId();
        pincode.pincode__c = pin.Id;
        insert pincode;
        
        Account a1 = new Account();
        a1.Name = 'Test Account';
        a1.Type__c = 'CI';
        a1.Phone = '1234567124';
        a1.Dealer_Code__c = 'D12346';
        a1.RecordTypeId = devRecordTypeId;
        a1.OwnerId = u.Id;
        insert a1;
        resultMap.put('DEALER 1', a1.Id);
        
        contact c1 = new Contact();
        c1.FirstName = 'First';
        c1.LastName = 'Test contact';
        c1.mobilePhone = '1234567127';
        c1.email = 'firstTest@contact.in';
        c1.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c1.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c1.Active__c = true;
        c1.AccountId = a1.Id;
        insert c1;
        resultMap.put('CA 1',c1.Id);
        
        string nick1 = c1.email!=null?c1.email.substring(0, c1.email.indexOf('@')):'';
        nick1 += Datetime.now().getTime();
        //Profile p = [select Id from Profile where Name = ''];
        User newUser2 = new User(alias=c1.firstName, email = c1.email, emailencodingkey = 'UTF-8', 
                                 firstname = c1.firstName, lastname = c1.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c1.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = c1.email,CommunityNickname = nick1,ProfileId =portalProfile.Id, IsActive = true);
        newUser2.setOptions(dmo);
        insert newUser2;
        
        SA_Pincode_Mapping__c pm4 = new SA_Pincode_Mapping__c();
        pm4.Pincode__c = '123457';
        pm4.Role__c = 'CA';
        pm4.Priority__c = 1;
        pm4.SA__c = c1.Id;
        pm4.Service_Master__c = sm.Id;
        insert pm4;
        
        return resultMap;
    }
    
    
    public static List<Collateral__c> createCollateral(){
        List<Collateral__c> cList = new List<Collateral__c>();
        Collateral__c c1 = new Collateral__c();
        c1.Name = 'Brochure 1';
        c1.Category__c = 'A';
        c1.Service__c = 'SPS';
        c1.Sub_Service__c = 'Nilaya';
        c1.URL__c = 'www.google.co.in';
        insert c1;
        cList.add(c1);
        
        Collateral__c c2 = new Collateral__c();
        c2.Name = 'Brochure 2';
        c2.Category__c = 'B';
        c2.Service__c = 'BHS';
        c2.Sub_Service__c = 'San Assure';
        c2.URL__c = 'www.google.co.in';
        insert c2;
        cList.add(c2);
        return cList;
        
    }
    
    public static account createDealerAccount(string name, string phone, string dealercode, string type){
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = name;
        a.Type__c = type;
        a.Phone = phone;
        a.Dealer_Code__c = dealercode;
        a.RecordTypeId = devRecordTypeId;
        a.OwnerId = u.Id;
        insert a;
        return a;
    }
    
    public static contact createPortalUser(string firstName, string lastName, string mobile, string email, string accountId, string profileName, string positionId, string persona,boolean isactive){
        contact c = new Contact();
        c.FirstName = firstName;
        c.LastName = lastName;
        c.mobilePhone = mobile;
        c.email = email;
        c.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c.Active__c = true;
        c.AccountId = accountId;
        c.PositionID__c = positionId;
        c.Persona__c = persona;
        insert c;
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;       
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerAutoResponseEmail = false;       
        dmo.optAllOrNone = false;
        
        //system.debug('c::'+c.Id);
        // create portal user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name =:profileName Limit 1]; //
        string nick = c.email!=null?c.email.substring(0, c.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        //Profile p = [select Id from Profile where Name = ''];
        User newUser1 = new User(alias=c.firstName, email = c.email, emailencodingkey = 'UTF-8', 
                                 firstname = c.firstName, lastname = c.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = c.email,CommunityNickname = nick,ProfileId =portalProfile.Id, IsActive = isactive);
        newUser1.setOptions(dmo);
        insert newUser1;
        
        return c;
    }
    
    Public Static Map<string,string> createData_for_Quote(string opportunityId){
        Map<string,string> resultMap = new Map<string,string>();
        Site_Health_Card__c shc = new Site_Health_Card__c();
        shc.Opportunity__c = opportunityId;
        insert shc;
        resultMap.put('SHC',shc.Id);
        string shc_searilze = Json.serialize(shc);
        resultMap.put('SHC_Serialize',shc_searilze);
        
        Health_Card_Observation__c oc = new Health_Card_Observation__c();
        oc.Area__c = 'Kitchen';
        oc.type__c = 'Symptoms of Interior Surfaces';
        oc.Symptom__c = 'Cracks Interior';
        oc.Severity__c = '2 mm';
        oc.Recommendations__c = 'AP WOODTECH TOUCHWOOD MATT';
        oc.Site_Health_Card__c = shc.Id;
        resultMap.put('HCB',oc.Id);
        
        User u = [select id from user where profile.name = 'System Administrator' and UserRoleId != null][0];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealers').getRecordTypeId();
        Account a = new Account();
        a.Name = 'testAccount';
        a.Type__c = 'CI';
        a.Phone = '1234567123';
        a.Dealer_Code__c = 'D12345';
        a.RecordTypeId = devRecordTypeId;
        a.OwnerId = u.Id;
        a.BillingStreet = 'ABC';
        a.BillingCity = 'Pune';
        a.BillingState = 'Maharashtra';
        a.BillingCountry = 'India';
        a.BillingPostalCode = '123456';
        insert a;
        resultMap.put('DEALER',a.Id);
        
        Id contractorRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Contractors').getRecordTypeId();
        Account con1 = new Account();
        con1.RecordTypeId = contractorRecordTypeId;
        con1.Name = 'Contractor 1 Dealer 1';
        con1.Phone = '1100885544';
        con1.Capacity__c = 10;
        con1.OwnerId = u.Id;
        insert con1;
        resultMap.put('Contractor 1',con1.Id);
        
        Dealer_Contractor_Mapping__c dCon1 = new Dealer_Contractor_Mapping__c();
        dCon1.Dealer__c = a.Id;
        dCon1.Contractor__c = con1.Id;
        dCon1.Relation_Status__c = 'Active';
        dCon1.Relationship_type__c = 'Dealer_Contractor';
        dCon1.Sub_Type__c = 'Primary';
        insert dCon1;
        
        Account con2 = new Account();
        con2.RecordTypeId = contractorRecordTypeId;
        con2.Name = 'Contractor 2 Dealer 1';
        con2.Phone = '1100885599';
        con2.Capacity__c = 10;
        con2.OwnerId = u.Id;
        insert con2;
        
        Dealer_Contractor_Mapping__c dCon2 = new Dealer_Contractor_Mapping__c();
        dCon2.Dealer__c = a.Id;
        dCon2.Contractor__c = con2.Id;
        dCon2.Relation_Status__c = 'Active';
        dCon2.Relationship_type__c = 'Dealer_Contractor';
        dCon2.Sub_Type__c = 'Primary';
        insert dCon2;
        
        contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'test contact';
        c.mobilePhone = '1234567123';
        c.email = 'test123@contact.in';
        c.start_Slot__c = Time.newInstance(10, 00, 00, 00);
        c.End_Slot__c = Time.newInstance(18, 00, 00, 00);
        c.Active__c = true;
        c.AccountId = a.Id;
        insert c;
        resultMap.put('CA',c.Id);
        
        Agent_Mapping__c am = new Agent_Mapping__c();
        am.SA__c = c.Id;
        am.CA__c = c.Id;
        am.Active__c = true;
        insert am;
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.EmailHeader.triggerUserEmail = false;       
        dmo.EmailHeader.triggerOtherEmail = false;
        dmo.EmailHeader.triggerAutoResponseEmail = false;       
        dmo.optAllOrNone = false;
        
        // create portal user
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Associate (SA)' Limit 1];
        string nick = c.email!=null?c.email.substring(0, c.email.indexOf('@')):'';
        nick += Datetime.now().getTime();
        //Profile p = [select Id from Profile where Name = ''];
        User newUser1 = new User(alias=c.firstName, email = c.email, emailencodingkey = 'UTF-8', 
                                 firstname = c.firstName, lastname = c.lastname, languagelocalekey = 'en_US',
                                 localesidkey = 'en_US',contactId = c.Id,timezonesidkey = 'Asia/Kolkata',
                                 username = c.email,CommunityNickname = nick,ProfileId =portalProfile.Id, IsActive = true);
        newUser1.setOptions(dmo);
        insert newUser1;
        resultMap.put('Portal USer',newUser1.Id);
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        pb.Id = Test.getStandardPricebookId();
        pb.IsActive = true;
        update pb;
        resultMap.put('PriceBook',pb.Id);
        
        Product2 pd1 = new Product2();
        pd1.name = '3 MGS ALUMINIUM PAINT';
        pd1.ProductCode = '1';
        pd1.Product_Class__c = 'Premium';
        pd1.Tier_Available__c = 'Platinum;';
        pd1.Family = 'Other Top Coats';
        pd1.isActive = true;
        pd1.Product_External_ID__c = '1';
        insert pd1;
        resultMap.put('Product 1',pd1.Id);
        
        Product2 pd2 = new Product2();
        pd2.name = 'AP APEX DURACAST SWIRLTEX - 2';
        pd2.ProductCode = '2';
        pd2.Product_Class__c = 'Economy';
        pd2.Tier_Available__c = 'Gold;DWS;';
        pd2.Family = 'Exterior Textures';
        pd2.isActive = true;
        pd2.Product_External_ID__c = '2';
        pd2.Other_Charge__c = true;
        pd2.Mechanised_Charge__c = true;
        pd2.Masking_Charge__c = true;
        insert pd2;
        resultMap.put('Product 2',pd2.Id);
        
        /*Pricebook2 standardPriceBook = [
            SELECT Id
              FROM Pricebook2
             WHERE isStandard = true
             LIMIT 1
        ];*/
        
        PricebookEntry standardPriceBookEntry = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = pd1.Id,
            UnitPrice = 0,
            UseStandardPrice = false,
            IsActive = true
        );
        insert standardPriceBookEntry;
        resultMap.put('PB Entry 1',standardPriceBookEntry.Id);
        
        PricebookEntry standardPriceBookEntry2 = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = pd2.Id,
            UnitPrice = 0,
            UseStandardPrice = false,
            IsActive = true
        );
        insert standardPriceBookEntry2;
        resultMap.put('PB Entry 2',standardPriceBookEntry2.Id);
        
        return resultMap;
    }
    
}