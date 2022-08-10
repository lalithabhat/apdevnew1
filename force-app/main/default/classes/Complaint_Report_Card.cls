public class Complaint_Report_Card {
	
    Public List<Case> caseRecord {get;set;}
    Public Case caseR {get;set;}
    Public string cId {get;set;}
    public string Today_Date{get;set;}
    public string customerName{get;set;}
    public string customerMobile{get;set;}
    public string contractorName{get;set;}
    public string contractorMobile{get;set;}
    public string dealerName{get;set;}
    public string dealerAddress{get;set;}
    public string dealerMobile{get;set;}
    Public Map<string,ImageWrapper> imageMap {get;set;}
    
    public Complaint_Report_Card() {
        caseRecord = new List<Case>();
        cId = ApexPages.currentPage().getParameters().get('id');
        Today_Date = system.today().format();
        caseR = new Case();
        
        DescribeSObjectResult describeResultCase = Case.getSObjectType().getDescribe();  
        List<String> fieldNamesCase = new List<String>( describeResultCase.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNamesCase, ',' ) + ',Contact.Name,' +
            'Contractor__r.Name, Dealer__r.Name,Contact.MobilePhone, ' +
            'Contractor__r.Phone, Dealer__r.Phone,Dealer__r.BillingStreet,Dealer__r.BillingCity,' +
            'Dealer__r.BillingState,Dealer__r.BillingCountry,Dealer__r.BillingPostalCode' + 
            ' FROM ' + describeResultCase.getName() + ' where Id =' + '\'' + cId + '\'';
        
        caseRecord = Database.query(query);
        caseR = caseRecord[0];
        customerName = caseRecord[0].Contact.Name;
        customerMobile = caseRecord[0].Contact.MobilePhone;
        contractorName = caseRecord[0].Contractor__r.Name;
        contractorMobile = caseRecord[0].Contractor__r.Phone;
        dealerName = caseRecord[0].Dealer__r.Phone;
        dealerMobile = caseRecord[0].Dealer__r.Phone;
        if(caseRecord[0].Dealer__r.BillingStreet != null){
            dealerAddress = caseRecord[0].Dealer__r.BillingStreet + ',<br/>';
        }
        if(caseRecord[0].Dealer__r.BillingCity != null){
            dealerAddress = dealerAddress + caseRecord[0].Dealer__r.BillingCity + ', ';
        }
        if(caseRecord[0].Dealer__r.BillingState != null){
            dealerAddress = dealerAddress + caseRecord[0].Dealer__r.BillingState + ',<br/> ';
        }
        if(caseRecord[0].Dealer__r.BillingCountry != null){
            dealerAddress = dealerAddress + caseRecord[0].Dealer__r.BillingCountry + ', ';
        }
        if(caseRecord[0].Dealer__r.BillingPostalCode != null){
            dealerAddress = dealerAddress + caseRecord[0].Dealer__r.BillingPostalCode;
        }
        
        imageMap = new Map<string,ImageWrapper>();
        imageMap = getImageMap(cId);
    }
    
    public static Map<string,ImageWrapper> getImageMap(Id workId){
        Map<String,ImageWrapper> resultMap = new Map<String,ImageWrapper>();
        List<ContentDocumentLink> contentDocumentItems = [select id,contentdocumentId from ContentDocumentLink where LinkedEntityId=:workId];
        set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocumentLink cd: contentDocumentItems){
            contentDocumentIds.add(cd.contentdocumentId);
        }
        List<ContentVersion> contentVersionIds = [select id,description from ContentVersion where ContentDocumentId IN: contentDocumentIds];
        system.debug('contentVersionIds::'+contentVersionIds);
        if(contentVersionIds != null && !contentVersionIds.isEmpty()){
            
            for(ContentVersion cv : contentVersionIds){
                if(cv.description != null && cv.description.Contains(':')){
                    List<string> str = cv.description.split(':');
                    if(str != null && !str.isEmpty()){
                        if(resultMap.containskey(str[0])){
                            if(str[0] == 'Before Picture'){
                                ImageWrapper wp = resultMap.get(str[0]);
                                wp.beforeImageLink = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                                wp.description = str[1];
                                resultMap.put(str[0],wp);
                            }else if(str[0] == 'After Picture'){
                                ImageWrapper wp = resultMap.get(str[0]);
                                wp.afterImageLink = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                                wp.description = str[1];
                                resultMap.put(str[0],wp);
                            }
                        }else{
                            if(str[0] == 'Before Picture'){
                                ImageWrapper wp = new ImageWrapper();
                                wp.beforeImageLink = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                                wp.description = str[1];
                                resultMap.put(str[0],wp);
                            }else if(str[0] == 'After Picture'){
                                ImageWrapper wp = new ImageWrapper();
                                wp.afterImageLink = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                                wp.description = str[1];
                                resultMap.put(str[0],wp);
                            }
                        }
                    }
                }
            }
            system.debug('resultMap::'+resultMap);
        }
        return resultMap;
    }
    
    Public class ImageWrapper{
        public string beforeImageLink {get;set;}
        public string afterImageLink {get;set;}
        public string description {get;set;}
    }
}