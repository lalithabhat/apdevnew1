@isTest
public class TestQuotation {
    @isTest  
    private static void quoteTest_I() {
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        Map<String,string> resultMap = TestDataFactory.createData_for_Quote(op.Id);
        string shcId = resultMap.get('SHC');
        string productId1 = resultMap.get('Product 1');
        string productId2 = resultMap.get('Product 2');
        set<string> productIds = new set<string>{productId1,productId2};
        string product_serialize = JSON.serialize(productIds);
        string portalId = resultMap.get('Portal USer');
        Test.startTest();
            Opportunity getOpty = Quotation.getOpportunity(op.Id);
            Site_Health_Card__c getSHC = Quotation.getSiteHealthCardRecord(shcId);
            List<Quotation.DealerWrapper> dealerList = Quotation.getDealerList(portalId);
            List<Quotation.RecommendationWrapper> getOCList = Quotation.getRecommendationList(shcId);
            List<string> roomValues = Quotation.getRoomValues();
            List<string> surfaceValues = Quotation.getSurfaceValues();
            List<Quotation.quoteLineItemWrapper> room = Quotation.addRoom(null, roomValues[0]);
            Quotation.quoteLineItemWrapper surface = Quotation.addSurface(roomValues[0], surfaceValues[0],null);
            Product2 pd = Quotation.getProductDetails(productId1);
            List<Product2> productlist = Quotation.getProductOptions(product_serialize);
            List<Quotation.ProductDiscountWrapper> productDiscountList = Quotation.getProductDiscountList(null);
            List<Quotation.QuoteLevelDiscountWrapper> quoteDiscountList = Quotation.getQuoteLevelDiscountList(null);
            Quotation.quoteLineItemWrapper otherCharge = Quotation.addOtherCharge(null);
            string otherCharge_serialize = JSON.serialize(otherCharge);
            otherCharge = Quotation.deleteOtherCharge(null);
            List<Quotation.PaymentDetailWrapper> paymentList = Quotation.getPaymentDetailList(null);
            Pricebook2 pb = Quotation.getPriceBook();
            Map<string,PricebookEntry> pbEntryMap = Quotation.getPriceBookEntry(pb.Id);
            List<Product2> pdList = Quotation.getMaskingCharge();
        Test.stopTest();
    }
    
    @isTest  
    private static void quoteTest_II() {
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        Map<String,string> resultMap = TestDataFactory.createData_for_Quote(op.Id);
        string shcId = resultMap.get('SHC');
        string productId1 = resultMap.get('Product 1');
        string productId2 = resultMap.get('Product 2');
        set<string> productIds = new set<string>{productId1,productId2};
        string product_serialize = JSON.serialize(productIds);
        string portalId = resultMap.get('Portal USer');
        string SHC_Serialize = resultMap.get('SHC_Serialize');
        string dealerId = resultMap.get('DEALER');
        string Contractor = resultMap.get('Contractor 1');
        URL__c url = new URL__c();
        url.Name = 'Quote Approval';
        url.URL__c = 'https://apldev-chatbottest.ind3s.sfdc-y37hzm.force.com/';
        insert url;
        
        Product_Class_Sequence__c pcs = new Product_Class_Sequence__c();
        pcs.Name='Premium';
        pcs.One_Level_Up__c = '';
        pcs.Sequence__c = 1;
        insert pcs;
        Test.startTest();
            Opportunity getOpty = Quotation.getOpportunity(op.Id);
            Site_Health_Card__c getSHC = Quotation.getSiteHealthCardRecord(shcId);
            List<string> roomValues = Quotation.getRoomValues();
            List<string> surfaceValues = Quotation.getSurfaceValues();
            Map<string,string> dataMap = new Map<string,string>();
            dataMap = createData(productId1,productId2,surfaceValues[0],roomValues[0],dealerId);
            string msg = Quotation.saveQuote(dataMap.get('quoteItems'), dataMap.get('productdiscounts'), dataMap.get('quotediscounts'), 
                                  dataMap.get('othercharge'), dataMap.get('paymentList'), dataMap.get('fieldset'), 
                                  SHC_Serialize,null,null
                                  );   
        
            PageReference pRef = Page.QuoteOutput_WideRangeServices;
            Test.setCurrentPage(pRef);
            ApexPages.currentPage().getParameters().put('id',msg);
            QuoteOutput_WideRangeServices qController = new QuoteOutput_WideRangeServices();
            SharePanelGlobal.savePDFWrapper pdfresult = SharePanelGlobal.savePDF(msg, 'Quote', null);
            pdfresult = SharePanelGlobal.getDocURL(msg);
            pdfresult = SharePanelGlobal.getPublicURL(msg, 'Quote', null);
            SharePanelGlobal.sendPDFCustomer(msg, 'Email', null, 'Quote', null);
            SharePanelGlobal.sendToCustomer(msg, 'Email', null, 'Quote');
        
            Milestone1_Project__c site = new Milestone1_Project__c();
            site.Status__c = 'Active';
            site.Kickoff__c = system.today();
            site.Deadline__c = system.today().addDays(1);
            site.Reason__c = 'First Site';
            site.PincodeLookup__c = pincode.Id;
            site.Account__c = ac.Id;
            insert site;
            
            Quote q = new Quote();
            q.Id = msg;
            q.Site__c = site.Id;
            q.Contractor__c = Contractor;
            q.Status = 'Accepted';
            update q;
        	
        	Map<String,String> pickVal = GetPickList.getPicklistValues('Product2','Product_Class__c');
        	Map<string,string> getUpperProducts = GetPickList.getOneLevelUpProduct(productId1);
        
            List<QuoteDetails_OnSiteClose.QuoteDetails> getQuotes = QuoteDetails_OnSiteClose.getQuoteRecords(site.Id);
        Test.stopTest();
    }
    
