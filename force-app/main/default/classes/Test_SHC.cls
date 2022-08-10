@isTest
public class Test_SHC {
    @isTest
    static void test(){
        //////////////////////test SHC_Helper
        SHC_Helper.getReco('symptom', 'severity');
        SHC_Helper.getProductNameById('pid');
        Opportunity o = new Opportunity();
        o.CloseDate = Date.today();
        o.Name = 'myOpportunity';
        o.StageName = 'Closed Won';
        o.RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        insert o;
        Site_Health_Card__c shc = new Site_Health_Card__c();
        shc.Opportunity__c = o.id;
        Insert shc;
        SHC_Helper.sendToCustomer(shc.Id, 'medium', 'url', 'site_health_card__c');
        SHC_Helper.sendToCustomer(shc.Id, 'medium', 'url', 'quote');
        SHC_Helper.getDependentPicklistValues('Health_Card_Observation__c', 'Symptom__c', 'Symptoms of Interior Surfaces');
        
        
        List<SHC_helper.symptomWrapper> swList = new List<SHC_helper.symptomWrapper>();
        SHC_helper.symptomWrapper s1 = new SHC_helper.symptomWrapper();
        s1.affectedArea ='100';
        s1.area = 'Bedroom';
        s1.index = '0';
        s1.severity ='1 mm';
        s1.mainType ='Symptoms of Interior Surfaces';
        s1.symptomType ='Cracks Interior';
        SHC_helper.symptomWrapper s2 = new SHC_helper.symptomWrapper();
        s2.affectedArea ='100';
        s2.area = 'Bedroom';
        s2.index = '0';
        s2.severity ='<2.5 mm';
        s2.mainType ='Symptoms of Exterior Surfaces';
        s2.symptomType ='Cracks Exterior (Vertical/Horizontal Cracks)';
        SHC_helper.symptomWrapper s3 = new SHC_helper.symptomWrapper();
        s3.mainType ='Smartcare Warranty Solutions';
        s3.symptomType ='Exterior Walls';
        s3.reco ='Reco';
         SHC_helper.symptomWrapper s4 = new SHC_helper.symptomWrapper();
        s4.affectedArea ='100';
        s4.area = 'Bedroom';
        s4.index = '0';
        s4.severity ='yes';
        s4.mainType ='Symptoms of Interior Surfaces';
        s4.symptomType ='Efflorescence';
         SHC_helper.symptomWrapper s5 = new SHC_helper.symptomWrapper();
        s5.affectedArea ='100';
        s5.area = 'Bedroom';
        s5.index = '0';
        s5.severity ='Yes';
        s5.mainType ='Symptoms of Interior Surfaces';
        s5.symptomType ='Plastering Requirement';
         SHC_helper.symptomWrapper s6 = new SHC_helper.symptomWrapper();
        s6.affectedArea ='100';
        s6.area = 'Bedroom';
        s6.index = '0';
        s6.severity ='>2m';
        s6.mainType ='Symptoms of Interior Surfaces';
        s6.symptomType ='Undulations';
        swList.add(s1);
        swList.add(s2);
        swList.add(s3);
        swList.add(s4);
        swList.add(s5);
        swList.add(s6);
        List<SHC_Helper.fileWrapper> files = new List<SHC_Helper.fileWrapper>();
        
        
        SHC_helper.shcWrapper shcW = new SHC_helper.shcWrapper();
        shcW.mode = 'new';
        shcW.oppId = o.Id;
        shcW.obvExterior = 'Exterior Observation';
        shcW.obvInterior = 'Interior Observation';
        shcW.obvSmartcare = 'Smartcare Observation';
        shcW.files = files;
        String shcId =SHC_helper.createSHC(swList, shcW);
        shcW.shcId = shcId;
        shcW.mode = 'clone';
        shcId =SHC_helper.createSHC(swList, shcW);
        shcW.mode = 'newBiz';
        shcId =SHC_helper.createSHC(swList, shcW);
        shcW.mode = 'edit';
        shcId =SHC_helper.createSHC(swList, shcW);
        SHC_helper.savePDF(shcId, 'Site_health_Card__c');
        SHC_helper.getDocURL(shcId);
        
        ///////////////////Test SHC_Helper2
        SHC_Helper2.getSHCData(shcId);
        SHC_Helper2.getSymptoms(shcId, 'Symptoms of Interior Surfaces');
        SHC_Helper2.getSymptoms(shcId, 'Smartcare Warranty Solutions');
        SHC_helper2.getFiles(shcId);
        
        //////////////////Test SHC Controller
         

			ApexPages.currentPage().getParameters().put('id', shcId);
			SHC_Controller sController = new SHC_Controller();
			

		
        
      ///  PageReference PDf =  Page.SHC_vf;
      //   pDF.getParameters().put('id',shcId);
      //  PDf.setRedirect(true);
    }
}