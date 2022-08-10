public without sharing class SHC_Helper {
    
    
    
    @auraenabled(cacheable=true)
    public static Recommendation getReco(String symptom, String  severity){
        system.debug(symptom + ' '+ severity);
        List<Recommendation> recoList = new List<Recommendation>();
        if(symptom  != null && !String.isBlank(symptom) && severity  != null && !String.isBlank(severity)){
            recoList =   [SELECT Id, Name, Description, Product__c, Product__r.Name FROM Recommendation 
                          WHERE Category__c ='Symptoms' 
                          AND Sub_Cat__c =: symptom
                          AND Attribute__c =: severity
                          AND Product__c!= null
                          Limit 1];
        }
        system.debug(recoList);
        if(recoList.size()>0)
            return recoList[0];
        return null;
        
        
        
    }
    @AuraEnabled 
    public static string getProductNameById(String pid){
        try{
            return [SELECT Name from Product2 where id=: pid][0].Name;
        }
        catch(exception e){
            return '';
        }
    }
    @AuraEnabled 
    public static void deleteFile (String cdId){
        // try{
        contentdocument cd= new contentdocument(id=cdId);
        delete cd;
        // }
        // catch(exception e){}
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> getDependentPicklistValues(String objName, String dependentField, String seletedControllingOption) {
        //System.debug(objName +' '+ dependentField + ' '+seletedControllingOption );
        sObject sObj = Schema.getGlobalDescribe().get(objName).newSObject();
        Schema.DescribeSObjectResult objDescribe = sObj.getSObjectType().getDescribe();     
        map < String, Schema.SObjectField > customFieldMap = objDescribe.fields.getMap();      
        // list < Schema.PicklistEntry > custPickValues = customFieldMap.get('Severity__c').getDescribe().getPickListValues();
        
        Schema.DescribeFieldResult depend = customFieldMap.get(dependentField).getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        system.debug(controlToken);
        if (controlToken == null) {
            return null;
            // new Map<String, List<String>>();
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        //system.debug(control);
        List<Schema.PicklistEntry> controlEntries;
        if(control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String,List<String>> dependentPicklistValues = new Map<String,List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                    String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                        (controlEntries == null
                         ?   (Object) (index == 1)
                         :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                        );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        //system.debug(dependentPicklistValues.get(seletedControllingOption));
        return dependentPicklistValues.get(seletedControllingOption);
        //return dependentPicklistValues;
    }
    public class symptomWrapper{
        @auraENabled public string area {get;set;}
        @auraENabled public string index {get;set;}
        @auraEnabled public string mainType {get;set;}
        @auraEnabled public string symptomType {get;set;}
        //  @auraEnabled public string observation {get;set;}
        @auraEnabled public string severity {get;set;}
        @auraEnabled public string affectedArea {get;set;}
        // @auraEnabled public List<string> files {get;set;}
        @auraEnabled public string reco {get;set;}
        @auraEnabled public string recoProduct {get;set;}
        @auraEnabled public string addProduct {get;set;}
    }
    public class shcWrapper{
        @auraENabled public string oppId {get;set;}
        @auraENabled public string obvInterior {get;set;}
        @auraEnabled public string obvExterior {get;set;}
        @auraEnabled public string obvSmartcare {get;set;}
        @auraEnabled public List<fileWrapper> files {get;set;}
        @auraEnabled public string mode {get;set;}
        @auraENabled public string shcId {get;set;} //for editing
    }
    public class fileWrapper{
        @AuraEnabled public string docId {get;set;}
        @AuraEnabled public string name {get;set;}
        @AuraEnabled public Boolean isExisting {get;set;}
    }
    
    @Auraenabled
    public static string createSHC(List<symptomWrapper> swList, shcWrapper shcW){
        system.debug(shcW);
        system.debug(swList);
        Site_Health_Card__c shc = new Site_Health_Card__c (
            Interior_Surface_Observations__c = shcW.obvInterior,
            Exterior_Surface_Observations__c = shcW.obvExterior,
            SmartCare_Observations__c = shcW.obvSmartcare);
        if(shcW.mode =='new') {
            shc.Opportunity__c = shcW.oppId;
            insert shc;
        }
        else if(shcW.mode =='clone'){
            shc.Opportunity__c  = [SELECT Opportunity__c from Site_Health_Card__c where Id =: shcW.shcId][0].Opportunity__c;
            insert shc;
        }
        else if(shcW.mode =='newBiz'){
            Id oppOld  = [SELECT Opportunity__c from Site_Health_Card__c where Id =: shcW.shcId][0].Opportunity__c;
            Opportunity old = [Select Name, CloseDate, StageName, AccountId, Lead_Id__c,RecordTypeId,Dealer__c,Pincode__c,Pincode_lookup__c,
                               Address__c, Amount, Is_the_any_additional__c, Any_other_work_planned_during_this_perio__c,Appointment_Type__c, Assigned_DateTime__c,
                               Bedroom_Interior_Design__c, Bedroom_Interior_Design_Components__c,Budget__c, Budget_Confirmed__c,Building__c, CA_Name__c, CA_Remarks_any_otherwork__c,
                               CA_Remarks_paint_performance__c, CA_Remarks_specific_area__c,CA_Remarks_preference_texture__c,CA_Reason_for_Painting__c, CA_Remarks_painting_execution__c,
                               City__c, Complete_Home_Interiors__c, Complete_Modular_Kitchen__c, ContractId,Converted_Record_Type__c, Current_Owner_PositionID__c,Current_Owner_Email__c,
                               Current_Owner_Employee_Id__c, Current_Owner_Mobile__c,Current_Owner_Name__c, Date_of_Design_Sharing__c, Date_of_Installaion__c,Description, Destination_System_Lead_Id__c,
                               Discovery_Completed__c, Disposition_in_Last_Call__c, Division_Head_DH__c,ERP_B1_Id__c,Expectation_on_Paint__c, ExpectedRevenue,External_Lead_Creator_Employee_Id__c,External_Lead_Creator_Mobile__c, 
                               External_Lead_Creator_Name__c,External_Lead_Creator_Position_Code__c, External_System_Update__c, Firm_BP__c, Firm_Mobile__c, Firm_Name__c, FollowUp_DateTime_in_Last_Call__c, 
                               ForecastCategoryName, If_interior_design_then_what_all_decor__c, Initiator_BP__c,Initiator_Mobile__c, Initiator_Name__c, Integration_Source__c, Is_Active__c, Is_construction_work_going_on__c, 
                               Is_Flat_Rented__c, Is_there_a_local_painter_hired__c, Last_Appointment_End_Date__c, Last_Appointment_Start_Date__c, LastModifiedTime__c,  LeadSource, Living_Room_Interior_Design__c, Living_Room_Interior_Design_Components__c,
                               Loss_Reason__c, NCT_Counter__c, New_Address__c, NextStep, IqScore, Other_Home_Areas__c, Other_Home_Areas_Components__c,Painting_Area__c, Phone_Opt_Out__c, Preferences_on_Texture_or_Designs__c, Preferences_on__c,Pricebook2Id,  CampaignId,
                               Primary_Contractor__c, Priority__c, IsPrivate, Probability, Qualification_Status__c, TotalOpportunityQuantity, Reason_for_painting__c, Referral_Type__c, Referrer_Mobile__c, Referrer_Name__c, Refferal_Email__c, Repeat_Opty__c, ROI_Analysis_Completed__c,
                               Service_Territory__c, Site__c, Site_Closure_Date_Sleek__c, Skills__c, SMS_Opt_Out__c, Source_of_Awarness_SOA__c, Source_System_Lead_ID__c, Specific_areas_of__c, SSO__c, State__c, Status_From_API__c, Sub_Disposition_in_Last_Call__c, Team_Lead_1_TL1__c, 
                               Team_Lead_2_TL2__c, Total_Value__c, Type, Type_of_Place__c, Unit_Head_UH__c, Web_Opt_Out__c, What_is_the_occasion_for_painting__c,What_is_the_Requirement__c,What_is_the_size_of_the_house__c, What_is_the_timeline_for_painting__c
                               from Opportunity WHERE ID =: oppOld LIMIT 1];
            Opportunity oNew =old.clone(false, false, false, false);
            oNew.New_Address__c = true;
            insert oNew;
            shc.Opportunity__c = oNew.Id;
            insert shc;
        }
        else if(shcW.mode == 'edit'){
            Delete [SELECT ID FROM Health_Card_Observation__c where Site_Health_Card__c =: shcW.shcId];
            Delete [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:shcW.shcId AND ContentDocument.filetype ='PDF'];
            
            shc.Id = shcW.shcId;
            update shc;
        }
        
        
        
        List<Health_Card_Observation__c> hcoToInsert = new List<Health_Card_Observation__c>();
        List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
        List<ContentDocument> cdToUpdate = new List<ContentDocument>();
        List<ContentVersion> cvToInsert = new List<ContentVersion>();
        if(shcW.mode =='new' || shcW.mode == 'edit') {
            for(fileWrapper s: shcW.files){
                ContentDocument d = new ContentDocument(Id = s.docId, title = s.name);
                cdToUpdate.add(d);
                if(!s.isExisting){
                    ContentDocumentLink contentlink = new ContentDocumentLink();
                    contentlink.LinkedEntityId = shc.Id;
                    contentlink.contentdocumentid = s.docId;
                    contentlink.ShareType = 'V';
                    cdlToInsert.add(contentlink);
                }
            }
            insert cdlToInsert;
            update cdToUpdate;
        }
        else{
            Set<Id> cdId = new Set<Id>();
            Map<Id,String> cdMap = new Map<Id,String>(); //cdId, title
            for(fileWrapper s: shcW.files){
                if(s.isExisting) {
                    cdId.add(s.docId); //copy cv in case of exisitng files
                    cdMap.put(s.docId, s.name);
                }
                else{ //only create content doc link for new files
                    ContentDocument d = new ContentDocument(Id = s.docId, title = s.name);
                    cdToUpdate.add(d);
                    ContentDocumentLink contentlink = new ContentDocumentLink();
                    contentlink.LinkedEntityId = shc.Id;
                    contentlink.contentdocumentid = s.docId;
                    contentlink.ShareType = 'V';
                    cdlToInsert.add(contentlink);  
                    
                }
            }
            for(ContentVersion cv : [SELECT pathOnClient,contentDocumentId, TagCsv, Title, VersionData FROM ContentVersion WHERE contentDocumentId IN: cdMap.keySet()]){
                ContentVersion newCv = new ContentVersion(pathOnClient=cv.pathOnClient,
                                                          Title=cdMap.get(cv.contentDocumentId), 
                                                          VersionData=cv.VersionData);
                cvToInsert.add(newCv);
            }
            Insert cvToInsert;
            Set<Id> cvId = new Set<Id>();
            for(contentVersion cv : cvToInsert) {
                cvId.add(cv.Id);
                system.debug(cv.Title);
            }
            system.debug('after cv loop');
            for(ContentVersion cv: [SELECT contentDocumentId, title FROM ContentVersion WHERE ID IN: cvId]){
                ContentDocument d = new ContentDocument(Id = cv.ContentDocumentId, title = cv.title);
                cdToUpdate.add(d);
                system.debug(d);
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = shc.Id;
                contentlink.contentdocumentid = cv.contentDOcumentId;
                contentlink.ShareType = 'V';
                cdlToInsert.add(contentlink);
            }
            Insert cdlToInsert;
            update cdToUpdate;  
            
        }
        
        for (symptomWrapper s: swList){
            system.debug(s);
            if(!(s.mainType == 'Smartcare Warranty Solutions' && (s.reco == null || s.reco == ''))){
                Health_Card_Observation__c hco = new Health_Card_Observation__c();
                hco.Site_Health_Card__c = shc.Id;
                hco.Type__c = s.mainType;
                hco.Symptom__c = s.symptomType;
                hco.Severity__c = s.severity;
                hco.Area__c = s.area;
                if(s.affectedArea !=null) hco.Affected_Area_sqft__c = Decimal.valueOf(s.affectedArea);
                hco.index__c = s.index;
                hco.recommendations__c = s.reco;
                hco.Additional_Product__c = s.addProduct;
                hco.Recommended_Product__c =s.recoProduct;
                hcoToInsert.add(hco);
            }
        }
        insert hcoToInsert;
        system.debug('hco size '+ hcoToInsert.size());
        
        return shc.id;
    }
    
    @Auraenabled
    public static void sendToCustomer(String shcId, String medium, String url, String objName){
        Map<String,String> input = new Map<String, String>();
        input.put('recordId',shcId);
        input.put('medium',medium);
        Flow.Interview.Site_Health_Card_SMS flow1 = new Flow.Interview.Site_Health_Card_SMS(input);
        flow1.start();
    }
    
    @auraenabled(cacheable=true)  
    public static savePDFWrapper getDocURL(String shcId){
        savePDFWrapper spw = new savePDFWrapper();
        
        List<ContentDocumentLink> cd = [SELECT ID, ContentDocumentId FROM  ContentDocumentLink WHERE LinkedEntityId =: shcId ];
        system.debug(cd);
        Set<ID> cdId = new Set<Id>();
        for(ContentDocumentLink c : cd){
            cdId.add(c.ContentDocumentId);
        }
        ContentDistribution c = [select id, ContentDownloadUrl, DistributionPublicUrl, PdfDownloadUrl from ContentDistribution where ContentDocumentId IN :cdId][0];//Assuming there will be only on distribution
        system.debug(c);
        spw.downloadURL = c.PdfDownloadUrl;
        spw.publicURL = c.DistributionPublicUrl;
        system.debug(spw);
        return spw;
    }
    
    public class savePDFWrapper{
        @Auraenabled public string contentDocumentID {get;set;}
        @Auraenabled public string downloadURL {get;set;}
        @Auraenabled public string publicURL {get;set;}
    }
    
    
    @Auraenabled
    public static  savePDFWrapper savePDF(String shcId,String objName){
        system.debug(shcId);
        savePDFWrapper spw = new savePDFWrapper();
        PageReference PDf;
        pdf =  Page.SHC_vf;
        pDF.getParameters().put('id',shcId);
        PDf.setRedirect(true);
        Blob b;
        if(Test.isRunningTest()) b = blob.valueOf('Unit.Test');
		else  b=PDf.getContent();
       ContentVersion contentVersion_1 = new ContentVersion(
            Title='Site Health Card', 
            PathOnClient ='Site_Health_Card.pdf',
            VersionData = b, 
            origin = 'H'
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId 
                                           FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        system.debug(contentversion_2);
        ContentDocumentLink contentlink = new ContentDocumentLink();
        // contentlink.LinkedEntityId = '00672000000I5xJAAS';
        contentlink.LinkedEntityId = shcId;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
        ContentDistribution cd = new ContentDistribution();
        cd.ContentVersionId = contentVersion_2.Id;
        cd.Name = 'Site Health Card- ' + Date.today().format();
        cd.PreferencesNotifyOnVisit = false;
        insert cd;
        system.debug(cd.id);
        ContentDistribution c = [select id, ContentDownloadUrl, DistributionPublicUrl, PdfDownloadUrl from ContentDistribution where id =: cd.Id][0];
        spw.contentDocumentId = contentVersion_2.ContentDocumentId;
        spw.downloadURL = c.PdfDownloadUrl;
        spw.publicURL = c.DistributionPublicUrl;
        if(objName.equalsIgnoreCase('site_health_card__c')){
            site_health_card__c s = new site_health_card__c(Id = shcId, public_URL__c =c.DistributionPublicUrl );
            update s;
        }
        
        return spw;
    }
}