    @isTest  
    private static void quoteTest_III() {
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        Map<String,string> resultMap = TestDataFactory.createData_for_Quote(op.Id);
        string shcId = resultMap.get('SHC');
        string productId1 = resultMap.get('Product 1');
        string productId2 = resultMap.get('Product 2');
        set<string> productIds = new set<string>{productId1,productId2};
        string product_serialize = JSON.serialize(productIds);
        string portalId = resultMap.get('Portal USer');
        string SHC_Serialize = resultMap.get('SHC_Serialize');
        string dealerId = resultMap.get('DEALER');
        string Contractor = resultMap.get('Contractor 1');
        Test.startTest();
            Opportunity getOpty = Quotation.getOpportunity(op.Id);
            Site_Health_Card__c getSHC = Quotation.getSiteHealthCardRecord(shcId);
            List<string> roomValues = Quotation.getRoomValues();
            List<string> surfaceValues = Quotation.getSurfaceValues();
            Map<string,string> dataMap = new Map<string,string>();
            dataMap = createData(productId1,productId2,surfaceValues[0],roomValues[0],dealerId);
            string msg = Quotation.saveQuote(dataMap.get('quoteItems'), dataMap.get('productdiscounts'), dataMap.get('quotediscounts'), 
                                  dataMap.get('othercharge'), dataMap.get('paymentList'), dataMap.get('fieldset'), 
                                  SHC_Serialize,null,null
                                  );   
        
            quote q = Quotation.getQuoteRecord(msg);
            string quote_Serialize = Json.serialize(q);
            map<string,List<Quotation.quoteLineItemWrapper>> qItems = Quotation.getQuoteLineItems(msg);
            List<Quotation.quoteLineItemWrapper> wrapperItems = new List<Quotation.quoteLineItemWrapper>();
            for(string st : qItems.keyset()){
                wrapperItems.addAll(qItems.get(st));
            }
            string qItems_Serialize = Json.serialize(wrapperItems);
            string final_item_serialize = '[{"label":"'+ roomValues[0] +'","value":'+ qItems_Serialize +'},{"label":"'+ roomValues[1] +
                                        '","value":[]}]';
            List<Quotation.ProductDiscountWrapper> prodList = Quotation.getExistingProductLevelDiscount(msg);
            List<Quotation.QuoteLevelDiscountWrapper> qdList = Quotation.getExistingQuoteLevelDiscount(quote_Serialize);
            qItems = Quotation.addLineItem(roomValues[0],surfaceValues[2],msg,final_item_serialize);
            qItems = Quotation.addLineItem(roomValues[1],surfaceValues[1],msg,final_item_serialize);
            Quotation.quoteLineItemWrapper otherItems = Quotation.addOtherCharge(msg);
            List<Quotation.PaymentDetailWrapper> payments = Quotation.getExistingPaymentDetailList(msg);
        Test.stopTest();
    }
    
