public without sharing class WorkCreationController {
    static string imgPrefix = 'data:image/png;base64,';
    
    @AuraEnabled
    public static string isMoneyApprovalRequired(String siteId, Decimal moneyCollected){
        system.debug('siteId '+siteId +' Money '+moneyCollected);
        String result = '';
        String msg = 'Money Collection Approval Will Go to ';
        Decimal totalMoneyCollected =0;
         Milestone1_project__c s = [Select Total_Money_Collected_Work__c,Team_Lead_2_TL2__r.Name,
                                    SSO__r.Name, Unit_Head_UH__r.Name, Division_Head__r.Name
                                    From Milestone1_project__c WHERE ID =: siteId];
                if(s.Total_Money_Collected_Work__c != null){
                    totalMoneyCollected = s.Total_Money_Collected_Work__c + moneyCollected;
                }else{
                    totalMoneyCollected = moneyCollected;
                }
        if(totalMoneyCollected > 150000 && totalMoneyCollected <=250000){
            result = msg + ' TL '+ s.Team_Lead_2_TL2__r.Name;
        }
        else if(totalMoneyCollected > 250000 && totalMoneyCollected <=400000){
            result = msg + ' SSO '+ s.SSO__r.Name;
        }
        else if(totalMoneyCollected > 400000 && totalMoneyCollected <=700000){
            result = msg + ' UH '+ s.Unit_Head_UH__r.Name;
        }
        else if(totalMoneyCollected > 700000){
            result = msg + ' UH '+ s.Unit_Head_UH__r.Name +' AND DH '+ s.Division_Head__r.Name;
        }
        if(msg !='') msg +='\n';
        return result;
    }
    
    @AuraEnabled
    public static string validateConsumption(List<productItemWrapper> pw, String dealerId){
        if(!Work_Creation_Setting__c.getOrgDefaults().Enable_Consumption_Check__c){
            return '';
        }
        
        /// get allocation where start & end falls betwn today, 
        //get previous consumption where createdDate > setting from date && betwn alocation date
        String volumeMsg = '';
        String valueMsg ='';
        system.debug('dealerId '+ dealerId);
        system.debug('pw '+ pw);
        //Id dealerId;
        Set<Id> productId = new Set<Id>();
        Map<Id,Decimal> volumeMap = new Map<Id,Decimal>(); // productid, volume
        Map<Id,Decimal> valueMap = new Map<Id,Decimal>();
        Map<Id,Decimal> volumeAllocationMap = new Map<Id,Decimal>(); // vol allocated to dealer
        Map<Id,Decimal> valueAllocationMap = new Map<Id,Decimal>();
        Map<Id,Decimal> volumeConsumedMap = new Map<Id,Decimal>(); // vol consumed previously
        Map<Id,Decimal> valueConsumedMap = new Map<Id,Decimal>();
        for(productItemWrapper p : pw){
            Id pid = p.consumption.Product__c;
            productId.add(pid);
            Decimal volume = p.consumption.Quantity__c;
            Decimal value = p.consumption.Amount__c;
            if(volume == null) volume = 0;
            if(value == null) value = 0;
            if(volumeMap.containsKey(pid)){
                Decimal temp = volumeMap.get(pid);
                if(temp != null) volume += temp;
            }
            if(volume > 0) volumeMap.put(pid,volume);
            if(valueMap.containsKey(pid)){
                Decimal temp = valueMap.get(pid);
                if(temp != null) value += temp;
            }
            if(value > 0) valueMap.put(pid,value);
        }
        system.debug('valueMap '+ valueMap);
        system.debug('ProductId '+ productId);
        Map<Id,product2> productMap = new Map<Id,Product2>([Select Name from Product2 WHERE ID IN: productId]);
        
        for(Dealer_Product_Allocation__c a : [Select Volume__c, Value__c, Product__c From Dealer_Product_Allocation__c WHERE Dealer__c =: dealerId AND Product__c IN: productId ]){
            if(a.Volume__c !=null) volumeAllocationMap.put(a.Product__c,a.Volume__c);
            if(a.Value__c != null) valueAllocationMap.put(a.Product__c,a.Value__c);
        }
        system.debug('volumeAllocationMap '+volumeAllocationMap);
        for(AggregateResult a : [SELECT SUM(Quantity__c)total, Product__c 
                                 FROM Consumption__c 
                                 WHERE Work__r.Quote__r.Dealer__c = : dealerId 
                                 AND Work__r.Approval_Status__c IN ('Approved', 'Not Required') 
                                 AND Product__c IN: productId 
                                 AND CreatedDate >=: Work_Creation_Setting__c.getOrgDefaults().Start_Date__c 
                                 Group By Product__c]){
                                     if(a.get('total') !=null) volumeConsumedMap.put((Id)a.get('Product__c'), (Decimal)a.get('total'));
                                 }
        for(AggregateResult a : [Select SUM(Amount__c)total, Product__c from Consumption__c 
                                 WHERE Work__r.Quote__r.Dealer__c = : dealerId 
                                 AND Work__r.Approval_Status__c IN ('Approved', 'Not Required')
                                 AND Product__c IN: productId 
                                 AND CreatedDate >=: Work_Creation_Setting__c.getOrgDefaults().Start_Date__c 
                                 Group By Product__c]){
                                     if(a.get('total') !=null) valueConsumedMap.put((Id)a.get('Product__c'), (Decimal)a.get('total'));
                                 }
        
        for(Id p : productId){
            if(volumeMap.get(p) !=null){
                Decimal consumed = volumeMap.get(p) + checkDecimal(volumeConsumedMap.get(p));
                Decimal allocated = checkDecimal(volumeAllocationMap.get(p));
                if(allocated < consumed) volumeMsg += productMap.get(p).Name +'- Allocated : '+allocated +' Consumed: '+ consumed +'\n';
            }
        }
        if(volumemsg != '') volumeMsg = '\n Allocated Volume Exceeded \n' + volumeMsg;
        for(Id p : productId){
            if(valueMap.get(p) !=null){
                Decimal consumed = valueMap.get(p) + checkDecimal(valueConsumedMap.get(p));
                Decimal allocated = checkDecimal(valueAllocationMap.get(p));
                if(allocated < consumed) valueMsg += productMap.get(p).Name +'- Allocated : ₹'+allocated +' Consumed: ₹'+ consumed +'\n';
            }
        }
        if(valueMsg != '') valueMsg = '\n Allocated Value Exceeded \n' + valueMsg;
        return volumeMsg + valueMsg;
    }
    public static decimal checkDecimal(Decimal d){
        if(d == null) return 0;
        return d;
    } 
    @AuraEnabled
    public static String getShadeImage(String shadeCode){
        String result;
        String endPoint = API_Integration__c.getValues('Shade Code API').URL__c; 
        HTTPRequest request =new HTTPRequest();
        request.setEndpoint(endpoint+'/content/dam/asian_paints/colours/swatches/'+shadeCode +'.png'); 
        request.setMethod('GET');  
        request.setHeader('Content-Length', '0');
        request.setTimeout(120000);
        Http http = new Http();
        HttpResponse response = Http.send(request);
        system.debug(response.getStatusCode());
        if(response.getStatusCode() == 200)
            result = imgPrefix +EncodingUtil.base64Encode(response.getBodyAsBlob());
        else if(response.getStatusCode() == 404)
            throw new AuraException('Shade Not Found');
        else 
            throw new AuraException('Unexpected error occured');
        return result;
    } 
    @AuraEnabled(cacheable=true)
    public static Quote getQuoteDetails(string qId){
        try {
            List<Quote> quoteList = new List<Quote>();
            DescribeSObjectResult describeResultQuote = Quote.getSObjectType().getDescribe();  
            List<String> fieldNamesQuote = new List<String>( describeResultQuote.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesQuote, ',' ) + ',Site__r.Team_Lead_1_TL1__c,site__r.Deadline__c,' +
                'Site__r.Team_Lead_2_TL2__c,Site__r.SSO__c,Site__r.Unit_Head_UH__c, Site__r.Service_Territory__c, '+
                'Site__r.Total_Money_Collected_Work__c, Site__r.Division_Head__c ' +
                ' FROM ' + describeResultQuote.getName() + ' where Id =' + '\'' + qId + '\'';
            
            quoteList = Database.query(query1);
            system.debug('quoteList::'+quoteList);
            if(!quoteList.isEmpty()){
                return quoteList[0];
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<QuoteLevelProductWrapper> getQuoteLevelProduct(string qId){
        List<QuoteLevelProductWrapper> resultList = new List<QuoteLevelProductWrapper>();
        Map<Id,QuoteLineItem> qlMap = new map<Id,QuoteLineItem>();
        List<QuoteLineItem> quoteItems = [select id,Product2Id,QuoteId,UnitPrice,Quantity,product2.Name,product2.ProductCode,product2.Family
                                          from QuoteLineItem
                                          where QuoteId =: qId];
        if(quoteItems != null && !quoteItems.isEmpty()){
            for(QuoteLineItem q : quoteItems){
                qlMap.put(q.Id,q);
            }
        }
        for(Id key : qlMap.keyset()){
            QuoteLineItem ql = qlMap.get(key);
            QuoteLevelProductWrapper qw = new QuoteLevelProductWrapper();
            qw.productName = ql.product2.Name;
            qw.productCode = ql.product2.ProductCode;
            qw.productFamily = ql.product2.Family;
            resultList.add(qw);
        }
        return resultList;                                     
    }
    
    @AuraEnabled(cacheable=true)
    public static Milestone1_Milestone__c getWorkDetails(string wId){
        try {
            List<Milestone1_Milestone__c> workList = new List<Milestone1_Milestone__c>();
            DescribeSObjectResult describeResultWork = Milestone1_Milestone__c.getSObjectType().getDescribe();  
            List<String> fieldNamesWork = new List<String>( describeResultWork.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesWork, ',' ) + 
                ' FROM ' + describeResultWork.getName() + ' where Id =' + '\'' + wId + '\'';
            
            workList = Database.query(query1);
            system.debug('workList::'+workList);
            if(!workList.isEmpty()){
                return workList[0];
            }
            return null;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Dealer_Contractor_Mapping__c> getContractorList(string dealerId){
        try {
            List<Dealer_Contractor_Mapping__c> contractorList = new List<Dealer_Contractor_Mapping__c>();
            DescribeSObjectResult describeResultContractor = Dealer_Contractor_Mapping__c.getSObjectType().getDescribe();  
            List<String> fieldNamesContractor = new List<String>( describeResultContractor.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesContractor, ',' ) + ',Contractor__r.Name,Contractor__r.Rating__c,Contractor__r.Contractor_BP_No__c ' +
                ' FROM ' + describeResultContractor.getName() + ' where Dealer__c =' + '\'' + dealerId + '\'' +
                ' Order by Rating__c ASC';
            
            contractorList = Database.query(query1);
            system.debug('contractorList::'+contractorList);
            
            return contractorList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<productItemWrapper> getExistingConsumption(string wId){
        List<productItemWrapper> existingItems = new List<productItemWrapper>();
        List<Consumption__c> consumptionList = [select id,name,Work__c,Quantity__c,Project__c,Product__c,
                                                Product_Family__c from Consumption__c where Work__c =: wId];
        Integer seq = 0;                                        
        if(consumptionList != null && !consumptionList.isEmpty()){
            for(Consumption__c c : consumptionList){
                productItemWrapper p = new productItemWrapper();
                p.consumption = c;
                p.sequence = seq;
                seq = seq+1;
                existingItems.add(p);
            }
        }
        return existingItems;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<productItemWrapper> addProductItem(string existingList, string selectedConsumption){
        List<productItemWrapper> existingItems = new List<productItemWrapper>();
        if(string.isNotBlank(existingList)){
            existingItems = (List<productItemWrapper>)JSON.deserialize(existingList, List<productItemWrapper>.class);
        }
        productItemWrapper pw = new productItemWrapper();
        pw.consumption.Name = selectedConsumption;
        pw.service = 'undefined';
        if(!existingItems.isEmpty()){
            pw.sequence = existingItems.size();
        }else{
            pw.sequence = 0;
        }
        existingItems.add(pw);
        return existingItems;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductItems(string productFamily){
        List<Product2> productList = [select id,name,ProductCode from Product2 where Family =: productFamily and Family != null];
        return productList;
    }
    
    @AuraEnabled
    public static Id saveWork(string fieldList, string productItems, string quote, string selectedContractor,List<shadeImage> shadeImages ){
        system.debug('prod items '+ productItems);
        try{
            Map<String,String> parseMap = new Map<String,String>();
            if(string.isNotBlank(fieldList)){
                List<QuoteParser> qparse = QuoteParser.parse(fieldList);
                for(QuoteParser qp : qparse){
                    system.debug('label::'+qp.label + ' ::: value::: '+qp.value);
                    parseMap.put(qp.label,qp.value); 
                }
            }
            system.debug('parseMap : ' + parseMap);
            List<productItemWrapper> productList = new List<productItemWrapper>();
            if(string.isNotBlank(productItems)){
                productList = (List<productItemWrapper>)JSON.deserialize(productItems, List<productItemWrapper>.class);
                system.debug('prod list'+ productList);
            }
            
            Quote quoteRecord = new Quote();
            if(string.isNotBlank(quote)){
                quoteRecord = (Quote)JSON.deserialize(quote, Quote.class);
            }
            
            Milestone1_Milestone__c work = new Milestone1_Milestone__c();
            Id projectId = QuoteRecord.Site__c;//getProjectId(quoteRecord.OpportunityId);
            system.debug('projectId:'+projectId);
            work.Name = 'New Work - ' + quoteRecord.Name;
            work.Project__c = projectId;
            work.Quote__c = quoteRecord.Id;
            work.Contractor__c = selectedContractor;
            work.Opportunity__c = quoteRecord.OpportunityId;
            work.Team_Lead_1_TL1__c = quoteRecord.Site__r.Team_Lead_1_TL1__c;
            work.Team_Lead_2_TL2__c = quoteRecord.Site__r.Team_Lead_2_TL2__c;
            work.SSO__c = quoteRecord.Site__r.SSO__c;
            work.Unit_Head_UH__c = quoteRecord.Site__r.Unit_Head_UH__c;
            work.Division_Head__c = quoteRecord.Site__r.Division_Head__c;
            work.Created_By__c = UserInfo.getName();
            if(parseMap.get('moneyCollected') != null){
                work.Money_Collected__c = Decimal.valueOf(parseMap.get('moneyCollected'));
                Milestone1_project__c s = [Select Total_Money_Collected_Work__c From Milestone1_project__c WHERE ID =: quoteRecord.Site__c];
                if(s.Total_Money_Collected_Work__c != null){
                    work.Total_Money_Collected__c = s.Total_Money_Collected_Work__c + work.Money_Collected__c;
                }else{
                    work.Total_Money_Collected__c = work.Money_Collected__c;
                }
                work.Approval_Status__c = 'Not Required'; 
            }else{
                work.Approval_Status__c = 'Not Required'; 
            }
            if(parseMap.get('kickOff') != null){
                work.Kickoff__c = Date.valueOf(parseMap.get('kickOff'));
            }
            if(parseMap.get('deadLine') != null){
                work.Deadline__c = Date.valueOf(parseMap.get('deadLine'));
            }
            if(parseMap.get('description') != null){
                work.Description__c = parseMap.get('description');
            }
            if(parseMap.get('shadeCode') != null){
                work.Shade_Code__c = parseMap.get('shadeCode');
            }
            if(parseMap.get('volumeApproval') != null){
                work.Volume_Approval_Required__c = Boolean.valueOf(parseMap.get('volumeApproval'));
                system.debug('volumeApproval : ' + work.Volume_Approval_Required__c);
            }
            String shadeCodeString ='';
            for(shadeImage s : shadeImages){
                shadeCodeString += s.shadeCode +', ';
            }
            work.Shade_Code__c = shadeCodeString;
            insert work;
            List<ContentVersion> imageCVList = new List<ContentVersion>();
            List<ContentDocumentLink> imageCDLList = new List<ContentDocumentLink>();
            Set<Id> imageCVSet = new Set<Id>();
            system.debug('shadeImages ' + shadeImages);
            for(shadeImage s : shadeImages){
                ContentVersion cv = new ContentVersion(
                    Title= s.shadeCode, 
                    PathOnClient = s.shadeCode +'.png',
                    VersionData = EncodingUtil.base64Decode(s.imageVal.removeStart(imgPrefix)), 
                    origin = 'H',
                    shade_image__c = true
                );
                imageCVList.add(cv);
            }
            insert imageCVList;
            for(ContentVersion cv : imageCVList){
                imageCVSet.add(cv.Id);
            }
            if(imageCVSet !=null && !imageCVSet.isEmpty()){
                for(ContentVersion cv : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id IN :imageCVSet ]){
                    ContentDocumentLink contentlink = new ContentDocumentLink();
                    contentlink.LinkedEntityId = work.Id;
                    contentlink.contentdocumentid = cv.ContentDocumentId;
                    contentlink.ShareType = 'V';
                    imageCDLList.add(contentLink);
                }
                insert imageCDLList;
            }
            
            List<Consumption__c> listToInsert = new List<Consumption__c>();
            for(productItemWrapper pw : productList){
                pw.consumption.Work__c = work.Id;
                pw.consumption.Project__c = projectId;
                pw.consumption.Service__c = pw.service;
                listToInsert.add(pw.consumption);
            }
            
            if(!listToInsert.isEmpty()){
                system.debug(listToInsert);
                insert listToInsert;
            }
            system.debug('selectedContractor:'+selectedContractor);
            return work.Id;
        }
        
        catch(DMLException e){
            throw new aurahandledexception(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static Id updateWork(string fieldList, string productItems, string workId){
        Map<String,String> parseMap = new Map<String,String>();
        if(string.isNotBlank(fieldList)){
            List<QuoteParser> qparse = QuoteParser.parse(fieldList);
            for(QuoteParser qp : qparse){
                system.debug('label::'+qp.label + ' ::: value::: '+qp.value);
                parseMap.put(qp.label,qp.value); 
            }
        }
        
        List<productItemWrapper> productList = new List<productItemWrapper>();
        if(string.isNotBlank(productItems)){
            productList = (List<productItemWrapper>)JSON.deserialize(productItems, List<productItemWrapper>.class);
        }
        
        Milestone1_Milestone__c workRecord = new Milestone1_Milestone__c();
        if(string.isNotBlank(workId)){
            workRecord = (Milestone1_Milestone__c)JSON.deserialize(workId, Milestone1_Milestone__c.class);
        }
        
        Milestone1_Milestone__c work = new Milestone1_Milestone__c();
        //Id projectId = getProjectId(quoteRecord.OpportunityId);
        //work.Name = 'New Work - ' + quoteRecord.Name;
        //work.Project__c = projectId;
        //work.Quote__c = quoteRecord.Id;
        //work.Opportunity__c = quoteRecord.OpportunityId;
        if(parseMap.get('moneyCollected') != null){
            work.Money_Collected__c = Decimal.valueOf(parseMap.get('moneyCollected'));
        }
        if(parseMap.get('kickOff') != null){
            work.Kickoff__c = Date.valueOf(parseMap.get('kickOff'));
        }
        if(parseMap.get('deadLine') != null){
            work.Deadline__c = Date.valueOf(parseMap.get('deadLine'));
        }
        if(parseMap.get('description') != null){
            work.Description__c = parseMap.get('description');
        }
        if(parseMap.get('shadeCode') != null){
            work.Shade_Code__c = parseMap.get('shadeCode');
        }
        work.Id = workRecord.Id;
        update work;
        
        List<Consumption__c> listToUpsert = new List<Consumption__c>();
        for(productItemWrapper pw : productList){
            if(pw.consumption.Work__c == null)
                pw.consumption.Work__c = workRecord.Id;
            pw.consumption.Project__c = workRecord.Project__c;
            listToUpsert.add(pw.consumption);
        }
        
        if(!listToUpsert.isEmpty()){
            upsert listToUpsert;
        }
        return work.Id;
    }
    
    Public static Id getProjectId(Id optyId){
        List<Milestone1_Project__c> pList = [select id,name,Opportunity__c from Milestone1_Project__c where Opportunity__c =: optyId];
        if(pList != null && !pList.isEmpty()){
            return pList[0].Id;
        }
        return null;
    }
    
    public class productItemWrapper{
        @AuraEnabled public string name {get;set;}
        @AuraEnabled public decimal quantity {get;set;}
        @AuraEnabled public string product {get;set;}
        @AuraEnabled public string productFamily {get;set;}
        @AuraEnabled public Integer sequence {get;set;}
        @AuraEnabled public Consumption__c consumption {get;set;}
        @Auraenabled public string service {get;set;}
        
        public productItemWrapper(){
            consumption = new Consumption__c();
        } 
    }
    
    public class QuoteLevelProductWrapper{
        @AuraEnabled
        public string productName;
        @AuraEnabled
        public string productCode;
        @AuraEnabled
        public string productFamily;
        
        public QuoteLevelProductWrapper(){
            
        }
    }
    
    public class shadeImage{
        @AuraEnabled public string shadeCode {get;set;}
        @AuraEnabled public string imageVal {get;set;}
    }
}