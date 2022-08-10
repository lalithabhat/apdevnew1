import { LightningElement,api,track,wire } from 'lwc';
import getQuoteRecord from '@salesforce/apex/Quotation.getQuoteRecord';
import getRecommendationList from '@salesforce/apex/Quotation.getRecommendationList';
import getQuoteLineItems from '@salesforce/apex/Quotation.getQuoteLineItems';
import getRoomValues from '@salesforce/apex/Quotation.getRoomValues';
import getSurfaceValues from '@salesforce/apex/Quotation.getSurfaceValues';
import addLineItem from '@salesforce/apex/Quotation.addLineItem';  
import getExistingProductLevelDiscount from '@salesforce/apex/Quotation.getExistingProductLevelDiscount';
import getExistingQuoteLevelDiscount from '@salesforce/apex/Quotation.getExistingQuoteLevelDiscount';
import getProductDiscountList from '@salesforce/apex/Quotation.getProductDiscountList'; 
import getQuoteLevelDiscountList from '@salesforce/apex/Quotation.getQuoteLevelDiscountList';
import getProductOptions from '@salesforce/apex/Quotation.getProductOptions';
import addOtherCharge from '@salesforce/apex/Quotation.addOtherCharge'; 
import getExistingPaymentDetailList from '@salesforce/apex/Quotation.getExistingPaymentDetailList'; 
import getPaymentDetailList from '@salesforce/apex/Quotation.getPaymentDetailList'; 
import validateQuote from '@salesforce/apex/Quotation.validateQuote'; 
import cloneQuote from '@salesforce/apex/Quotation.cloneQuote';
import saveQuotePDF from '@salesforce/apex/SharePanelGlobal.savePDF' 

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

let itemMap;
export default class EditQuote_LWC extends NavigationMixin(LightningElement) {

    @track quote;
    @api recordId;
    @track quoteId;
    @track RecommendationList = [];
    @track mapData = [];
    @track isShowModal = false;
    @track roomValues = [];
    @track isShowSurfaceModal = false;
    @track surfaceValues = [];
    @track selectedRoom;
    @track showSpinner = false;
    @track productDiscountList = [];
    @track quoteDiscountList = [];
    @track productList = [];
    @track discountTypeList = [];
    @track otherChargeRecord;
    @track otherchargeId='';
    @track otherchargeQuantity;
    @track otherchargeProductName='';
    @track otherchargeProductId='';
    @track otherchargeExist=false;
    @track paymentList=[];

    @wire(addOtherCharge, {qId:'$recordId'})
    addOtherCharge({data, error}){
        if(data){
            this.otherChargeRecord = JSON.stringify(data);
            this.otherChargeRecord = JSON.parse(this.otherChargeRecord);
            if(this.otherChargeRecord.quoteItem.Id != null && this.otherChargeRecord.quoteItem.Id != undefined){
                this.otherchargeId = this.otherChargeRecord.quoteItem.Id;
                this.otherchargeQuantity = this.otherChargeRecord.quoteItem.Quantity__c;
                this.otherchargeProductName = this.otherChargeRecord.productName;
                this.otherchargeProductId = this.otherChargeRecord.quoteItem.Product2Id;
                this.otherchargeExist = true;
            }
        }else if (error) {
            this.error = error;
            console.log('Error while OtherChargeMethod::'+error);
        }
    }

    @wire(getQuoteRecord, {qId:'$recordId'})
    getQuoteRecord({data, error}){
        if(data){
            this.quote = JSON.stringify(data);
            this.quote = JSON.parse(this.quote);
            this.quoteId = this.quote.Id;
            getRecommendationList({shcId:this.quote.Site_Health_Card__c})
                .then(result => {
                    this.RecommendationList = JSON.stringify(result);
                    this.RecommendationList = JSON.parse(this.RecommendationList);
                    console.log('RecommendationList::'+this.RecommendationList.length);
                })
                .catch(error => {
                    console.log('Errorured in RecommendationList method:- '+error);
                });
            
            let tempQuote =  JSON.stringify(this.quote);
            getExistingQuoteLevelDiscount({qId:tempQuote})
                .then(result => {
                    this.quoteDiscountList = JSON.stringify(result);
                    this.quoteDiscountList = JSON.parse(this.quoteDiscountList);
                })
                .catch(error => {
                    console.log('Errorured in getExistingQuoteLevelDiscount method:- '+error);
                });               
        }else if (error) {
            this.error = error;
            console.log('Error while getQuoteRecord::'+error);
        }
    }

