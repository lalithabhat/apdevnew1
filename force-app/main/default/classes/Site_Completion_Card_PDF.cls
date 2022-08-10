public class Site_Completion_Card_PDF {

    public string wId{get;set;}
	public List<Milestone1_Milestone__c > workRecord{get;set;}  
    
    public string Today_Date{get;set;}
    public string customerName{get;set;}
    public string customerMobile{get;set;}
    public string contractorName{get;set;}
    public string contractorMobile{get;set;}
    public string dealerName{get;set;}
    public string dealerAddress{get;set;}
    public string dealerMobile{get;set;}
    public string quoteApprovalDate{get;set;}
    public string siteStartDate{get;set;}
    public string siteCompletionDate{get;set;}
    Public Map<string,ImageWrapper> imageMap {get;set;}
    public List<Milestone1_Project__c > siteRecord{get;set;}
    public string site_tier{get;set;}
    public string site_serviceVariant{get;set;}
    public List<Quote> quoteList {get;set;}
    public List<QuoteWrapper> quoteWrapper {get;set;}
      public string siteName{get;set;}
     public string visitedBy{get;set;}
    public string visitedMobile{get;set;}
    
    public Site_Completion_Card_PDF(){
        wId = ApexPages.currentPage().getParameters().get('id');
        //wId = 'a0E72000000WNXlEAO';
        workRecord = new List<Milestone1_Milestone__c>();
        siteRecord = new List<Milestone1_Project__c >();
        Today_Date = system.today().format();
        site_tier = '';
        site_serviceVariant = '';
        quoteList = new List<Quote>();
        quoteWrapper = new List<QuoteWrapper>();
        
        DescribeSObjectResult describeResultSite = Milestone1_Project__c.getSObjectType().getDescribe();  
        List<String> fieldNamesSite = new List<String>( describeResultSite.fields.getMap().keySet() );
        String querySite = ' SELECT ' + String.join( fieldNamesSite, ',' ) + ',Account__r.Name,' +
            'Contractor__r.Name, Dealer__r.Name,Account__r.PersonMobilePhone,Owner.Name, ' +
            'Contractor__r.Phone, Dealer__r.Phone,Dealer__r.BillingStreet,Dealer__r.BillingCity,' +
            'Dealer__r.BillingState,Dealer__r.BillingCountry,Dealer__r.BillingPostalCode' + 
            ' FROM ' + describeResultSite.getName() + ' where Id =' + '\'' + wId + '\'';
        
        siteRecord = Database.query(querySite);
        
        
        DescribeSObjectResult describeResultWork = Milestone1_Milestone__c.getSObjectType().getDescribe();  
        List<String> fieldNamesWork = new List<String>( describeResultWork.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNamesWork, ',' ) + 
            ' FROM ' + describeResultWork.getName() + ' where Project__c =' + '\'' + wId + '\'';
        
        workRecord = Database.query(query);
        
        DescribeSObjectResult describeResultQuote = Quote.getSObjectType().getDescribe();  
        List<String> fieldNamesQuote = new List<String>( describeResultQuote.fields.getMap().keySet() );
        String queryQuote = ' SELECT ' + String.join( fieldNamesQuote, ',' ) + ',Site__r.Kickoff__c,Site__r.Deadline__c '+
            ' FROM ' + describeResultQuote.getName() + ' where Site__c =' + '\'' + wId + '\' and ' +
            'Status = \'Accepted\'';
        
        quoteList = Database.query(queryQuote);
        
        if(quoteList != null && !quoteList.isEmpty()){
            for(quote q : quoteList){
                QuoteWrapper qw = new QuoteWrapper();
                qw.quoteNo = q.QuoteNumber;
                if(q.Total_Amount_after_discount__c != null){
                    qw.approvedValue = string.valueOf(q.Total_Amount_after_discount__c);
                }
                if(q.Approval_Date__c != null)
                	qw.approvedDate = q.Approval_Date__c.format();
                if(q.Site__r.Kickoff__c != null)
                	qw.projectStartDate = q.Site__r.Kickoff__c.format();
                if(q.Site__r.Deadline__c != null)
                	qw.projectEndDate = q.Site__r.Deadline__c.format();
                qw.myShade = '';
                quoteWrapper.add(qw);
            }
        }
        siteName = siteRecord[0].Name;
        visitedBy = siteRecord[0].owner.Name;
        List<User> u = [Select Contact.MobilePhone from user where id =: siteRecord[0].OwnerId];
        if(!u.isEmpty() && u[0].COntact.MobilePhone !=null) visitedMobile = u[0].Contact.MobilePhone;
        else visitedMobile = '';
        customerName = siteRecord[0].Account__r.Name;
        customerMobile = siteRecord[0].Account__r.PersonMobilePhone;
        contractorName = siteRecord[0].Contractor__r.Name;
        contractorMobile = siteRecord[0].Contractor__r.Phone;
        dealerName = siteRecord[0].Dealer__r.Name;
        dealerMobile = siteRecord[0].Dealer__r.Phone;
        dealerAddress ='';
        //quoteApprovalDate = workRecord[0].Quote__r.lastmodifiedDate.Date().format();
        if(siteRecord[0].Kickoff__c != null){
            siteStartDate = siteRecord[0].Kickoff__c.format();
        }
        if(siteRecord[0].Deadline__c != null){
            siteCompletionDate = siteRecord[0].Deadline__c.format();
        }
        if(siteRecord[0].Dealer__r.BillingStreet != null){
            dealerAddress = siteRecord[0].Dealer__r.BillingStreet + ',';
        }
        if(siteRecord[0].Dealer__r.BillingCity != null){
            dealerAddress = dealerAddress + siteRecord[0].Dealer__r.BillingCity + ', ';
        }
        if(siteRecord[0].Dealer__r.BillingState != null){
            dealerAddress = dealerAddress + siteRecord[0].Dealer__r.BillingState + ', ';
        }
        if(siteRecord[0].Dealer__r.BillingCountry != null){
            dealerAddress = dealerAddress + siteRecord[0].Dealer__r.BillingCountry + ', ';
        }
        if(siteRecord[0].Dealer__r.BillingPostalCode != null){
            dealerAddress = dealerAddress + siteRecord[0].Dealer__r.BillingPostalCode;
        }
        if(siteRecord[0].Tier__c != null){
            site_tier = siteRecord[0].Tier__c;
        }
        if(siteRecord[0].New_Service__c != null){
            site_serviceVariant = siteRecord[0].New_Service__c;
        }
        
        imageMap = new Map<string,ImageWrapper>();
        Map<String,ImageWrapper> resultMap = new Map<String,ImageWrapper>();
        for(Milestone1_Milestone__c mm : workRecord){
            resultMap = getImageMap(mm.Id);
            if(resultMap != null && !resultMap.isEmpty()){
                imageMap.putAll(resultMap);
            }
        }
        system.debug('imageMap::'+imageMap);
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
                        if(resultMap.containskey(str[1])){
                            if(str[0] == 'Before Picture'){
                                ImageWrapper wp = resultMap.get(str[1]);
                                wp.beforeImageLink = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                                resultMap.put(str[1],wp);
                            }else if(str[0] == 'After Picture'){
                                ImageWrapper wp = resultMap.get(str[1]);
                                wp.afterImageLink = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                                resultMap.put(str[1],wp);
                            }
                        }else{
                            if(str[0] == 'Before Picture'){
                                ImageWrapper wp = new ImageWrapper();
                                wp.beforeImageLink = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                                resultMap.put(str[1],wp);
                            }else if(str[0] == 'After Picture'){
                                ImageWrapper wp = new ImageWrapper();
                                wp.afterImageLink = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                                resultMap.put(str[1],wp);
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
    }
    
    Public class QuoteWrapper{
        public string quoteNo {get;set;}
        public string approvedValue {get;set;}
        public string approvedDate {get;set;}
        public string projectStartDate {get;set;}
        public string projectEndDate {get;set;}
        public string myShade {get;set;}
        
    }
}