    @isTest  
    private static void quoteTest_IV() {
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        Map<String,string> resultMap = TestDataFactory.createData_for_Quote(op.Id);
        string shcId = resultMap.get('SHC');
        string productId1 = resultMap.get('Product 1');
        string productId2 = resultMap.get('Product 2');
        set<string> productIds = new set<string>{productId1,productId2};
        string product_serialize = JSON.serialize(productIds);
        string portalId = resultMap.get('Portal USer');
        string SHC_Serialize = resultMap.get('SHC_Serialize');
        string dealerId = resultMap.get('DEALER');
        string Contractor = resultMap.get('Contractor 1');
        Test.startTest();
            Opportunity getOpty = Quotation.getOpportunity(op.Id);
            Site_Health_Card__c getSHC = Quotation.getSiteHealthCardRecord(shcId);
            List<string> roomValues = Quotation.getRoomValues();
            List<string> surfaceValues = Quotation.getSurfaceValues();
            Map<string,string> dataMap = new Map<string,string>();
            dataMap = createData(productId1,productId2,surfaceValues[0],roomValues[0],dealerId);
            string msg = Quotation.saveQuote(dataMap.get('quoteItems'), dataMap.get('productdiscounts'), dataMap.get('quotediscounts'), 
                                  dataMap.get('othercharge'), dataMap.get('paymentList'), dataMap.get('fieldset'), 
                                  SHC_Serialize,null,null
                                  );   
        
            quote q = Quotation.getQuoteRecord(msg);
            q.Tier__c = null;
            q.Name = null;
            q.New_Services__c = null;
            q.Number_of_Painters__c = null;
            q.ExpirationDate = null;
            string quote_Serialize = Json.serialize(q);
            map<string,List<Quotation.quoteLineItemWrapper>> qItems = Quotation.getQuoteLineItems(msg);
            List<Quotation.quoteLineItemWrapper> wrapperItems = new List<Quotation.quoteLineItemWrapper>();
            for(string st : qItems.keyset()){
                wrapperItems.addAll(qItems.get(st));
            }
            string qItems_Serialize = Json.serialize(wrapperItems);
            string final_item_serialize = '[{"label":"'+ roomValues[0] +'","value":'+ qItems_Serialize +'},{"label":"'+ roomValues[1] +
                                        '","value":[]}]';
            //List<Quotation.ProductDiscountWrapper> prodList = Quotation.getExistingProductLevelDiscount(msg);
            //List<Quotation.QuoteLevelDiscountWrapper> qdList = Quotation.getExistingQuoteLevelDiscount(quote_Serialize);
            //Quotation.quoteLineItemWrapper otherItems = Quotation.addOtherCharge(msg);
            //List<Quotation.PaymentDetailWrapper> payments = Quotation.getExistingPaymentDetailList(msg);
            map<string,List<Quotation.quoteLineItemWrapper>> qItemsD = Quotation.addLineItem(roomValues[0],surfaceValues[1],msg,final_item_serialize);
            List<Quotation.quoteLineItemWrapper> wrapperItemsD = new List<Quotation.quoteLineItemWrapper>();
            for(string st : qItemsD.keyset()){
                wrapperItemsD.addAll(qItemsD.get(st));
            }
            string qItems_SerializeD = Json.serialize(wrapperItemsD);
            string final_item_serializeD = '[{"label":"'+ roomValues[0] +'","value":'+ qItems_SerializeD +'}]'; 
            List<string> strList = Quotation.validateQuote(quote_Serialize,final_item_serializeD,null,null,null);
            q.Tier__c = 'Gold';
            q.New_Services__c = 'DWS';
            quote_Serialize = Json.serialize(q);
            List<string> strList2 = Quotation.validateQuote(quote_Serialize,final_item_serializeD,null,null,null);
        Test.stopTest();
    }
    