    @wire(getQuoteLineItems, {qId:'$recordId'})
    getQuoteLineItems({data, error}){
        if(data){
            let dummy = JSON.stringify(data);
            dummy = JSON.parse(dummy);
            itemMap = new Map();
            for (let key in dummy) {                
                this.mapData.push({value:dummy[key], key:key});
                itemMap.set(key,dummy[key]);
             }
             console.log('mapDta:: '+this.mapData);
        }else if (error) {
            this.error = error;
            console.log('Error while getQuoteLineItems::'+error);
        }
    }

    @wire(getExistingProductLevelDiscount, {qId:'$recordId'})
    getExistingProductLevelDiscount({data, error}){
        if(data){
            this.productDiscountList = JSON.stringify(data);
            this.productDiscountList = JSON.parse(this.productDiscountList);
            for(var i=0; i<data.length; i++) {
                this.productList = [...this.productList ,{value: data[i].selectedProduct, label: data[i].productName}];                                   
            }
            this.discountTypeList = [...this.discountTypeList ,{value: 'Percentage', label: '%'}];
            this.discountTypeList = [...this.discountTypeList ,{value: 'Amount', label: '₹'}];
        }else if (error) {
            this.error = error;
            console.log('Error while getExistingProductLevelDiscount::'+error);
        }
    }

    @wire(getExistingPaymentDetailList, {qId:'$recordId'})
    getExistingPaymentDetailList({data, error}){
        if(data){
            this.paymentList = JSON.stringify(data);
            this.paymentList = JSON.parse(this.paymentList);
        }else if (error) {
            this.error = error;
            console.log('Error while getExistingPaymentDetailList::'+error);
        }
    }

    @wire(getRoomValues, {})
    getRoomValues({data, error}){
        if(data){
          for(var i=0; i<data.length; i++) {
            this.roomValues = [...this.roomValues ,{value: data[i], label: data[i]}];                                   
          }
        }else if (error) {
            this.error = error;
        }
    }
    get roomOptions(){
        return this.roomValues;
    }
    selectRoom(event){
        const selectedOption = event.detail.value;
        this.isShowModal = false;
        //alert(itemMap.has(selectedOption));
        if(itemMap.has(selectedOption)){
            alert('This room already added');
        }else{
            this.mapData.push({value:null, key:selectedOption});
            itemMap.set(selectedOption,null);
        }
        
    }

    showModalBox() {  
        this.isShowModal = true;
    }
    hideModalBox() {  
        this.isShowModal = false;
    }

    @wire(getSurfaceValues, {})
    getSurfaceValues({data, error}){
        if(data){
          for(var i=0; i<data.length; i++) {
            this.surfaceValues = [...this.surfaceValues ,{value: data[i], label: data[i]}];                                   
          }
        }else if (error) {
            this.error = error;
        }
    }
    get surfaceOptions(){
        return this.surfaceValues;
    }

    selectSurface(event){
        this.showSpinner = true;
        const selectedOption = event.detail.value;
        this.isShowSurfaceModal = false;
        
        let mapStringParam = [];
        itemMap.forEach(function(value, key) {
            mapStringParam.push({label:key, value:value});
        })
        let tempquoteLineItem = JSON.stringify(mapStringParam);

        addLineItem({room:this.selectedRoom,surface:selectedOption, qId:this.recordId, existingList:tempquoteLineItem})
            .then(result => {
                let dummy = JSON.stringify(result);
                dummy = JSON.parse(dummy);
                itemMap = new Map();
                this.mapData = [];
                for (let key in dummy) {                    
                    this.mapData.push({value:dummy[key], key:key});
                    itemMap.set(key,dummy[key]);
                }
                this.showSpinner = false;
            })
            .catch(error => {
                console.log('Errorured in addLineItem method:- '+error);
                this.showSpinner = false;
            });
    }
    showSurfaceModalBox(event){
        this.isShowSurfaceModal = true;
        //alert('seq:: '+event.target.dataset.id);
        this.selectedRoom = event.target.dataset.id;
    }
    hideSurfaceModalBox(){
        this.isShowSurfaceModal = false;
        this.selectedRoom = null;
    }

