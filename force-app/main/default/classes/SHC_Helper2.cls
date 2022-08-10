public class SHC_Helper2 {
    public class areaWrapper{
        @AuraEnabled public string area {get;set;}
        @AuraEnabled public string reco {get;set;}  //used for smart reco
        @AuraEnabled public List<SHC_helper.symptomWrapper> symptoms {get;set;}
        
    }
    @AuraEnabled
    public static Site_Health_Card__c getSHCData(String shcId){
        
        Site_Health_Card__c shc = [SELECT Name, Interior_Surface_Observations__c, Exterior_Surface_Observations__c, SmartCare_Observations__c,
                                   Customer_Name__c, Opportunity__r.Name, Createddate, Address__c, Dealer__c, Opportunity__r.CA_Name__r.Name, Opportunity__r.Account.PersonContact.mobilephone,
                                   Opportunity__r.Dealer__r.BillingStreet,Opportunity__r.Dealer__r.BillingCity ,Opportunity__r.Dealer__r.BillingState ,
                                   Opportunity__r.Dealer__r.BillingPostalCode,Opportunity__r.Dealer__r.BillingCountry
                                   FROM Site_Health_Card__c WHERE ID =: shcId][0];
        return shc;
        
    }
    
    @AuraEnabled 
    public static List<areaWrapper> getSymptoms(String shcId, String surfaceType){
        List<areaWrapper> areaList = new List<areaWrapper>();
        Map<String,areaWrapper> areaMap = new Map<String,areaWrapper>();
        for(Health_Card_Observation__c h : [SELECT Area__c, Affected_Area_sqft__c,Index__c,Additional_Product__c,Recommended_Product__c, Recommendations__c, Type__c, Severity__c, Symptom__c  FROM Health_Card_Observation__c 
                                            WHERE Site_Health_Card__c =: shcId AND Type__c =: surfaceType ]){
                                                if(surfaceType == 'Smartcare Warranty Solutions'){
                                                    areaWrapper a = new areaWrapper();
                                                    a.area = h.symptom__c;  //resuing area for symptom in smart care
                                                    a.reco = h.Recommendations__c;
                                                    areaList.add(a);
                                                    
                                                } 
                                                else{
                                                    List<SHC_Helper.symptomWrapper> swListNew =  new  List<SHC_Helper.symptomWrapper>();
                                                    areaWrapper aw = new areaWrapper();
                                                    if(areaMap.get(h.index__c) == null)
                                                        aw = new areaWrapper();
                                                    else  { aw =  areaMap.get(h.index__c);
                                                           swListNew = aw.symptoms;
                                                          }
                                                    
                                                    
                                                    aw.area = h.Area__c;
                                                    SHC_helper.symptomWrapper sw = new SHC_helper.symptomWrapper();  
                                                    sw.severity = h.Severity__c;
                                                    sw.affectedArea = String.valueof(h.Affected_Area_sqft__c);
                                                    sw.symptomType = h.Symptom__c;
                                                    sw.recoProduct = h.Recommended_Product__c;
                                                    sw.addProduct = h.Additional_Product__c;
                                                    swListNew.add(sw);
                                                    aw.symptoms = swListNew;                     
                                                    areaMap.put(h.index__c, aw);
                                                }
                                            }
        
       if(surfaceType == 'Smartcare Warranty Solutions') return areaList;
        return areaMap.values();
    }
    
    @Auraenabled
    public static List<SHC_Helper.fileWrapper> getFiles(String shcId){
        List<SHC_Helper.fileWrapper> fileList = new List<SHC_Helper.fileWrapper>();
        for(ContentDocumentLink lstCL : [SELECT ContentDocumentId, ContentDocument.title FROM ContentDocumentLink WHERE LinkedEntityId =:shcId AND ContentDocument.filetype !='PDF' LIMIT 10]){
            SHC_Helper.fileWrapper file = new SHC_Helper.fileWrapper();
            file.docId = lstCL.ContentDocumentId;
            file.name =  lstCL.ContentDocument.title;
           fileList.add(file);
        }
        return fileList;
       
      
    }
    
}