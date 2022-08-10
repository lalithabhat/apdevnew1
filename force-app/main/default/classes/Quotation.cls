public class Quotation {
    @AuraEnabled
	    public static Decimal getProductCost(string IdofProduct, string tierName) {
            system.debug(IdofProduct +' '+ tierName);
            Decimal cost =0;
            if(tierName ==null) return 0;
            List<product2> valueOfCost = [select id,name,Platinum_Cost__c,Gold_Cost__c,Classic_Cost__c from product2 where Id =: IdofProduct Limit 1];
            if(valueOfCost.isEmpty()) return 0;
            if(tierName.containsIgnoreCase('Platinum')){
                cost=valueOfCost[0].Platinum_Cost__c;  
            }
            else if(tierName.containsIgnoreCase('Gold')){
                cost=valueOfCost[0].Gold_Cost__c;
            }
            else if(tierName.containsIgnoreCase('Classic')){
                cost=valueOfCost[0].Classic_Cost__c;
            }   
            
            
            system.debug(cost);
            if(cost == null) cost =0;
            return cost;  
            
        }
    @Auraenabled
    public static string getServiceName(String productId,String dealerId){
        system.debug('productId' + productId + ' '+ dealerId);
    List<Product2> pList= [Select Service__c from product2 where id = : productId];
        if(dealerId !=null && !pList.isEmpty() && pList[0].Service__c !=null){
            List<SA_Pincode_Mapping__c> pinMapping = [Select Id, Service__c from SA_Pincode_Mapping__c WHERE SA__r.AccountId = : dealerId AND Skills__c = : pList[0].Service__c];
               if(!pinMapping.isEmpty())
            	return pList[0].Service__c;
            
         }
        return 'undefined';
    }
    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunity(string oId){
        try {
            List<Opportunity> opportunityList = new List<Opportunity>();
            DescribeSObjectResult describeResultOpportunity = Opportunity.getSObjectType().getDescribe();  
            List<String> fieldNamesOpportunity = new List<String>( describeResultOpportunity.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesOpportunity, ',' ) + 
                ' FROM ' + describeResultOpportunity.getName() + ' where Id =' + '\'' + oId + '\'';
            
            opportunityList = Database.query(query1);
            system.debug('opportunityList::'+opportunityList);
            return opportunityList[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Site_Health_Card__c getSiteHealthCardRecord(string shcId){
        try {
            List<Site_Health_Card__c> SHCList = new List<Site_Health_Card__c>();
            DescribeSObjectResult describeResultSHC = Site_Health_Card__c.getSObjectType().getDescribe();  
            List<String> fieldNamesSHC = new List<String>( describeResultSHC.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesSHC, ',' ) + ',Opportunity__r.Dealer__c,Opportunity__r.ownerId ' +
                ' FROM ' + describeResultSHC.getName() + ' where Id =' + '\'' + shcId + '\'';
            
                SHCList = Database.query(query1);
            system.debug('SHCList::'+SHCList);
            return SHCList[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<DealerWrapper> getDealerList(string optyOwner){
        try {
            List<DealerWrapper> dealerList = new List<DealerWrapper>();
            List<User> userList = [select id,contactId from User where Id =: optyOwner];
            if(userList != null && !userList.isEmpty()){
                if(userList[0].contactId != null){
                    List<Agent_Mapping__c> agentList = new List<Agent_Mapping__c>();
                    DescribeSObjectResult describeResultAgent = Agent_Mapping__c.getSObjectType().getDescribe();  
                    List<String> fieldNamesAgent = new List<String>( describeResultAgent.fields.getMap().keySet() );
                    String query1 = ' SELECT ' + String.join( fieldNamesAgent, ',' ) + ',CA__r.Account.Name,CA__r.Account.Dealer_Code__c,' +
                        'CA__r.AccountId ' +
                        ' FROM ' + describeResultAgent.getName() + ' where SA__c =' + '\'' + userList[0].contactId + '\'';
                    
                    agentList = Database.query(query1);
                    system.debug('agentList::'+agentList);
                    if(!agentList.isEmpty()){
                        Map<Id,DealerWrapper> dealerMap = new Map<Id,DealerWrapper>();
                        for(Agent_Mapping__c a : agentList){
                            DealerWrapper dw = new DealerWrapper();
                            if(a.CA__r.Account.Dealer_Code__c != null)
                                dw.dealerName = a.CA__r.Account.Name + ' | ' + a.CA__r.Account.Dealer_Code__c;
                            else
                                dw.dealerName = a.CA__r.Account.Name + ' | ';
                            dw.dealerId = a.CA__r.AccountId;
                            dw.noDealer = false;
                            dw.message = '';
                            dealerMap.put(a.CA__r.AccountId,dw);
                        }
                        for(Id key : dealerMap.keyset()){
                            DealerWrapper d = new DealerWrapper();
                            d.dealerName = dealerMap.get(key).dealerName;
                            d.dealerId = dealerMap.get(key).dealerId;
                            d.noDealer = dealerMap.get(key).noDealer;
                            d.message = dealerMap.get(key).message;
                            dealerList.add(d);
                        }
                    }else{
                        DealerWrapper d = new DealerWrapper();
                        d.noDealer = true;
                        d.message = 'No Agent mapping available for the Opportunity Owner(SA)';
                        dealerList.add(d);
                    }
                }else{
                    DealerWrapper d = new DealerWrapper();
                    d.noDealer = true;
                    d.message = 'No Contact found for the login User';
                    dealerList.add(d);
                }
            }else{
                DealerWrapper d = new DealerWrapper();
                d.noDealer = true;
                d.message = 'No User Found';
                dealerList.add(d);
            }
            
            return dealerList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static quote getQuoteRecord(string qId){ 
        try {
            List<Quote> qList = new List<Quote>();
            DescribeSObjectResult describeResultQ = Quote.getSObjectType().getDescribe();  
            List<String> fieldNamesQ = new List<String>( describeResultQ.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesQ, ',' ) + 
                ' FROM ' + describeResultQ.getName() + ' where Id =' + '\'' + qId + '\'';
            
                qList = Database.query(query1);
            system.debug('qList::'+qList);
            if(!qList.isEmpty()){
                return qList[0];
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<RecommendationWrapper> getRecommendationList(string shcId){
        try {
            List<Health_Card_Observation__c> SHCList = new List<Health_Card_Observation__c>();
            List<RecommendationWrapper> recommendationList = new List<RecommendationWrapper>();
            DescribeSObjectResult describeResultSHC = Health_Card_Observation__c.getSObjectType().getDescribe();  
            List<String> fieldNamesSHC = new List<String>( describeResultSHC.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesSHC, ',' ) + 
                ' FROM ' + describeResultSHC.getName() + ' where Site_Health_Card__c =' + '\'' + shcId + '\'';
            
            SHCList = Database.query(query1);
            if(!SHCList.isEmpty()){
                for(Health_Card_Observation__c sc : SHCList){
                    RecommendationWrapper rw = new RecommendationWrapper();
                    rw.Symptom = sc.Symptom__c;
                    rw.Recommendation = sc.Recommendations__c;
                    recommendationList.add(rw);
                }
            }
            return recommendationList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    @AuraEnabled(cacheable=true)
    public static List<string> getRoomValues(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = QuoteLineItem.Room__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        system.debug('Room Values::'+pickListValuesList);
        return pickListValuesList;
    }

    @AuraEnabled(cacheable=true)
    public static List<string> getSurfaceValues(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = QuoteLineItem.Surface__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        system.debug('surface Values::'+pickListValuesList);
        return pickListValuesList;
    } 
    
    @AuraEnabled(cacheable=true)
    public static map<string,List<quoteLineItemWrapper>> getQuoteLineItems(string qId){ 
        try {
            List<QuoteLineItem> QuoteLineItems = new List<QuoteLineItem>();
            map<string,List<quoteLineItemWrapper>> quoteLineMap = new Map<string,list<quoteLineItemWrapper>>();
            DescribeSObjectResult describeResultQ = QuoteLineItem.getSObjectType().getDescribe();  
            List<String> fieldNamesQ = new List<String>( describeResultQ.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesQ, ',' ) + ',Product2.Name ' +
                ' FROM ' + describeResultQ.getName() + ' where QuoteId =' + '\'' + qId + '\' and ' +
                ' Other_Charge__c = false';
            
               QuoteLineItems  = Database.query(query1);
            system.debug('QuoteLineItems ::'+QuoteLineItems);
            if(!QuoteLineItems.isEmpty()){
                for(QuoteLineItem q : QuoteLineItems){
                    quoteLineItemWrapper qw = new quoteLineItemWrapper();
                    if(quoteLineMap.containskey(q.Room__c)){
                        List<quoteLineItemWrapper> dummyList = quoteLineMap.get(q.Room__c);
                        qw.sequence = dummyList.size();
                        qw.quoteItem = q;
                        qw.productName = q.Product2.Name;
                        qw.isExist= true;
                        dummyList.add(qw);
                        quoteLineMap.put(q.Room__c,dummyList);
                    }else{
                        List<quoteLineItemWrapper> dummyList = new List<quoteLineItemWrapper>();
                        qw.sequence = 0;
                        qw.quoteItem = q;
                        qw.productName = q.Product2.Name;
                        qw.isExist = true;
                        dummyList.add(qw);
                        quoteLineMap.put(q.Room__c,dummyList);
                    }
                }
            }
            return quoteLineMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<ProductDiscountWrapper> getExistingProductLevelDiscount(string qId){ 
        try {
            List<QuoteLineItem> QuoteLineItems = new List<QuoteLineItem>();
            map<string,List<ProductDiscountWrapper>> productMap = new Map<string,list<ProductDiscountWrapper>>();
            List<ProductDiscountWrapper> resultList = new List<ProductDiscountWrapper>();
            DescribeSObjectResult describeResultQ = QuoteLineItem.getSObjectType().getDescribe();  
            List<String> fieldNamesQ = new List<String>( describeResultQ.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesQ, ',' ) + ',Product2.Name ' +
                ' FROM ' + describeResultQ.getName() + ' where QuoteId =' + '\'' + qId + '\' and ' +
                ' Other_Charge__c = false';
            
            QuoteLineItems  = Database.query(query1);
            system.debug('QuoteLineItems ::'+QuoteLineItems);
            if(!QuoteLineItems.isEmpty()){
                Integer seq = 0;
                for(QuoteLineItem q : QuoteLineItems){
                    if(!productMap.containsKey(q.Product2Id)){
                        List<ProductDiscountWrapper> discountList = new List<ProductDiscountWrapper>();
                        if(q.Discount != null && q.Discount > 0){
                        	ProductDiscountWrapper pw = new ProductDiscountWrapper();
                            pw.discountPrice = q.Discount;
                            pw.discountType = 'Percentage';
                            pw.selectedProduct = q.Product2Id;
                            pw.productName = q.Product2.Name;
                            pw.sequence = seq;
                            seq++;
                            discountList.add(pw);
                    	}
                        if(q.Discount_Lumpsum__c != null && q.Discount_Lumpsum__c > 0){
                            ProductDiscountWrapper pw = new ProductDiscountWrapper();
                            pw.discountPrice = q.Discount_Lumpsum__c;
                            pw.discountType = 'Amount';
                            pw.selectedProduct = q.Product2Id;
                            pw.productName = q.Product2.Name;
                            pw.sequence = seq;
                            seq++;
                            discountList.add(pw);
                        }
                        productMap.put(q.Product2Id,discountList);
                    }
                }
            }
            for(string st : productMap.keyset()){
                resultList.addAll(productMap.get(st));
            }
            
            return resultList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<QuoteLevelDiscountWrapper> getExistingQuoteLevelDiscount(string qId){ 
        try {
            List<QuoteLevelDiscountWrapper> discountList = new List<QuoteLevelDiscountWrapper>();
            if(string.isNotBlank(qId)){
                Quote qRecord = new Quote();
                qRecord = (Quote)JSON.deserialize(qId, Quote.class);
                Integer seq = 0;
                for(Integer i=1;i<=3;i++){
                    if((string)qRecord.get('Discount_Name_'+i+'__c') != null && (Decimal)qRecord.get('Discount_Value_'+i+'__c') != null){
                        QuoteLevelDiscountWrapper qw = new QuoteLevelDiscountWrapper();
                        qw.discountPrice = (Decimal)qRecord.get('Discount_Value_'+i+'__c');
                        qw.discountType = (string)qRecord.get('Discount_Type_'+i+'__c');
                        qw.discountName = (string)qRecord.get('Discount_Name_'+i+'__c');
                        qw.sequence = seq;
                        seq++;
                        discountList.add(qw);
                    }
                }
            }
            return discountList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static map<string,List<quoteLineItemWrapper>> addLineItem(string room, string surface,string qId,string existingList){
        system.debug('existingList::'+existingList);
        List<QuoteLineItemParse> qparse = new List<QuoteLineItemParse>();
        if(string.isNotBlank(existingList)){
            qparse = QuoteLineItemParse.parse(existingList);
            system.debug('qparse::'+qparse);
        }
        map<string,List<quoteLineItemWrapper>> lineItemMap = new map<string,List<quoteLineItemWrapper>>();
        for(QuoteLineItemParse st : qparse){
            if(st.value != null && !st.value.isEmpty()){
                if(st.label == room){
                    quoteLineItemWrapper qw = new quoteLineItemWrapper();
                    qw.sequence = st.value.size();
                    qw.isExist = false;
                    QuoteLineItem q = new QuoteLineItem();
                    q.Room__c = room;
                    q.Surface__c = surface;
                    q.quoteId = qId;
                    qw.quoteItem = q;
                    st.value.add(qw);
                    lineItemMap.put(st.label,st.value);
                }else{
                    lineItemMap.put(st.label,st.value);
                }
                
            }else{
                if(st.label == room){
                    quoteLineItemWrapper qw = new quoteLineItemWrapper();
                    qw.sequence = 0;
                    qw.isExist = false;
                    QuoteLineItem q = new QuoteLineItem();
                    q.Room__c = room;
                    q.Surface__c = surface;
                    q.quoteId = qId;
                    qw.quoteItem = q;
                    List<quoteLineItemWrapper> qwList = new List<quoteLineItemWrapper>();
                    qwList.add(qw);
                    lineItemMap.put(st.label,qwList);
                }
            }
        }
        
        return lineItemMap;
    }
   /* @AuraEnabled(cacheable=true)
    public static List<QuoteLineItem> addRoom(string existingRoomList, string selectedRoom){
            List<QuoteLineItem> lineitemList = new List<QuoteLineItem>();
            if(string.isNotBlank(existingRoomList)){
                lineitemList = (List<QuoteLineItem>)JSON.deserialize(existingRoomList, List<QuoteLineItem>.class);
            }
            lineitemList.add(new QuoteLineItem(Room__c = selectedRoom));
            return lineitemList;
    } */

    @AuraEnabled(cacheable=true)
    public static List<quoteLineItemWrapper> addRoom(string existingRoomList, string selectedRoom){
            List<quoteLineItemWrapper> lineitemList = new List<quoteLineItemWrapper>();
            if(string.isNotBlank(existingRoomList)){
                lineitemList = (List<quoteLineItemWrapper>)JSON.deserialize(existingRoomList, List<quoteLineItemWrapper>.class);
            }
            Integer seq;
            if(!lineitemList.isEmpty()){
                seq = lineitemList.size();
            }else{
                seq = 0;
            }
            quoteLineItemWrapper qw = new quoteLineItemWrapper();
            qw.room = selectedRoom;
            qw.sequence = seq;
            lineitemList.add(qw);
            return lineitemList;
    }

   /* @AuraEnabled(cacheable=true)
    public static List<QuoteLineItem> addSurface(string room, string selectedSurface, string existingquoteLineList){
            List<QuoteLineItem> lineitemList = new List<QuoteLineItem>();
            if(string.isNotBlank(existingquoteLineList)){
                lineitemList = (List<QuoteLineItem>)JSON.deserialize(existingquoteLineList, List<QuoteLineItem>.class);
            }
            lineitemList.add(new QuoteLineItem(Room__c = room, Surface__c = selectedSurface));
            return lineitemList;
    }*/

    /*@AuraEnabled(cacheable=true)
    public static List<quoteLineItemWrapper> addSurface(string room, string selectedSurface, string existingquoteLineList){
            List<quoteLineItemWrapper> lineitemList = new List<quoteLineItemWrapper>();
            if(string.isNotBlank(existingquoteLineList)){
                lineitemList = (List<quoteLineItemWrapper>)JSON.deserialize(existingquoteLineList, List<quoteLineItemWrapper>.class);
            }
            system.debug('room::'+room);
            quoteLineItemWrapper qw = new quoteLineItemWrapper();
            qw.surface = selectedSurface;
            qw.room = room;
            if(!lineitemList.isEmpty() && lineitemList.size() > 0){
                qw.sequence = lineitemList.size();
            }else{
                qw.sequence = 0;
            }
            lineitemList.add(qw);
            system.debug('lineitemList:: '+lineitemList.size());
            return lineitemList;
    }*/

    @AuraEnabled(cacheable=true)
    public static quoteLineItemWrapper addSurface(string room, string selectedSurface, Integer size){
            system.debug('room::'+room);
            system.debug('size::'+size);
            if(size != null){

            }else{
                size = 0;
            }
            quoteLineItemWrapper qw = new quoteLineItemWrapper();
            qw.surface = selectedSurface;
            qw.room = room;
            qw.sequence = size;
        	qw.service = 'undefined';
        	qw.productCost = 0;
            return qw;
    }

    @AuraEnabled(cacheable=true)
    public static Product2 getProductDetails(string productId){
        List<Product2> productList = [select id,name from Product2 where Id=:productId];
        if(productList != null && !productList.isEmpty()){
            return productList[0];
        }
        return null;
    }

    public static Map<Id,Product2> getProductDetailsMap(set<string> productIds){
        Map<Id,Product2> productMap = new Map<Id,Product2>();
        List<Product2> productList = [select id,name from Product2 where Id IN:productIds];
        if(productList != null && !productList.isEmpty()){
            for(Product2 p : productList){
                productMap.put(p.Id,p);
            }
        }
        return productMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getProductOptions(string productIds){
        List<string> listOfIds = new List<string>();
        listOfIds = (List<string>)JSON.deserialize(productIds, List<string>.class);
        system.debug('listOfIds::'+listOfIds);
        set<string> IDs = new set<string>();
        for(string st : listOfIds){
            IDs.add(st);
        }
        system.debug('IDs:: '+Ids);
        Map<Id,Product2> productMap = getProductDetailsMap(IDs);
        List<Product2> pdList = new List<Product2>();
        for(Id key : productMap.keySet()){
            pdList.add(productMap.get(key));
        }
        return pdList;
    }

    @AuraEnabled(cacheable=true)
    public static List<ProductDiscountWrapper> getProductDiscountList(string pList){
        List<ProductDiscountWrapper> pdiscountList = new List<ProductDiscountWrapper>();
        if(string.isNotBlank(pList)){
            pdiscountList = (List<ProductDiscountWrapper>)JSON.deserialize(pList, List<ProductDiscountWrapper>.class);
        }
        ProductDiscountWrapper pd = new ProductDiscountWrapper();
        pd.discountType = 'Percentage';
        if(pdiscountList != null && !pdiscountList.isEmpty()){
            pd.sequence = pdiscountList.size();
        }else{
            pd.sequence = 0;
        }
        pdiscountList.add(pd);
        return pdiscountList;
    }

    @AuraEnabled(cacheable=true)
    public static List<QuoteLevelDiscountWrapper> getQuoteLevelDiscountList(string dList){
        List<QuoteLevelDiscountWrapper> qdiscountList = new List<QuoteLevelDiscountWrapper>();
        if(string.isNotBlank(dList)){
            qdiscountList = (List<QuoteLevelDiscountWrapper>)JSON.deserialize(dList, List<QuoteLevelDiscountWrapper>.class);
        }

        QuoteLevelDiscountWrapper qd = new QuoteLevelDiscountWrapper();
        qd.discountType = 'Amount';
        if(qdiscountList != null && !qdiscountList.isEmpty()){
            qd.sequence = qdiscountList.size();
        }else{
            qd.sequence = 0;
        }
        qdiscountList.add(qd);
        return qdiscountList;
    }

    @AuraEnabled(cacheable=true)
    public static quoteLineItemWrapper addOtherCharge(string qId){
        List<QuoteLineItem> QuoteLineItems = new List<QuoteLineItem>();
        quoteLineItemWrapper qw = new quoteLineItemWrapper();
        if(string.isNotBlank(qId)){
            DescribeSObjectResult describeResultQ = QuoteLineItem.getSObjectType().getDescribe();  
            List<String> fieldNamesQ = new List<String>( describeResultQ.fields.getMap().keySet() );
            String query1 = ' SELECT ' + String.join( fieldNamesQ, ',' ) + ',Product2.Name ' +
                ' FROM ' + describeResultQ.getName() + ' where QuoteId =' + '\'' + qId + '\' and ' +
                ' Other_Charge__c = true';
            
            QuoteLineItems = Database.query(query1);
            system.debug('QuoteLineItems ::'+QuoteLineItems);
        }
        if(!QuoteLineItems.isEmpty()){
            qw.sequence = 0;
            qw.quoteItem = QuoteLineItems[0];
            qw.productName = QuoteLineItems[0].Product2.Name;
            qw.isExist= true;
        }else{
            QuoteLineItem ql = new QuoteLineItem();
            ql.Surface__c = 'Other';
            ql.Room__c = 'Other';
            ql.Other_Charge__c = true;
            ql.QuoteId = qId;
            List<Product2> otherProduct = [select Id,name from Product2 where Other_Charge__c = true];
            qw.sequence = 0;
            if(otherProduct != null && !otherProduct.isEmpty()){
                ql.Product2Id = otherProduct[0].Id;
                qw.productId = otherProduct[0].Id;
                qw.productName = otherProduct[0].Name;
            }
            qw.quoteItem = ql;
        }
        return qw;
    }

    @AuraEnabled(cacheable=true)
    public static quoteLineItemWrapper deleteOtherCharge(string OCRecord){
        quoteLineItemWrapper qw = new quoteLineItemWrapper();
        if(string.isNotBlank(OCRecord)){
            qw = (quoteLineItemWrapper)JSON.deserialize(OCRecord, quoteLineItemWrapper.class);
            qw.area = null;
            qw.price = null;
            qw.productId = null;
            qw.remarks = null;
            qw.pricingModal = null;
        }
        return qw;
    }

    @AuraEnabled(cacheable=true)
    public static List<PaymentDetailWrapper> getPaymentDetailList(string existingList){
        system.debug('existingList::'+existingList);
        List<PaymentDetailWrapper> paymentList = new List<PaymentDetailWrapper>();
        if(string.isNotBlank(existingList)){
            paymentList = (List<PaymentDetailWrapper>)JSON.deserialize(existingList, List<PaymentDetailWrapper>.class);
        }
        PaymentDetailWrapper pd = new PaymentDetailWrapper();
        if(!paymentList.isEmpty()){
            pd.sequence = paymentList.size();
        }else{
            pd.sequence = 0;
        }
        paymentList.add(pd);
        return paymentList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PaymentDetailWrapper> getExistingPaymentDetailList(string qId){
        List<PaymentDetailWrapper> paymentList = new List<PaymentDetailWrapper>();
        List<Payment_Milestone__c > pList = [select id,name, Stage__c,Milestone_Percentage__c,
                                             Quote__c from Payment_Milestone__c where Quote__c =: qId];
        if(pList != null && !pList.isEmpty()){
            Integer seq = 0;
            for(Payment_Milestone__c p : pList){
                PaymentDetailWrapper pw = new PaymentDetailWrapper();
                pw.milestoneStage = p.Stage__c;
                pw.milestonePercentage = p.Milestone_Percentage__c;
                pw.sequence = seq;
                seq++;
                paymentList.add(pw);
            }
        }else{
            paymentList = getPaymentDetailList(null);
        }
        return paymentList;
    }

    Public static Pricebook2 getPriceBook(){
        List<Pricebook2> priceBookEntryList = new List<Pricebook2>();
        priceBookEntryList = [select id,name,IsStandard from Pricebook2 where IsStandard = true and IsActive = true];
              
        Pricebook2 pbook = new Pricebook2();
        if(priceBookEntryList != null && !priceBookEntryList.isEmpty()){
            pbook = priceBookEntryList[0];
        }
        return pbook;
    }

    Public static Map<string,PricebookEntry> getPriceBookEntry(Id pbook){
        List<PricebookEntry> priceBookEntryList = [select id,Pricebook2Id,Product2Id,UnitPrice,IsActive from PricebookEntry where Pricebook2Id =: pbook and IsActive = true];
        Map<string,PricebookEntry> pricebookEntryMap = new Map<string,PricebookEntry>();
        for(PricebookEntry p : priceBookEntryList){
            pricebookEntryMap.put(p.Product2Id,p);
        }
        return pricebookEntryMap;
    }

    @AuraEnabled(cacheable=true)
    public static List<Product2> getMaskingCharge(){
        List<Product2> pdlist = [select id,name,ProductCode,Masking_Charge__c,Mechanised_Charge__c
                             from Product2 where Masking_Charge__c = true OR Mechanised_Charge__c = true];
        return pdList;
    }

    @AuraEnabled
    public static string saveQuote(string quoteLineItemList, string productdiscountList, string quoteLeveldiscountList, 
                                  string otherchargeList, string paymentDetailsList, string fieldset, string shc,
                                  string maskingCharge, string mechanisedCharge){ 
        system.debug('inside quote save method');
        List<quoteLineItemWrapper> quoteLineItems = new List<quoteLineItemWrapper>();
        system.debug('quoteLineItemList::'+quoteLineItemList);
        if(string.isNotBlank(quoteLineItemList)){
            quoteLineItems = (List<quoteLineItemWrapper>)JSON.deserialize(quoteLineItemList, List<quoteLineItemWrapper>.class);
        }
        system.debug('quoteLineItems:'+quoteLineItems);
        List<ProductDiscountWrapper> productDiscountItems = new List<ProductDiscountWrapper>();
        if(string.isNotBlank(productdiscountList)){
            productDiscountItems = (List<ProductDiscountWrapper>)JSON.deserialize(productdiscountList, List<ProductDiscountWrapper>.class);
        }
        system.debug('productDiscountItems:'+productDiscountItems);
        List<QuoteLevelDiscountWrapper> quoteLevelDiscountItems = new List<QuoteLevelDiscountWrapper>();
        if(string.isNotBlank(quoteLeveldiscountList)){
            quoteLevelDiscountItems = (List<QuoteLevelDiscountWrapper>)JSON.deserialize(quoteLeveldiscountList, List<QuoteLevelDiscountWrapper>.class);
        }

        quoteLineItemWrapper otherChargeItem = new quoteLineItemWrapper();
        if(string.isNotBlank(otherchargeList)){
            otherChargeItem = (quoteLineItemWrapper)JSON.deserialize(otherchargeList, quoteLineItemWrapper.class);
        }
        system.debug('otherChargeItem::'+otherChargeItem);

        List<PaymentDetailWrapper> paymentDetailItems = new List<PaymentDetailWrapper>();
        if(string.isNotBlank(paymentDetailsList)){
            paymentDetailItems = (List<PaymentDetailWrapper>)JSON.deserialize(paymentDetailsList, List<PaymentDetailWrapper>.class);
        }
        system.debug('paymentDetailItems::'+paymentDetailItems);
        system.debug('fieldset::'+fieldset);                              
        
        List<QuoteParser> qparse = QuoteParser.parse(fieldset);
        Map<String,String> parseMap = new Map<String,String>();
        for(QuoteParser qp : qparse){
            system.debug('label::'+qp.label + ' ::: value::: '+qp.value);
            parseMap.put(qp.label,qp.value); 
        }
        
        Pricebook2 pBook = getPriceBook();
        Map<string,PricebookEntry> pBookMap = getPriceBookEntry(pBook.Id);
                          
        Site_Health_Card__c shcRecord = new Site_Health_Card__c();
        if(string.isNotBlank(shc)){
            shcRecord = (Site_Health_Card__c)JSON.deserialize(shc, Site_Health_Card__c.class);
        }

        Quote q = new quote();
        q.Name = parseMap.get('quoteName');
        q.opportunityId = shcRecord.Opportunity__c;
        q.Status = 'Draft';
        q.Site_Health_Card__c = shcRecord.Id;
        
        if(parseMap.get('area') != null){
            q.Total_Sq_ft_of_Home__c = Decimal.valueOf(parseMap.get('area'));
        }
        if(parseMap.get('bhk') != null){
            q.Total_BHK__c = parseMap.get('bhk');
        }
        if(parseMap.get('gender') != null){
            q.Gender__c = parseMap.get('gender');
        }
        if(parseMap.get('ageBand') != null){
            q.Age_Band__c = parseMap.get('ageBand');
        }
        if(parseMap.get('maritalStatus') != null){
            q.Marital_Status__c = parseMap.get('maritalStatus');
        }
        if(parseMap.get('profession') != null){
            q.Profession__c = parseMap.get('profession');
        }
        if(parseMap.get('kids') != null){
            q.Kids__c = Decimal.valueOf(parseMap.get('kids'));
        }
        if(parseMap.get('familyType') != null){
            q.Family_Type__c = parseMap.get('familyType');
        }
        if(parseMap.get('tier') != null){
            q.Tier__c = parseMap.get('tier');
        }
        if(parseMap.get('numberOfPainter') != null){
            q.Number_of_Painters__c = Decimal.valueOf(parseMap.get('numberOfPainter'));
        }
        if(parseMap.get('areaAppliedPerPainter') != null){
            q.Area_Applied_per_Painter_Day__c = Decimal.valueOf(parseMap.get('areaAppliedPerPainter'));
        }
        if(parseMap.get('siteType') != null){
            q.Site_Type__c = parseMap.get('siteType');
        }
        if(parseMap.get('bufferTime') != null){
            q.Buffer_Time__c = Decimal.valueOf(parseMap.get('bufferTime'));
        }
        if(parseMap.get('newServices') != null){
            q.New_Services__c = parseMap.get('newServices');
        }
        if(parseMap.get('selectedDealer') != null){
            q.Dealer__c = parseMap.get('selectedDealer');
        }
        if(parseMap.get('expirationDate') != null){
            system.debug('expirationDate::'+parseMap.get('expirationDate'));
            q.ExpirationDate = Date.valueOf(parseMap.get('expirationDate'));
        }
        Integer j=1;
        for(Integer i=0; i<quoteLevelDiscountItems.size();i++){
            q.put('Discount_Name_'+ j + '__c',quoteLevelDiscountItems[i].discountName);
            q.put('Discount_Type_'+ j + '__c',quoteLevelDiscountItems[i].discountType); 
            q.put('Discount_Value_'+ j + '__c',quoteLevelDiscountItems[i].discountPrice); 
            j++;
        }
        q.Pricebook2Id = pBook.Id;
        if(otherChargeItem != null && otherChargeItem.area != null && otherChargeItem.price != null){
            system.debug('inside othercharge');
            otherChargeItem.room = 'Other';
            otherChargeItem.surface = 'Other';
            otherChargeItem.price =  otherChargeItem.price.setscale(2,system.RoundingMode.DOWN) ;
            quoteLineItems.add(otherChargeItem);
        }

        if((q.Tier__c == 'Platinum' || q.Tier__c == 'Gold') && string.isNotBlank(maskingCharge)){
            quoteLineItemWrapper maskingChargeItem = new quoteLineItemWrapper();
            maskingChargeItem = (quoteLineItemWrapper)JSON.deserialize(maskingCharge, quoteLineItemWrapper.class);
            maskingChargeItem.room = 'Masking Charge';
            maskingChargeItem.surface = 'Masking Charge';
            quoteLineItems.add(maskingChargeItem);
        }

        if((q.Tier__c == 'Platinum' || q.Tier__c == 'Gold') && string.isNotBlank(mechanisedCharge)){
            quoteLineItemWrapper mechainsedChargeItem = new quoteLineItemWrapper();
            mechainsedChargeItem = (quoteLineItemWrapper)JSON.deserialize(mechanisedCharge, quoteLineItemWrapper.class);
            mechainsedChargeItem.room = 'Mechainsed Charge';
            mechainsedChargeItem.surface = 'Mechainsed Charge';
            quoteLineItems.add(mechainsedChargeItem);
        }

        system.debug('tier:: '+q.Tier__c);

        
        List<quoteLineItemWrapper> upperProudctsList = new List<quoteLineItemWrapper>();
        for(quoteLineItemWrapper qw : quoteLineItems){
            //quoteLineItemMap.put(qw.productId,qw);
            system.debug('upperProducts::'+qw.upperProducts);
            if(qw.upperProducts != null && !qw.upperProducts.isEmpty()){
                for(string st : qw.upperProducts){
                    quoteLineItemWrapper qwNew = new quoteLineItemWrapper();
                    qwNew.productId = st;
                    system.debug('qw.price '+ qw.price);
                    qwNew.price = (qw.price == null)? null : qw.price.setscale(2,system.RoundingMode.DOWN) ;
                     system.debug('qwNew.price '+ qwNew.price);
                    qwNew.area = qw.area;
                    qwNew.room = qw.room;
                    qwNew.surface = qw.surface;
                    qwNew.pricingModal = qw.pricingModal;
                    qwNew.remarks = qw.remarks;
                    qwNew.quantity = qw.quantity;
                    qwNew.service = qw.service;
                    upperProudctsList.add(qwNew);
                }
            }
        }
        if(!upperProudctsList.isEmpty()){
            quoteLineItems.addAll(upperProudctsList);
        }
        Map<string, quoteLineItemWrapper> quoteLineItemMap = new Map<string, quoteLineItemWrapper>();
        for(quoteLineItemWrapper qw : quoteLineItems){
            quoteLineItemMap.put(qw.productId,qw);
        }

        if(q.Tier__c != null){
            Map<string,Product2> mandatoryProduct = new Map<string,Product2>();
            
            for(Product2 p : [select id,name,Tier_Available__c from Product2 where Tier_Available__c includes(:q.Tier__c)]){
                mandatoryProduct.put(p.Id,p);
            }
            system.debug('mandatoryProduct::'+mandatoryProduct);
            
            if(!mandatoryProduct.isEmpty()){
                string returnError = 'Below Product mandatory for the Tier: '+ q.Tier__c + '\n';
                Integer sd = 1;
                for(string pkey : mandatoryProduct.keySet()){
                    system.debug('pKey:: '+pkey);
                    if(quoteLineItemMap.containskey(pkey)){
                        system.debug('yes:: ');
                    }else{
                        returnError += mandatoryProduct.get(pkey).Name + '\n';
                        sd = sd+1;
                    }
                }
                if(sd > 1)
                    return returnError; 
            }
        }

        if(q.New_Services__c != null){
            Map<string,Product2> mandatoryProduct = new Map<string,Product2>();
            
            for(Product2 p : [select id,name,Tier_Available__c from Product2 where Tier_Available__c includes(:q.New_Services__c)]){
                mandatoryProduct.put(p.Id,p);
            }
            system.debug('mandatoryProduct::'+mandatoryProduct);
            
            if(!mandatoryProduct.isEmpty()){
                string returnError = 'At least One Product mandatory for the New Services: '+ q.New_Services__c + '\n';
                Boolean isSelected =false;
                for(string pkey : mandatoryProduct.keySet()){
                    if(quoteLineItemMap.containskey(pkey)){
                        isSelected = true;
                        break;
                    }
                    returnError += mandatoryProduct.get(pkey).Name + '\n';
                }
                if(!isSelected) return returnerror;
             /*   string returnError = 'Below Product mandatory for the New Services: '+ q.New_Services__c + '\n';
                Integer sd = 1;
                
                for(string pkey : mandatoryProduct.keySet()){
                    system.debug('pKey:: '+pkey);
                    if(quoteLineItemMap.containskey(pkey)){
                        system.debug('yes:: ');
                    }else{
                        returnError += mandatoryProduct.get(pkey).Name + '\n';
                        sd = sd+1;
                    }
                }
                if(sd > 1)
                    return returnError;  */
            }
        }


        insert q;

        Map<string,List<ProductDiscountWrapper>> productDiscountMap = new Map<string,List<ProductDiscountWrapper>>();
        if(productDiscountItems != null && !productDiscountItems.isEmpty()){
            for(ProductDiscountWrapper pd : productDiscountItems){
                if(productDiscountMap.containskey(pd.selectedProduct)){
                    List<ProductDiscountWrapper> dummyList = new List<ProductDiscountWrapper>();
                    dummyList = productDiscountMap.get(pd.selectedProduct);
                    dummyList.add(pd);
                    productDiscountMap.put(pd.selectedProduct, dummyList);
                }else{
                    List<ProductDiscountWrapper> dummyList = new List<ProductDiscountWrapper>();
                    dummyList.add(pd);
                    productDiscountMap.put(pd.selectedProduct, dummyList);
                }
            }
        }
        /*if(otherChargeItem != null && otherChargeItem.area != null && otherChargeItem.price != null){
            system.debug('inside othercharge');
            quoteLineItems.add(otherChargeItem);
        } */

        List<QuoteLineItem> quoteLineItemForInsert = new List<QuoteLineItem>();
        
        for(quoteLineItemWrapper qw : quoteLineItems){
            QuoteLineItem quoteItem = new QuoteLineItem();
            quoteItem.Product2Id = qw.productId;
            quoteItem.QuoteId = q.Id;
            quoteItem.UnitPrice = (qw.price == NULL) ? null : qw.price.setscale(2,system.RoundingMode.DOWN) ;
            quoteItem.Quantity = qw.area;
            //system.debug('Room::'+qw.room);
            quoteItem.Room__c = qw.room;
            quoteItem.Surface__c = qw.surface;
            quoteItem.Pricing_Modal__c = qw.pricingModal;
            quoteItem.Description = qw.remarks;
            quoteItem.Quantity__c = qw.quantity;
            quoteItem.Service__c = qw.service;
            if(qw.room == 'Other'){
                quoteItem.Other_Charge__c = true;
            }

            if(productDiscountMap != null && !productDiscountMap.isEmpty()){
                if(productDiscountMap.containskey(qw.productId)){
                    for(ProductDiscountWrapper pd : productDiscountMap.get(qw.productId)){
                        if(pd.discountType == 'Percentage'){
                            quoteItem.Discount = pd.discountPrice;
                        }else if(pd.discountType == 'Amount'){
                            quoteItem.Discount_Lumpsum__c = pd.discountPrice;
                        }
                    }
                }
            }
            if(pBookMap.containskey(qw.productId)){
                quoteItem.PricebookEntryId = pBookMap.get(qw.productId).Id;
            }
            
            quoteLineItemForInsert.add(quoteItem);
        }

        if(!quoteLineItemForInsert.isEmpty()){
            insert quoteLineItemForInsert;
        }
        
        if(!paymentDetailItems.isEmpty()){
            List<Payment_Milestone__c> pmListForInsert = new List<Payment_Milestone__c>();
            for(PaymentDetailWrapper pw : paymentDetailItems){
                Payment_Milestone__c pm = new Payment_Milestone__c();
                pm.Stage__c = pw.milestoneStage;
                pm.Milestone_Percentage__c = pw.milestonePercentage;
                pm.Quote__c = q.Id;
                pmListForInsert.add(pm);
            }
            insert pmListForInsert;
        } 

        return q.Id;
       // throw new AuraHandledException('Invalid');
    }
    
    @AuraEnabled(cacheable=true)
    public static List<string> validateQuote(string q, string lineItems, string pdList, string qdList, string payments){
        List<string> resultList = new List<string>();
        system.debug('q::'+q);
        system.debug('lineItems::'+lineItems);
        
        Quote qRec = new Quote();
        if(string.isNotBlank(q)){
            qRec = (Quote)JSON.deserialize(q, Quote.class);
            if(string.isBlank(qRec.name)){
                resultList.add('#Quote Name missing.');
            }
            if(string.isBlank(qRec.Tier__c)){
                resultList.add('#Tier is missing.');
            }
            if(string.isBlank(qRec.New_Services__c)){
                resultList.add('#New services missing.');
            }
            if(qRec.ExpirationDate == null){
                resultList.add('#ExpirationDate missing.');
            }
            if(qRec.Number_of_Painters__c == null){
                resultList.add('#Number of painters missing.');
            }
        }else{
            resultList.add('#Quote Record not found.');
        }
        
        List<QuoteLineItemParse> qparse = new List<QuoteLineItemParse>();
        if(string.isNotBlank(lineItems)){
            qparse = QuoteLineItemParse.parse(lineItems);
            system.debug('qparse::'+qparse);
            if(qparse.isEmpty()){
                resultList.add('#Add at least one room and surface.');
            }else{
                Map<Id,quoteLineItemWrapper> selectedProduct = new Map<Id,quoteLineItemWrapper>();
                for(QuoteLineItemParse st : qparse){
                    for(quoteLineItemWrapper qw : st.value){
                        if(qw.quoteItem.Quantity == null){
                            resultList.add('#' + qw.quoteItem.Surface__c + ' surface missing the Area.');
                        }
                        if(qw.quoteItem.Product2Id == null){
                            resultList.add('#' + qw.quoteItem.Surface__c + ' surface missing the Product.');
                        }else{
                            selectedProduct.put(qw.quoteItem.Product2Id,qw);
                        }
                        
                        if(qw.quoteItem.Quantity__c == null){
                            resultList.add('#' + qw.quoteItem.Surface__c + ' surface missing the product volume.');
                        }
                        if(qw.quoteItem.UnitPrice == null){
                            resultList.add('#' + qw.quoteItem.Surface__c + ' surface missing the Price.');
                        }
                    }
                }
                if(qRec.Tier__c != null){
                    Map<string,Product2> mandatoryProduct = new Map<string,Product2>();
                    for(Product2 p : [select id,name,Tier_Available__c from Product2 where Tier_Available__c includes(:qRec.Tier__c)]){
                        mandatoryProduct.put(p.Id,p);
                    }
                    system.debug('mandatoryProduct::'+mandatoryProduct);
                    List<string> prodList = new List<string>();
                    if(!mandatoryProduct.isEmpty()){
                        for(string pkey : mandatoryProduct.keySet()){
                            if(selectedProduct.containskey(pkey)){
                                system.debug('yes:: ');
                            }else{
                                prodList.add('*'+mandatoryProduct.get(pkey).Name);
                            }
                        }
                    }
                    if(!prodList.isEmpty()){
                        resultList.add('#Below Product mandatory for the Tier: '+ qRec.Tier__c);
                        resultList.addAll(prodList);
                    }
                }
                
                if(qRec.New_Services__c != null){
                    Map<string,Product2> mandatoryProduct = new Map<string,Product2>();
                    for(Product2 p : [select id,name,Tier_Available__c from Product2 where Tier_Available__c includes(:qRec.New_Services__c)]){
                        mandatoryProduct.put(p.Id,p);
                    }
                    system.debug('mandatoryProduct for services::'+mandatoryProduct);
                    List<string> prodList = new List<string>();
                    if(!mandatoryProduct.isEmpty()){
                        for(string pkey : mandatoryProduct.keySet()){
                            if(selectedProduct.containskey(pkey)){
                                system.debug('yes:: ');
                            }else{
                                prodList.add('*'+mandatoryProduct.get(pkey).Name);
                            }
                        }
                    }
                    if(!prodList.isEmpty()){
                        resultList.add('#Below Product mandatory for the New Services: '+ qRec.New_Services__c);
                        resultList.addAll(prodList);
                    }
                }
            }
        }else{
            resultList.add('#Add at least one room and surface.');
        }
        
        List<ProductDiscountWrapper> productDiscounts = new List<ProductDiscountWrapper>();
        if(string.isNotBlank(pdList)){
            productDiscounts = (List<ProductDiscountWrapper>)JSON.deserialize(pdList, List<ProductDiscountWrapper>.class);
            for(ProductDiscountWrapper pd : productDiscounts){
                if(pd.selectedProduct == null){
                    resultList.add('#All Product discount items should have Product selected');
                }
            }
        }
        
        List<QuoteLevelDiscountWrapper> quoteDiscounts = new List<QuoteLevelDiscountWrapper>();
        if(string.isNotBlank(qdList)){
            quoteDiscounts = (List<QuoteLevelDiscountWrapper>)JSON.deserialize(qdList, List<QuoteLevelDiscountWrapper>.class);
        }
        
        List<PaymentDetailWrapper> paymentList = new List<PaymentDetailWrapper>();
        if(string.isNotBlank(payments)){
            paymentList = (List<PaymentDetailWrapper>)JSON.deserialize(payments, List<PaymentDetailWrapper>.class);
            if(paymentList.isEmpty()){
                resultList.add('#Add payment details.');
            }else{
                Decimal percentage = 0;
                for(PaymentDetailWrapper pd : paymentList){
                    percentage += pd.milestonePercentage;
                }
                if(percentage != 100){
                    resultList.add('#Payment milestones percentage should be 100%.');
                }
            }
        }else{
            resultList.add('#Add payment details.');
        }
        system.debug('resultList::'+resultList);
        return resultList;
    }
	
    @AuraEnabled
    public static string cloneQuote(string q, string lineItems, string pdList, string qdList, string payments, string otherItem){
       // try{
			Quote qRec = new Quote();
            qRec = (Quote)JSON.deserialize(q, Quote.class);
            
            List<QuoteLineItemParse> qparse = new List<QuoteLineItemParse>();
            qparse = QuoteLineItemParse.parse(lineItems);
            List<QuoteLineItem> selectedLineItem = new List<QuoteLineItem>();
            for(QuoteLineItemParse st : qparse){
                for(quoteLineItemWrapper ql : st.value){
                    selectedLineItem.add(ql.quoteItem);
                    if(ql.upperProducts != null && !ql.upperProducts.isEmpty()){
                		for(string up : ql.upperProducts){
                            QuoteLineItem newItem = new QuoteLineItem();
                            newItem.Product2Id = up;
                            newItem.UnitPrice = ql.quoteItem.UnitPrice;
                            newItem.Quantity = ql.quoteItem.Quantity;
                            newItem.Room__c = ql.quoteItem.Room__c;
                            newItem.Surface__c = ql.quoteItem.Surface__c;
                            newItem.Pricing_Modal__c = ql.quoteItem.Pricing_Modal__c;
                            newItem.Description = ql.quoteItem.Description;
                            newItem.Quantity__c = ql.quoteItem.Quantity__c;
                            newItem.Other_Charge__c = ql.quoteItem.Other_Charge__c;
                            selectedLineItem.add(newItem);
                        }
                    }
                }
            }
            
            List<ProductDiscountWrapper> productDiscounts = new List<ProductDiscountWrapper>();
            if(string.isNotBlank(pdList)){
                productDiscounts = (List<ProductDiscountWrapper>)JSON.deserialize(pdList, List<ProductDiscountWrapper>.class);
            }
            
            List<QuoteLevelDiscountWrapper> quoteDiscounts = new List<QuoteLevelDiscountWrapper>();
            if(string.isNotBlank(qdList)){
                quoteDiscounts = (List<QuoteLevelDiscountWrapper>)JSON.deserialize(qdList, List<QuoteLevelDiscountWrapper>.class);
            }
            
            List<PaymentDetailWrapper> paymentList = new List<PaymentDetailWrapper>();
            if(string.isNotBlank(payments)){
                paymentList = (List<PaymentDetailWrapper>)JSON.deserialize(payments, List<PaymentDetailWrapper>.class);
            }
            
            quoteLineItemWrapper otherLineItem = new quoteLineItemWrapper();
            if(string.isNotBlank(otherItem)){
                otherLineItem = (quoteLineItemWrapper)JSON.deserialize(otherItem, quoteLineItemWrapper.class);
                if(otherLineItem.quoteItem.Quantity != null && otherLineItem.quoteItem.UnitPrice != null){
                    otherLineItem.quoteItem.Room__c = 'Other';
                    otherLineItem.quoteItem.Surface__c = 'Other';
                    otherLineItem.quoteItem.Other_Charge__c = true;
                    selectedLineItem.add(otherLineItem.quoteItem);
                }
            }
            
            Quote newQuoteRecord = new Quote();
            newQuoteRecord = qRec.clone(false, false, false, false);  
            newQuoteRecord.Status = 'Draft';
        	newQuoteRecord.Public_URL__c = '';
        	newQuoteRecord.Quote_Approval_Link__c = '';
        	newQuoteRecord.Site__c = null;
            
            for(Integer i=1; i<=3;i++){
                newQuoteRecord.put('Discount_Name_'+ i + '__c','');
                newQuoteRecord.put('Discount_Type_'+ i + '__c',''); 
                newQuoteRecord.put('Discount_Value_'+ i + '__c',0);
            }
            Integer j=1;
            for(Integer i=0; i<quoteDiscounts.size();i++){
                newQuoteRecord.put('Discount_Name_'+ j + '__c',quoteDiscounts[i].discountName);
                newQuoteRecord.put('Discount_Type_'+ j + '__c',quoteDiscounts[i].discountType); 
                newQuoteRecord.put('Discount_Value_'+ j + '__c',quoteDiscounts[i].discountPrice); 
                j++;
            }
            
            Map<string,List<ProductDiscountWrapper>> productDiscountMap = new Map<string,List<ProductDiscountWrapper>>();
            if(productDiscounts != null && !productDiscounts.isEmpty()){
                for(ProductDiscountWrapper pd : productDiscounts){
                    if(productDiscountMap.containskey(pd.selectedProduct)){
                        List<ProductDiscountWrapper> dummyList = new List<ProductDiscountWrapper>();
                        dummyList = productDiscountMap.get(pd.selectedProduct);
                        dummyList.add(pd);
                        productDiscountMap.put(pd.selectedProduct, dummyList);
                    }else{
                        List<ProductDiscountWrapper> dummyList = new List<ProductDiscountWrapper>();
                        dummyList.add(pd);
                        productDiscountMap.put(pd.selectedProduct, dummyList);
                    }
                }
            }
            
            Pricebook2 pBook = getPriceBook();
        	Map<string,PricebookEntry> pBookMap = getPriceBookEntry(pBook.Id);
            
            insert newQuoteRecord;
            
            List<QuoteLineItem> quoteLineItemForInsert = new List<QuoteLineItem>();
            for(QuoteLineItem olditem : selectedLineItem){
                QuoteLineItem newItem = new QuoteLineItem();
                newItem.Product2Id = olditem.Product2Id;
                newItem.QuoteId = newQuoteRecord.Id;
                newItem.UnitPrice = olditem.UnitPrice;
                newItem.Quantity = olditem.Quantity;
                newItem.Room__c = olditem.Room__c;
                newItem.Surface__c = olditem.Surface__c;
                newItem.Pricing_Modal__c = olditem.Pricing_Modal__c;
                newItem.Description = olditem.Description;
                newItem.Quantity__c = olditem.Quantity__c;
                newItem.Other_Charge__c = olditem.Other_Charge__c;
                
                if(productDiscountMap.containskey(newItem.Product2Id)){
                    for(ProductDiscountWrapper pd : productDiscountMap.get(newItem.Product2Id)){
                        if(pd.discountType == 'Percentage'){
                            newItem.Discount = pd.discountPrice;
                        }else if(pd.discountType == 'Amount'){
                            newItem.Discount_Lumpsum__c = pd.discountPrice;
                        }
                    }
                }
                
                if(pBookMap.containskey(newItem.Product2Id)){
                    newItem.PricebookEntryId = pBookMap.get(newItem.Product2Id).Id;
                }
                
                quoteLineItemForInsert.add(newItem);
            }
            
        	insert quoteLineItemForInsert;
        
            if(!paymentList.isEmpty()){
                List<Payment_Milestone__c> pmListForInsert = new List<Payment_Milestone__c>();
                for(PaymentDetailWrapper pw : paymentList){
                    Payment_Milestone__c pm = new Payment_Milestone__c();
                    pm.Stage__c = pw.milestoneStage;
                    pm.Milestone_Percentage__c = pw.milestonePercentage;
                    pm.Quote__c = newQuoteRecord.Id;
                    pmListForInsert.add(pm);
                }
                insert pmListForInsert;
            } 
            
            return newQuoteRecord.Id;
        /*}Catch(Exception ex){
            return 'Fail';
        }  */         
    }
    
    
    public class quoteLineItemWrapper{
        @AuraEnabled public decimal area;
        @AuraEnabled public decimal quantity;
        @AuraEnabled public decimal price;
        @AuraEnabled public string  productId {get;set;}
        @AuraEnabled public string  productName;
        @AuraEnabled public string  pricingModal;
        @AuraEnabled public string  remarks;
        @AuraEnabled public string  discountype;
        @AuraEnabled public decimal discount;
        @AuraEnabled public decimal discountProduct;
        @AuraEnabled public string room;
        @AuraEnabled public string surface;
        @AuraEnabled public QuoteLineItem quoteItem;
        @AuraEnabled public Integer sequence;
        @AuraEnabled public List<string> upperProducts;
        @AuraEnabled public Boolean isExist;
        @AuraENabled public string service {get;set;}
        @AuraEnabled public Decimal productCost {get;set;}

        public quoteLineItemWrapper(){
            
            this.service = 'undefined';
            
            quoteItem = new QuoteLineItem();
            upperProducts = new List<string>();
        }
    }

    public class ProductDiscountWrapper{
        @AuraEnabled public decimal discountPrice;
        @AuraEnabled public Integer sequence;
        @AuraEnabled public string  discountType;
        @AuraEnabled public string  selectedProduct;
        @AuraEnabled public string  productName;
        @AuraEnabled public List<Product2>  productOptions;

        public ProductDiscountWrapper(){
            productOptions = new List<Product2>();
        }
    }

    public class QuoteLevelDiscountWrapper{
        @AuraEnabled public decimal discountPrice;
        @AuraEnabled public Integer sequence;
        @AuraEnabled public string  discountType;
        @AuraEnabled public string  discountName;

        public QuoteLevelDiscountWrapper(){
        }
    }

    public class PaymentDetailWrapper{
        @AuraEnabled public string milestoneStage;
        @AuraEnabled public Integer sequence;
        @AuraEnabled public Decimal  milestonePercentage;

        public PaymentDetailWrapper(){
        }
    }

    public class RecommendationWrapper{
        @AuraEnabled public string Symptom;
        @AuraEnabled public string Recommendation;

        public RecommendationWrapper(){
        }
    }

    public class DealerWrapper{
        @AuraEnabled public string dealerName;
        @AuraEnabled public string dealerId;
        @AuraEnabled public string message;
        @AuraEnabled public boolean noDealer;


        public DealerWrapper(){
        }
    }

}