     fetchQuoteName(event){
        console.log('Quote Name::'+event.target.value);
        this.quote.Name = event.target.value;
     }

     @track isTier = false;
     tierChange(event){
        console.log('tier Name::'+event.target.value);
        this.quote.Tier__c = event.target.value;
        if(this.tier == 'Platinum'){
            this.isTier = true;
        }else{
            this.isTier = false;
        }
     }

     newServiceseChange(event){
        console.log('newServices::'+event.target.value);
        this.quote.New_Services__c = event.target.value;
     }

     expirationDateChange(event){
        console.log('expirationDate::'+event.target.value);
        this.quote.ExpirationDate = event.target.value;
     }

     areaChange(event){
        console.log('area::'+event.target.value);
        console.log('room::'+event.target.name);
        var seq = event.target.dataset.id;
        var room = event.target.name;
        var value = event.target.value;
        /*let items = [];
        items = itemMap.get(name);
        items[seq].quoteItem.Quantity = value;
        itemMap.set(name,items);*/
        itemMap.get(room)[seq].quoteItem.Quantity = value;
        //alert(itemMap.get(room)[seq].quoteItem.Quantity);
     }
     productModelChange(event){
        console.log('productModel::'+event.target.value);
        console.log('room::'+event.target.name);
        var seq = event.target.dataset.id;
        var room = event.target.name;
        var value = event.target.value;
        itemMap.get(room)[seq].quoteItem.Pricing_Modal__c = value;
     }
     priceChange(event){
        console.log('price::'+event.target.value);
        console.log('room::'+event.target.name);
        var seq = event.target.dataset.id;
        var room = event.target.name;
        var value = event.target.value;
        itemMap.get(room)[seq].quoteItem.UnitPrice = value;
     }
     productChange(event){
        this.pickListValueList = [];
        console.log('ProductId::'+event.detail);
        console.log('room::'+event.target.name);
        var seq = event.target.dataset.id;
        var room = event.target.name;
        var value = event.detail;
        itemMap.get(room)[seq].quoteItem.Product2Id = value;

        let pIds = []; 
        itemMap.forEach((value, key) => {
            for(var i=0;i<value.length;i++){
                pIds.push(value[i].quoteItem.Product2Id);
            }
        })
        let tempIds = JSON.stringify(pIds);
        getProductOptions({productIds:tempIds})
            .then(result => {
                if(result.length > 0){
                    this.productList = [];
                    for(var j=0;j<result.length;j++){
                        this.productList = [...this.productList ,{value: result[j].Id, label: result[j].Name}];
                    }  
                }                
            })
            .catch(error => {
                console.log('Errorured in getProductDiscountList method:- '+error);
            });
        
     }
     quantityChange(event){
        console.log('Quanity::'+event.target.value);
        console.log('room::'+event.target.name);
        var seq = event.target.dataset.id;
        var room = event.target.name;
        var value = event.target.value;
        itemMap.get(room)[seq].quoteItem.Quantity__c = value;
     }
     remarksChange(event){
        console.log('remarks::'+event.target.value);
        console.log('room::'+event.target.name);
        var seq = event.target.dataset.id;
        var room = event.target.name;
        var value = event.target.value;
        itemMap.get(room)[seq].quoteItem.Description = value;
     }
     handleupperproductchange(event){
        var seq = event.target.dataset.id;
        var room = event.target.name;
        var value = event.detail;
        //alert(event.detail);
        itemMap.get(room)[seq].upperProducts = value;
     }

     deleteRoom(event){
        var room = event.target.dataset.id;
        itemMap.delete(room);
        this.mapData = [];
        itemMap.forEach((value, key) => {
            this.mapData.push({value:value, key:key});
        })
     }

     deleteSurface(event){
        var seq = event.target.dataset.id;
        var room = event.target.name;
        itemMap.get(room).splice(seq,1);
        for(var r=0;r<itemMap.get(room);r++){
            itemMap.get(room)[r].sequence = r;
        }
        this.mapData = [];
        itemMap.forEach((value, key) => {
            this.mapData.push({value:value, key:key});
        })
     }