    @isTest  
    private static void quoteTest_V() {
        Account ac  = TestDataFactory.createPersonAccount('1234567890','test@stetig.in');
        Pincode__c pincode  = TestDataFactory.createPincodeRecord('123456');
        Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('SPS').getRecordTypeId();
        Opportunity op  = TestDataFactory.createOpportunity(ac.Id,devRecordTypeId,pincode.Id);
        Map<String,string> resultMap = TestDataFactory.createData_for_Quote(op.Id);
        string shcId = resultMap.get('SHC');
        string productId1 = resultMap.get('Product 1');
        string productId2 = resultMap.get('Product 2');
        set<string> productIds = new set<string>{productId1,productId2};
        string product_serialize = JSON.serialize(productIds);
        string portalId = resultMap.get('Portal USer');
        string SHC_Serialize = resultMap.get('SHC_Serialize');
        string dealerId = resultMap.get('DEALER');
        string Contractor = resultMap.get('Contractor 1');
        Test.startTest();
            Opportunity getOpty = Quotation.getOpportunity(op.Id);
            Site_Health_Card__c getSHC = Quotation.getSiteHealthCardRecord(shcId);
            List<string> roomValues = Quotation.getRoomValues();
            List<string> surfaceValues = Quotation.getSurfaceValues();
            Map<string,string> dataMap = new Map<string,string>();
            dataMap = createData(productId1,productId2,surfaceValues[0],roomValues[0],dealerId);
            string msg = Quotation.saveQuote(dataMap.get('quoteItems'), dataMap.get('productdiscounts'), dataMap.get('quotediscounts'), 
                                  dataMap.get('othercharge'), dataMap.get('paymentList'), dataMap.get('fieldset'), 
                                  SHC_Serialize,null,null
                                  );   
        
            quote q = Quotation.getQuoteRecord(msg);
            string quote_Serialize = Json.serialize(q);
            map<string,List<Quotation.quoteLineItemWrapper>> qItems = Quotation.getQuoteLineItems(msg);
            List<Quotation.quoteLineItemWrapper> wrapperItems = new List<Quotation.quoteLineItemWrapper>();
            for(string st : qItems.keyset()){
                wrapperItems.addAll(qItems.get(st));
            }
            string qItems_Serialize = Json.serialize(wrapperItems);
            string final_item_serialize = '[{"label":"'+ roomValues[0] +'","value":'+ qItems_Serialize +'}]';
            List<Quotation.ProductDiscountWrapper> prodList = Quotation.getExistingProductLevelDiscount(msg);
            string prodList_Serialize = Json.serialize(prodList);
            List<Quotation.QuoteLevelDiscountWrapper> qdList = Quotation.getExistingQuoteLevelDiscount(quote_Serialize);
            string qdList_Serialize = Json.serialize(qdList);
            Quotation.quoteLineItemWrapper otherItems = Quotation.addOtherCharge(msg);
            string otherItems_Serialize = Json.serialize(otherItems);
            List<Quotation.PaymentDetailWrapper> payments = Quotation.getExistingPaymentDetailList(msg);
            string payments_Serialize = Json.serialize(payments);
            string returnMsg = Quotation.cloneQuote(quote_Serialize, final_item_serialize, prodList_Serialize, qdList_Serialize,
                                                payments_Serialize, otherItems_Serialize);
        Test.stopTest();
    }
    
