@isTest
public class Test_Bot_updateLead {
    Public static testMethod void doTest1() {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        l.Whatsapp_Notification__c = False;
        insert l;
        
        List<Bot_updateLead.PrechatInput> ipList = New List<Bot_updateLead.PrechatInput>();
        Bot_updateLead.PrechatInput c = new Bot_updateLead.PrechatInput();
        c.leadId = l.Id; 
        c.isWorkPlanningPending = 'Yes';
        c.whenToStartWork = 'Immediate';
        c.fullAdress = 'Full Address';
        c.landmark = 'Landmark';
        c.spsRating = '';
        c.idsInteriorOrPainting = ''; //Furniture, false ceiling, flooring etc.
        c.idsDesignArea = '';//Bedroom Interior Design
        c.idsDesignComponents = '';//Bed
        c.idsTypeOfPlace = '';//Flat
        c.WhatsappOptin = 'Yes';
        c.option1BHS = '';//idsDesignComponents = Complete Bedroom Interior Design
        c.option2BHS = '';//idsDesignComponents = Complete Living Room Interior Design
        c.option4BHS = '';//Bathroom
        c.option3BHS = '';
        c.option5BHS = '';
        c.clearDesignComponents = '';
        ipList.add(c);
        List<Bot_updateLead.PrechatOutput> Docs = Bot_updateLead.updateLead(ipList);
        Test.stopTest();
    }
    Public static testMethod void doTest2() { //whatsapp notification true; WhatsappOptin No; whenToStartWork
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'Test Lead';
        l.Email = 'testLead.1@gmail.com';
        l.MobilePhone = '1234567890';
        l.Whatsapp_Notification__c = True;
        insert l;
        
        List<Bot_updateLead.PrechatInput> ipList = New List<Bot_updateLead.PrechatInput>();
        Bot_updateLead.PrechatInput c = new Bot_updateLead.PrechatInput();
        c.leadId = l.Id; 
        //c.isWorkPlanningPending = 'Yes';
        c.whenToStartWork = 'Immediate';
        c.fullAdress = 'Full Address';
        c.landmark = 'Landmark';
        c.spsRating = '';
        c.idsInteriorOrPainting = ''; //Furniture, false ceiling, flooring etc.
        c.idsDesignArea = '';//Bedroom Interior Design
        c.idsDesignComponents = 'Complete Bedroom Interior Design,Complete Living Room Interior Design';//Bed
        c.idsTypeOfPlace = '';//Flat
        c.WhatsappOptin = 'No';
        c.option1BHS = '1';//idsDesignComponents = Complete Bedroom Interior Design
        c.option2BHS = '1';//idsDesignComponents = Complete Living Room Interior Design
        c.option4BHS = '';//Bathroom
        c.option3BHS = '';
        c.option5BHS = '';
        c.clearDesignComponents = '';
        ipList.add(c);
        List<Bot_updateLead.PrechatOutput> Docs = Bot_updateLead.updateLead(ipList);
        Test.stopTest();
    }
}