     discountProductChange(event){
        console.log('Product in discount::'+event.target.value);
        var seq = event.target.dataset.id;
        var name = event.target.name;
        if(name == 'Product Discount'){
            this.productDiscountList[seq].selectedProduct = event.target.value;
        }
     }
     discountAmountChange(event){
        console.log('Amount in discount::'+event.target.value);
        var seq = event.target.dataset.id;
        var name = event.target.name;
        if(name == 'Product Discount'){
            this.productDiscountList[seq].discountPrice = event.target.value;
        }else{
            this.quoteDiscountList[seq].discountPrice = event.target.value;
        }
        
     }
     discountTypeChange(event){
        console.log('discountType in discount::'+event.target.value);
        var seq = event.target.dataset.id;
        var name = event.target.name;
        if(name == 'Product Discount'){
            this.productDiscountList[seq].discountType = event.target.value;
        }else{
            this.quoteDiscountList[seq].discountType = event.target.value;
        }
     }
     discountNameChange(event){
        console.log('discountName in discount::'+event.target.value);
        var seq = event.target.dataset.id;
        var name = event.target.name;
        if(name == 'Quote Discount'){
            this.quoteDiscountList[seq].discountName = event.target.value;
        }
     }
     addDiscount(event){
        console.log('inside ADD new Product discount');
        var name = event.target.name;
        if(name == 'Product Discount'){
            let tempRecord = JSON.stringify(this.productDiscountList);
            getProductDiscountList({pList:tempRecord})
                .then(result => {
                    this.productDiscountList = JSON.stringify(result);
                    this.productDiscountList = JSON.parse(this.productDiscountList);
                })
                .catch(error => {
                    console.log('Errorured in add new productDiscountList method:- '+error);
                });
        }else{ 
            let tempRecord = JSON.stringify(this.quoteDiscountList);
            getQuoteLevelDiscountList({dList:tempRecord})
                .then(result => {
                    this.quoteDiscountList = JSON.stringify(result);
                    this.quoteDiscountList = JSON.parse(this.quoteDiscountList);
                })
                .catch(error => {
                    console.log('Errorured in add new quoteDiscountList method:- '+error);
                });
        }
        
     }
     deleteDiscount(event){
        console.log('seq::'+event.target.dataset.id);
        var seq = event.target.dataset.id;
        var name = event.target.name;
        if(name == 'Product Discount'){
            this.productDiscountList.splice(seq,1);
            for(var q=0;q<this.productDiscountList.length;q++){
                this.productDiscountList[q].sequence = q;
            }
        }else{
            this.quoteDiscountList.splice(seq,1);
            for(var q=0;q<this.quoteDiscountList.length;q++){
                this.quoteDiscountList[q].sequence = q;
            }
        }
    }

    otherChargeAreaChange(event){
        this.otherChargeRecord.quoteItem.Quantity = event.target.value;
    }
    otherChargeProductModelChange(event){
        this.otherChargeRecord.quoteItem.Pricing_Modal__c = event.target.value;
    }
    otherChargePriceChange(event){
        this.otherChargeRecord.quoteItem.UnitPrice = event.target.value;
    }
    otherChargeProductChange(event){
        this.otherChargeRecord.quoteItem.Product2Id = event.target.value;
    }
    otherChargeQuantityChange(event){
        this.otherChargeRecord.quoteItem.Quantity__c = event.target.value;
    }
    otherChargeRemarksChange(event){
        this.otherChargeRecord.quoteItem.Description = event.target.value;
    }

    addPaymentdetail(event){
        let tempRecord = JSON.stringify(this.paymentList);
        getPaymentDetailList({existingList:tempRecord})
            .then(result => {
                this.paymentList = [];
                this.paymentList = JSON.stringify(result);
                this.paymentList = JSON.parse(this.paymentList);
            })
            .catch(error => {
                console.log('Errorured in add new paymentList method:- '+error);
            });
    }
    percentageSelect(event){
        var seq = event.target.dataset.id;
        this.paymentList[seq].milestonePercentage = event.target.value;
    }
    stageSelect(event){
        var seq = event.target.dataset.id;
        this.paymentList[seq].milestoneStage = event.target.value;
    }
    deletePaymentRow(event){
        var seq = event.target.dataset.id;
        this.paymentList.splice(seq,1);
        for(var q=0;q<this.paymentList.length;q++){
            this.paymentList[q].sequence = q;
        }
    }

