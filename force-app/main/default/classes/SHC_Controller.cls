public without sharing class SHC_Controller {
    public Site_Health_Card__c shc {get; set;}
    public List<String> smartCare {get;set;}
    public List<areaWrapper> interior {get;set;}
    public List<areaWrapper> exterior {get;set;}
    public string dateOfVisit {get;set;}
    public List<String> images {get;set;}
    public List<imgWrapper> imageList {get;set;}
    public string pincode {get;set;}
    
    public string Website_SHC {get;set;}
    public string SafePainting_Service_SHC {get;set;}
    public string Product_Details_SHC {get;set;}
    public string Waterproofing_Solutions_SHC {get;set;}
    public string Product_Warranty_SHC{get;set;}
    
    public class imgWrapper{
        public string url {get;set;}
        public string name{get;set;}
    }
    public class areaWrapper{
        public string area {get;set;}
        public List<symptomWrapper> swList {get;set;}
    }
    public class symptomWrapper{
        public string reco {get;set;}
        public Decimal affectedArea {get;set;}
        public string severity {get;set;}
    }
    public static integer getPosition(String symptomName){
        switch on symptomName {
            when 'Cracks Interior', 'Cracks Exterior (Vertical/Horizontal Cracks)','Interior Walls' {		
                return 0;
            }	
            when 'Gaps (between 2 different substrates)','Terrace' {		
                return 1;
            }
            when 'Moisture Reading','Vertical Walls', 'Exterior Walls' {		
                return 2;
            }
            when 'Efflorescence'{
                return 3; 
            }
            when 'Plastering Requirement'{
                return 4; 
            }
            when 'Undulations'{
                return 5; 
            }
            when else {		 
                return 0;
            }
        }
    }
    
    public static areaWrapper processValues(Health_Card_Observation__c h , areaWrapper aw){
        
        areaWrapper awNew = new areaWrapper();
        symptomWrapper sDummy = new symptomWrapper();
        List<symptomWrapper> swListNew =  new  List<symptomWrapper>{sDummy, sDummy,sDummy,sDummy,sDummy,sDummy};
            if(aw == null) aw = new areaWrapper();
        else swListNew = aw.swList;
        symptomWrapper swNew = new SymptomWrapper();
        swNew.reco = h.Recommendations__c;
        swNew.affectedArea = h.Affected_Area_sqft__c;
        swNew.severity = h.Severity__c;
        integer pos = getPosition(h.Symptom__c); 
        awNew.area = h.Area__c;
        swListNew[pos] = swNew;
        awNew.swList =swListNew;
        system.debug('in fnc ' + awNew);
        return awNew;      
        
        
    }
    public SHC_Controller(){
        Map<String,areaWrapper> areaMapInt = new Map<String,areaWrapper>();
        Map<String,areaWrapper> areaMapExt = new Map<String,areaWrapper>();
        
        interior = new List<areaWrapper>();
        exterior = new List<areaWrapper>();
        imageList = new List<imgWrapper>();
        images = new List<String>();
      
        String shcID = ApexPages.currentPage().getParameters().get('id');
        
       //shcId ='a0R72000000C0kDEAS';
        
        smartCare = new List<String>();
        for(integer i=0; i<3; i++){ 
            smartCare.add('');
        }
        
        
        shc = [SELECT Name, Interior_Surface_Observations__c, Exterior_Surface_Observations__c, SmartCare_Observations__c,
               Customer_Name__c, Opportunity__r.Name, Createddate, Address__c, Dealer__c, Opportunity__r.CA_Name__r.Name, Opportunity__r.Account.PersonContact.mobilephone,
               Opportunity__r.Dealer__r.BillingStreet,Opportunity__r.Dealer__r.BillingCity ,Opportunity__r.Dealer__r.BillingState ,
               Opportunity__r.Dealer__r.BillingPostalCode,Opportunity__r.Dealer__r.BillingCountry, Dealer_Address__c, Opportunity__r.Owner.Name
               FROM Site_Health_Card__c WHERE ID =: shcId];
        
        dateOfVisit = String.valueof(shc.createddate.day()).leftPad(2,'0') +'-'+String.valueof(shc.createddate.month()).leftPad(2,'0')+'-'+shc.createddate.year();
        pincode = (shc.Opportunity__r.Dealer__r.BillingPostalCode == NULL) ? '' : shc.Opportunity__r.Dealer__r.BillingPostalCode;
        for(Health_Card_Observation__c h : [SELECT Area__c, Affected_Area_sqft__c,Index__c, Recommendations__c, Type__c, Severity__c, Symptom__c  FROM Health_Card_Observation__c WHERE Site_Health_Card__c =: shc.Id]){
            
            integer pos = getPosition(h.Symptom__c); 
            if(h.Type__c == 'Symptoms of Interior Surfaces'){
                areaMapInt.put(h.index__c, processValues(h,areaMapInt.get(h.index__c)));
            }
            else if(h.Type__c == 'Symptoms of Exterior Surfaces'){
                areaMapExt.put(h.index__c, processValues(h,areaMapExt.get(h.index__c)));
            }
            else{
                smartCare[pos] = (h.Recommendations__c == null) ? '': h.Recommendations__c;  
            }
            
        }
       
        
        areaWrapper ad = new areaWrapper();
        symptomWrapper sDummy = new symptomWrapper();
        List<symptomWrapper> sLDummy =  new  List<symptomWrapper>{sDummy, sDummy,sDummy,sDummy,sDummy,sDummy};
            ad.swList = sLDummy;
        interior =areaMapInt.values();
        exterior =areaMapExt.values();
        integer size = interior.size();
        for(integer i=size; i<4; i++) interior.add(ad);
        size = exterior.size();
        for(integer i=size; i<4; i++) exterior.add(ad);
        
        Set<Id> cdId = new Set<Id>();
        for(ContentDocumentLink lstCL : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:shc.Id AND ContentDocument.filetype !='PDF']){
            cdId.add(lstCL.ContentDocumentId);
        }
        List<contentversion> cv = [SELECT versiondata,Title,COntentDocumentId  FROM ContentVersion WHERE COntentDocumentId IN: cdId  LIMIT 10];
        for(integer i=0; i<cv.size(); i++){
             imgWrapper iw = new imgWrapper();
              iw.name = cv[i].title;
            if([select isportalenabled from user where id= :userinfo.getUserId()][0].isPortalEnabled)
               iw.url ='/sfc/servlet.shepherd/document/download/'+cv[i].COntentDocumentId;
            else {
               iw.url = '/services/data/v53.0/sobjects/ContentVersion/'+cv[i].Id+'/VersionData';
              }
             imageList.add(iw);
             
        }
        for(Url__c u: [select name, url__c from url__c]){
            switch on u.name {
                when 'SafePainting_Service_SHC'{ SafePainting_Service_SHC =	u.url__c;}
                when 'Product_Details_SHC' {Product_Details_SHC =	u.url__c;}
                when 'Waterproofing_Solutions_SHC' {Waterproofing_Solutions_SHC =	u.url__c; }
                when 'Product_Warranty_SHC'{ Product_Warranty_SHC =	u.url__c;}
                when 'Website_SHC' {Website_SHC =	u.url__c;}
        	}
        }
        system.debug(SafePainting_Service_SHC);
        
        
    }
}