public without sharing class Shade_Controller {
    // public Milestone1_Project__c shc {get; set;}
    // public List<String> smartCare {get;set;}
    // public List<areaWrapper> interior {get;set;}
    // public List<areaWrapper> exterior {get;set;}
    // public string dateOfVisit {get;set;}
    // public List<String> images {get;set;}
    // public string pincode {get;set;}
    
    
    //------------------------------------------------------//  
    public Account acc {get;set;}
    public Account dealer {get;set;}
    public Milestone1_Project__c site {get;set;}
    public string custAdd {get;set;}
    public string dealerAdd {get;set;}
    
    public List<imgWrapper> imageList {get;set;}
    public List<imgWrapper> imageList1 {get;set;}
    public class imgWrapper{
        public string url {get;set;}
        public string name{get;set;}
    }
    
    // public string Website_SHC {get;set;}
    // public string SafePainting_Service_SHC {get;set;}
    //public string Product_Details_SHC {get;set;}
    // public string Waterproofing_Solutions_SHC {get;set;}
    //public string Product_Warranty_SHC{get;set;}
    
    public User associate {get;set;}
    public User techassociate {get;set;}
    public User techlead {get;set;}
    
    public Date Today { get {return Date.today();} }
    //-------------------------------------------------------//   
    
    /*   
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


}*/
    public Shade_Controller(){
        /*
Map<String,areaWrapper> areaMapInt = new Map<String,areaWrapper>();
Map<String,areaWrapper> areaMapExt = new Map<String,areaWrapper>();

interior = new List<areaWrapper>();
exterior = new List<areaWrapper>();
images = new List<String>();

// String shcID = ApexPages.currentPage().getParameters().get('id');

ID shcId ='a0E72000000eXy9EAE';

smartCare = new List<String>();
for(integer i=0; i<3; i++){ 
smartCare.add('');
}


shc = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Deadline__c, Description__c, Duration__c, GoogleGanntUrl__c, ImportID__c, Kickoff__c, Next_Project_Milestone_Due_Date__c, Next_Project_Top_Milestone_Due_Date__c, Number_of_Incomplete_Milestones__c, Number_of_Incomplete_Top_Milestones__c, Status_BudgetExpenseSummary__c, Status_BudgetMiletoneEstimate__c, Status_Image_HoursSummary__c, Status_Image_OpenVComplete__c, Status_Img_OpenLateBlocked__c, Status_TasksOpenBlockedLate__c, Status_TasksOpenComplete__c, Status__c, Total_Blocked_Task_Count__c, Total_Complete_Task_Count__c, Total_Expense_Budget__c, Total_Expense_Budget_from_Milestones__c, Total_Expense_Estimate__c, Total_Expense_Incurred__c, Total_Hours_Budget__c, Total_Hours_Budget_from_Milestones__c, Total_Hours_Estimate__c, Total_Hours_Incurred__c, Total_Late_Task_Count__c, Total_Open_Task_Count__c, Opportunity__c, PincodeLookup__c, Tier__c, New_Site__c, Site_Completed_On__c, Dealer__c, Contractor__c, Address__c, OTP_Verified__c, Account__c, Site_Completion_Card_Public_URL__c, Site_Completion_Card_Download_URL__c, Reason__c, Create_URL__c, Service__c, Site_Certificate_URL__c, Service_Territory_Name__c, Survey_Status__c, Survey_Link__c, Team_Lead_1_TL1__c, Team_Lead_2_TL2__c, Service_Territory__c, New_Service__c, Warranty_Card_URL__c, System_Determined_Tier__c, Legacy_Site_Number__c, SSO__c, TA_Audit_Complete__c, Warranty_Card_Download_URL__c, Site_Certificate_Download_URL__c, Customer_Contact_No__c, Unit_Head_UH__c, Total_Money_Collected_Work__c, Work_Count__c, Customer_Name__c, OTP__c, Associate_Contact_No__c, Warranty_No__c, NPS_Category__c, Division__c, Region__c, LeadID__c, Survey_Response_Rating__c, Owner_of_site__c, Issue_Description__c, DB2K_Hydroloc_Used__c, Shade_selection_test__c FROM Milestone1_Project__c WHERE ID =: shcId];

/*dateOfVisit = String.valueof(shc.createddate.day()).leftPad(2,'0') +'-'+String.valueof(shc.createddate.month()).leftPad(2,'0')+'-'+shc.createddate.year();
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
for(integer i=size; i<4; i++) exterior.add(ad);*/
        
        
        //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
        String siteID = ApexPages.currentPage().getParameters().get('Id');
       // ID siteId ='a0E72000000eXy9EAE';
      //  try{
            // site = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Deadline__c, Description__c, Duration__c, GoogleGanntUrl__c, ImportID__c, Kickoff__c, Next_Project_Milestone_Due_Date__c, Next_Project_Top_Milestone_Due_Date__c, Number_of_Incomplete_Milestones__c, Number_of_Incomplete_Top_Milestones__c, Status_BudgetExpenseSummary__c, Status_BudgetMiletoneEstimate__c, Status_Image_HoursSummary__c, Status_Image_OpenVComplete__c, Status_Img_OpenLateBlocked__c, Status_TasksOpenBlockedLate__c, Status_TasksOpenComplete__c, Status__c, Total_Blocked_Task_Count__c, Total_Complete_Task_Count__c, Total_Expense_Budget__c, Total_Expense_Budget_from_Milestones__c, Total_Expense_Estimate__c, Total_Expense_Incurred__c, Total_Hours_Budget__c, Total_Hours_Budget_from_Milestones__c, Total_Hours_Estimate__c, Total_Hours_Incurred__c, Total_Late_Task_Count__c, Total_Open_Task_Count__c, Opportunity__c, PincodeLookup__c, Tier__c, New_Site__c, Site_Completed_On__c, Dealer__c, Contractor__c, Address__c, OTP_Verified__c, Account__c, Site_Completion_Card_Public_URL__c, Site_Completion_Card_Download_URL__c, Reason__c, Create_URL__c, Service__c, Site_Certificate_URL__c, Service_Territory_Name__c, Survey_Status__c, Survey_Link__c, Team_Lead_1_TL1__c, Team_Lead_2_TL2__c, Service_Territory__c, New_Service__c, Warranty_Card_URL__c, System_Determined_Tier__c, Legacy_Site_Number__c, SSO__c, TA_Audit_Complete__c, Warranty_Card_Download_URL__c, Site_Certificate_Download_URL__c, Customer_Contact_No__c, Unit_Head_UH__c, Total_Money_Collected_Work__c, Work_Count__c, Customer_Name__c, OTP__c, Associate_Contact_No__c, Warranty_No__c, NPS_Category__c, Division__c, Region__c, LeadID__c, Survey_Response_Rating__c, Owner_of_site__c, Issue_Description__c, DB2K_Hydroloc_Used__c, Shade_selection_test__c FROM Milestone1_Project__c WHERE ID =: shcId];
            site=new Milestone1_Project__c();
            site=[SELECT id ,Account__c,Dealer__c,OwnerId,Team_Lead_1_TL1__c,Team_Lead_2_TL2__c  FROM Milestone1_Project__c where Id=:siteID];
            system.debug('Account :::: '+site.Account__c);
            system.debug('Dealer :::: '+site.Dealer__c);
            system.debug('Associate :::: '+site.OwnerId);
            system.debug('Tech associate :::: '+site.Team_Lead_1_TL1__c);
            system.debug('Tech Lead :::: '+site.Team_Lead_2_TL2__c);
            
            acc=new Account();
            if(site.Account__c!=null){
                
                acc=[SELECT id ,Name,PersonMobilePhone,PersonMailingStreet,PersonMailingCity,PersonMailingPostalCode,PersonMailingState,PersonMailingCountry FROM Account where Id=:site.Account__c ];
                system.debug('Account details :::: '+acc);
                custAdd=(acc.PersonMailingStreet!=null ?acc.PersonMailingStreet:'')+' '+(acc.PersonMailingCity!=null ?acc.PersonMailingCity:'')+' '+(acc.PersonMailingPostalCode!=null ?acc.PersonMailingPostalCode:'')+' '+(acc.PersonMailingState!=null ?acc.PersonMailingState:'')+' '+(acc.PersonMailingCountry!=null ?acc.PersonMailingCountry:'');
                system.debug('Customer Address :::: '+custadd);
            }
            dealer=new Account();
            if(site.Dealer__c!=null){
                dealer=[SELECT id,Name,Phone,BillingStreet,BillingCity,BillingPostalCode,BillingState,BillingCountry FROM Account where id=:site.Dealer__c];  
                system.debug('dealer details :::: '+dealer);
                dealerAdd=(dealer.BillingStreet!=null ?dealer.BillingStreet:'') +' '+(dealer.BillingCity!=null ?dealer.BillingCity:'')+' '+(dealer.BillingPostalCode!=null ?dealer.BillingPostalCode:'')+' '+(dealer.BillingState!=null ?dealer.BillingState:'')+' '+(dealer.BillingCountry!=null ?dealer.BillingCountry:'');
                system.debug('Dealer Address :::: '+dealerAdd); 
            }
            
            Set<Id> cdId = new Set<Id>();
            Set<Id> wid=new Set<Id>();
            imageList = new List<imgWrapper>();
            imagelist1= new List<imgwrapper>();
            
            for(Milestone1_Milestone__c work :[SELECT Id From Milestone1_Milestone__c WHERE Project__c=:site.id ]){
                wid.add(work.id);
            }
            if(!wid.isempty()){
                for(ContentDocumentLink lstCL : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: wid AND ContentDocument.filetype !='PDF']){
                    cdId.add(lstCL.ContentDocumentId);
                }
            }
            
            List<contentversion> cv = [SELECT versiondata,Title,COntentDocumentId  FROM ContentVersion WHERE COntentDocumentId IN:cdId AND Shade_Image__c = True]; 
            system.debug('cv size'+cv.size());
            if(cv.size()>0){
                for(integer i=0; i<cv.size() ; i++){
                    imgWrapper iw = new imgWrapper();
                    iw.name = cv[i].title;
                    if([select isportalenabled from user where id= :userinfo.getUserId()][0].isPortalEnabled)
                        iw.url ='/sfc/servlet.shepherd/document/download/'+cv[i].COntentDocumentId;
                    else {
                        iw.url = '/services/data/v53.0/sobjects/ContentVersion/'+cv[i].Id+'/VersionData';
                    }
                    
                    imageList.add(iw);   
                    system.debug(imageList.size());
                }  
            }
            
            /*  for(Url__c u: [select name, url__c from url__c]){
switch on u.name {
when 'SafePainting_Service_SHC'{ SafePainting_Service_SHC =	u.url__c;}
when 'Product_Details_SHC' {Product_Details_SHC =	u.url__c;}
when 'Waterproofing_Solutions_SHC' {Waterproofing_Solutions_SHC =	u.url__c; }
when 'Product_Warranty_SHC'{ Product_Warranty_SHC =	u.url__c;}
when 'Website_SHC' {Website_SHC =	u.url__c;}
}
}
system.debug(SafePainting_Service_SHC); 
system.debug('SafePainting_Service_SHC :::: '+Product_Details_SHC); 
system.debug('Waterproofing_Solutions_SHC :::: '+Waterproofing_Solutions_SHC); 
system.debug('Product_Warranty_SHC :::: '+Product_Warranty_SHC); 
system.debug('Website_SHC :::: '+Website_SHC); */
            
            
            associate=new User();
            if(site.OwnerId!=null){
                associate=[SELECT id,Name,mobilePhone from User where id=:site.OwnerId];
                system.debug('Associate details :::: '+associate);
            } 
            
            techassociate =new User();
            if(site.Team_Lead_1_TL1__c!=null){
                techassociate=[SELECT id,Name,mobilePhone from User where id=:site.Team_Lead_1_TL1__c];
                system.debug('Tech Associate details :::: '+techassociate);     
            } 
            techlead=new User();
            if(site.Team_Lead_2_TL2__c!=null){
                techlead=[SELECT id,Name,mobilePhone from User where id=:site.Team_Lead_2_TL2__c];
                system.debug('tech Lead details :::: '+techlead); 
            }
       // }
       /// catch(exception e){
        //    system.debug('error :::: '+e.getMessage()+''+e.getCause()+''+e.getLineNumber());
      //  }
        
        //-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
    }
    
    
}