    Public Static Map<string,string> createData( string productId1, string productId2, string surface, string room, string dealerId){
        Map<string,string> resultMap = new Map<string,string>();
        List<Quotation.quoteLineItemWrapper> quoteItems = new List<Quotation.quoteLineItemWrapper>();
        Quotation.quoteLineItemWrapper qw = new Quotation.quoteLineItemWrapper();
        qw.area = 100;
        qw.productId = productId1;
        qw.pricingModal = 'Labour';
        qw.quantity = 10;
        qw.remarks = 'ok';
        qw.surface = surface;
        qw.room = room;
        qw.upperProducts.add(productId2);
        qw.price = 100;
        qw.sequence = 0;
        quoteItems.add(qw);
        string quoteItems_serialize = Json.serialize(quoteItems) ;   
        resultMap.put('quoteItems',quoteItems_serialize);
        
        List<Quotation.ProductDiscountWrapper> pwdList = new List<Quotation.ProductDiscountWrapper>();
        Quotation.ProductDiscountWrapper pwd = new Quotation.ProductDiscountWrapper();
        pwd.discountPrice = 1;
        pwd.discountType = 'Percentage';
        pwd.selectedProduct = productId1;
        pwd.sequence = 0;
        pwdList.add(pwd);
        Quotation.ProductDiscountWrapper pwd2 = new Quotation.ProductDiscountWrapper();
        pwd2.discountPrice = 10;
        pwd2.discountType = 'Amount';
        pwd2.selectedProduct = productId2;
        pwd2.sequence = 1;
        pwdList.add(pwd2);
        string pwdList_serialize = Json.serialize(pwdList) ;
        resultMap.put('productdiscounts',pwdList_serialize);
        
        List<Quotation.QuoteLevelDiscountWrapper> qwdList = new List<Quotation.QuoteLevelDiscountWrapper>();
        Quotation.QuoteLevelDiscountWrapper qwd = new Quotation.QuoteLevelDiscountWrapper();
        qwd.discountName = 'Q1';
        qwd.discountPrice = 10;
        qwd.discountType = 'Amount';
        qwd.sequence = 0;
        qwdList.add(qwd);
        Quotation.QuoteLevelDiscountWrapper qwd2 = new Quotation.QuoteLevelDiscountWrapper();
        qwd2.discountName = 'Q2';
        qwd2.discountPrice = 1;
        qwd2.discountType = 'Percentage';
        qwd2.sequence = 1;
        qwdList.add(qwd2);
        string qwdList_serialize = Json.serialize(qwdList) ;
        resultMap.put('quotediscounts',qwdList_serialize);
        
        Quotation.quoteLineItemWrapper othercharge = new Quotation.quoteLineItemWrapper();
        othercharge.area = 100;
        othercharge.productId = productId2;
        othercharge.pricingModal = 'Labour';
        othercharge.quantity = 10;
        othercharge.remarks = 'ok';
        othercharge.price = 100;
        othercharge.sequence = 0;    
        string othercharge_serialize = Json.serialize(othercharge) ;
        resultMap.put('othercharge',othercharge_serialize);
        
        List<Quotation.PaymentDetailWrapper> paymentList = new List<Quotation.PaymentDetailWrapper>();
        Quotation.PaymentDetailWrapper payment = new Quotation.PaymentDetailWrapper();
        payment.milestonePercentage = 50;
        payment.milestoneStage = 'Stage 1';
        payment.sequence = 0;
        paymentList.add(payment);
        Quotation.PaymentDetailWrapper payment2 = new Quotation.PaymentDetailWrapper();
        payment2.milestonePercentage = 50;
        payment2.milestoneStage = 'Stage 1';
        payment2.sequence = 0;
        paymentList.add(payment2);
        string paymentList_serialize = Json.serialize(paymentList) ;
        resultMap.put('paymentList',paymentList_serialize);
        
        string fieldset = '[{"label":"area","value":"100"},{"label":"bhk","value":"1"},{"label":"gender","value":"Male"},'+
            '{"label":"ageBand","value":"21-25"},{"label":"maritalStatus","value":"Married"},'+
            '{"label":"profession","value":"Developer"},{"label":"familyType","value":"Joint"},'+
            '{"label":"kids","value":"1"},{"label":"quoteName","value":"MD Approval"},{"label":"tier","value":"Gold"},'+
            '{"label":"numberOfPainter"},{"label":"areaAppliedPerPainter","value":"1"},'+
            '{"label":"siteType","value":"Fresh"},{"label":"bufferTime"},{"label":"newServices","value":"DWS"},'+
            '{"label":"selectedDealer","value":"'+dealerId+'"},{"label":"expirationDate","value":"2022-2-19"}]';
        resultMap.put('fieldset',fieldset);
        
        return resultMap;
    }
}