    numberOfPainterChange(event){
        console.log('numberOfPainter::'+event.target.value);
        this.quote.Number_of_Painters__c = event.target.value;
    }
    areaAppliedPerPainterChange(event){
        console.log('areaAppliedPerPainter::'+event.target.value);
        this.quote.Area_Applied_per_Painter_Day__c = event.target.value;
    }
    siteTypeChange(event){
        console.log('siteType::'+event.target.value);
        this.quote.Site_Type__c = event.target.value;
    }
    bufferTimeChange(event){
        console.log('bufferTime::'+event.target.value);
        this.quote.Buffer_Time__c = event.target.value;
    }
    totalAreaSqft(event){
        console.log('totalAreaSqft select::'+event.target.value);
        this.quote.Total_Sq_ft_of_Home__c = event.target.value;
     }
     totalBHK(event){
        console.log('totalBHK select::'+event.target.value);
        this.quote.Total_BHK__c = event.target.value;
     }
     genderSelect(event){
        console.log('genderSelect ::'+event.target.value);
        this.quote.Gender__c = event.target.value;
     }
     ageBandSelect(event){
        console.log('ageBand select::'+event.target.value);
        this.quote.Age_Band__c = event.target.value;
     }
     maritalStatusSelect(event){
        console.log('maritalStatus select::'+event.target.value);
        this.quote.Marital_Status__c = event.target.value;
     }
     professionSelect(event){
        console.log('profession select::'+event.target.value);
        this.quote.Profession__c = event.target.value;
     }
     familytypeSelect(event){
        console.log('familytype select::'+event.target.value);
        this.quote.Family_Type__c = event.target.value;
     }
     kidsSelect(event){
        console.log('kids select::'+event.target.value);
        this.quote.Kids__c = event.target.value;
     }

     @track isSave = false;
     @track newQuoteId='';
     @track validationList = [];
     saveQuote(event){
        this.showSpinner = true;
        let tempQuoteRecord = JSON.stringify(this.quote);
        let mapStringParam = [];
        itemMap.forEach(function(value, key) {
            mapStringParam.push({label:key, value:value});
        })
        let tempquoteLineItem = JSON.stringify(mapStringParam);
        let tempPDiscount = JSON.stringify(this.productDiscountList);
        let tempQuoteDiscount = JSON.stringify(this.quoteDiscountList); 
        let tempPayments = JSON.stringify(this.paymentList);
        let tempOtherItems = JSON.stringify(this.otherChargeRecord);
        validateQuote({q:tempQuoteRecord,lineItems:tempquoteLineItem,pdList:tempPDiscount,qdList:tempQuoteDiscount,payments:tempPayments})
            .then(result => {
                this.validationList = [];
                this.validationList = JSON.stringify(result);
                this.validationList = JSON.parse(this.validationList);
                if(this.validationList.length == 0){
                    cloneQuote({q:tempQuoteRecord,lineItems:tempquoteLineItem,pdList:tempPDiscount,qdList:tempQuoteDiscount,payments:tempPayments,otherItem:tempOtherItems})
                        .then(res => {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Quote Created Successfully!',
                                    variant: 'success'
                                })
                                
                            );
                            this.newQuoteId = res;
                            saveQuotePDF({
                                shcId: this.newQuoteId,
                                objName: 'Quote'
                            }).then(resul => {
                                console.log('Inside file SAVE:: '+resul);
                                this.isSave = true;
                                this.showSpinner = false;
                                
                            }).catch(error => {
                                console.log('Inside file error: '+ JSON.stringify(error))
                                this.showSpinner = false;
                            })

                        })
                        .catch(error => {
                            console.log('Errorured in Clone method:- '+error);
                            this.showSpinner = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Quote Creation Failed: '+error,
                                    variant: 'error'
                                })
                                
                            );
                        });
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please complete below details.',
                            variant: 'error'
                        })
                        
                    );
                    this.showSpinner = false;
                }
            })
            .catch(error => {
                console.log('Errorured in validateQuote method:- '+error);
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Quote Creation Failed.',
                        variant: 'error'
                    })
                    
                );
            });
    }

    cancelQuote(){
        this.dispatchEvent(new CustomEvent('close'));
     }


}