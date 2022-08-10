import { LightningElement,api,track,wire } from 'lwc';
//import getOpportunity from '@salesforce/apex/Quotation.getOpportunity';
import getRoomValues from '@salesforce/apex/Quotation.getRoomValues';
import getSurfaceValues from '@salesforce/apex/Quotation.getSurfaceValues';
import addRoom from '@salesforce/apex/Quotation.addRoom';
import saveQuote from '@salesforce/apex/Quotation.saveQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSiteHealthCardRecord from '@salesforce/apex/Quotation.getSiteHealthCardRecord';
import getRecommendationList from '@salesforce/apex/Quotation.getRecommendationList';
import getDealerList from '@salesforce/apex/Quotation.getDealerList';
import getProductOptions from '@salesforce/apex/Quotation.getProductOptions';
import saveQuotePDF from '@salesforce/apex/SharePanelGlobal.savePDF'
import getMaskingCharge from '@salesforce/apex/Quotation.getMaskingCharge';
import addOtherCharge from '@salesforce/apex/Quotation.addOtherCharge';


let i=0;
export default class Quotation_LWC extends LightningElement {
@api recordId;
@api siteHealthCardId;
@track opportunity;
@track siteHealthCard;
@track roomValues = [];
@track surfaceValues = [];
@track quoteLineItemList = [];
@track isShowModal = false;
@track selectedRoom;
@track quoteLineItemListFromChild = [];
@track productDiscountList = [];
@track quoteLevelDiscountList = [];
@track otherChargeRecord;
@track paymentDetailList = [];
@track noLineItem = false;
@track RecommendationList = [];
@track isSave = false;
@track mandatoryProductMsg;
@track quoteId;
@track dealerMissing = false;
@track dealerList = [];
@track issueInDealerListMethod = false;
@track dealerErrorMsg = '';
@track selectedDealer;
@track expirationDate;
@track showSpinner =false

//////// Get siteHealthCard Details

dateInternal
  connectedCallback() {
    var today = new Date();
    today.setDate(today.getDate() +1);
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
    var yyyy = today.getFullYear();
    today = mm + "/" + dd + "/" + yyyy;
    today = yyyy + "-" + mm + "-" + dd;
    this.dateInternal  = today;
    }

@wire(getSiteHealthCardRecord, {shcId:'$recordId' })
getSiteHealthCardRecord({data, error}){
    if(data){
        this.siteHealthCard = JSON.stringify(data);
        this.siteHealthCard = JSON.parse(this.siteHealthCard);
        if(this.siteHealthCard.Opportunity__r.Dealer__c != null && this.siteHealthCard.Opportunity__r.Dealer__c != undefined){
            this.selectedDealer = this.siteHealthCard.Opportunity__r.Dealer__c;
        }else{
            this.dealerMissing = true;
            getDealerList({optyOwner:this.siteHealthCard.Opportunity__r.OwnerId})
            .then(result => {
                if(result.length > 0){
                    if(result[0].noDealer){
                        this.issueInDealerListMethod = true;
                        this.dealerErrorMsg = result[0].message;
                    }
                }
                if(!this.issueInDealerListMethod){
                    for( i=0; i<result.length; i++) {
                        this.dealerList = [...this.dealerList ,{value: result[i].dealerId, label: result[i].dealerName}];                                  
                    }
                }
                
            })
            .catch(error => {
                console.log('Errorured in dealerList method:- '+error);
            });
        }
        getRecommendationList({shcId:this.siteHealthCard.Id})
            .then(result => {
                this.RecommendationList = JSON.stringify(result);
                this.RecommendationList = JSON.parse(this.RecommendationList);
                
            })
            .catch(error => {
                console.log('Errorured in RecommendationList method:- '+error);
            });
          
            const dt = new Date();
            dt.setDate(dt.getDate() + 30);
            var month = dt.getUTCMonth() + 1; //months from 1-12
            var day = dt.getUTCDate();
            var year = dt.getUTCFullYear();
            if(month.toString().length < 2){
                month = '0' + month;
            }
            if(day.toString().length < 2){
                day = '0' + day;
            }
            var newdate = year + "-" + month + "-" + day;
            this.expirationDate = newdate;
        
        
            //alert('exp::'+newdate);
    }else if (error) {
        this.error = error;
    }
}


//////// Get opportunity Details
/*@wire(getOpportunity, {oId:'$recordId' })
getOpportunity({data, error}){
    if(data){
        this.opportunity = JSON.stringify(data);
        this.opportunity = JSON.parse(this.opportunity);
    }else if (error) {
        this.error = error;
    }
}  */

//////// Get Room Values
@wire(getRoomValues, {})
getRoomValues({data, error}){
    if(data){
        for( i=0; i<data.length; i++) {
        this.roomValues = [...this.roomValues ,{value: data[i], label: data[i]}];                                  
        }
    }else if (error) {
        this.error = error;
    }
} 

//////// Get Surface Details and Masking charge details
//@track maskingChargeList = [];
@track maskingProductId;
@track mechanisedProductId;
@track maskingKitCharge;
@track mechanisedCharge;

@wire(getSurfaceValues, {})
getSurfaceValues({data, error}){
    if(data){
        for( i=0; i<data.length; i++) {
        this.surfaceValues = [...this.surfaceValues ,{value: data[i], label: data[i]}];                                  
        }
    
        getMaskingCharge({})
        .then(result => {
            
            for(i=0;i<result.length;i++){
                if(result[i].Masking_Charge__c){
                    this.maskingProductId = result[i].Id;
                }
                if(result[i].Mechanised_Charge__c){
                    this.mechanisedProductId = result[i].Id;
                }
            }
        })
        .catch(error => {
            console.log('Errorured in maskingChargeList method:- '+error);
        });

        addOtherCharge({})
            .then(result => {
                //this.otherChargeRecord = result;
                this.maskingKitCharge = JSON.stringify(result);
                this.maskingKitCharge = JSON.parse(this.maskingKitCharge);
            })
            .catch(error => {
                console.log('Errorured in addmaskingCharge method:- '+error);
            });

        addOtherCharge({})
            .then(result => {
                //this.otherChargeRecord = result;
                this.mechanisedCharge = JSON.stringify(result);
                this.mechanisedCharge = JSON.parse(this.mechanisedCharge);
            })
            .catch(error => {
                console.log('Errorured in addmechanisedCharge method:- '+error);
            });
    }else if (error) {
        this.error = error;
    }
} 

addRoom(event){
   
    let tempRecord = JSON.stringify(this.quoteLineItemList);
    addRoom({existingRoomList:tempRecord, selectedRoom:this.selectedRoom})
    .then(result => {
        this.quoteLineItemList = JSON.stringify(result);
        this.quoteLineItemList = JSON.parse(this.quoteLineItemList);
        
        this.noLineItem = false;
    })
    .catch(error => {
        console.log('Errorured in addRoom method:- '+error);
    }); 
}

showModalBox() { 
    this.isShowModal = true;
    this.selectedRoom = null;
    
}

hideModalBox() { 
    this.isShowModal = false;
}

get roomOptions(){
    return this.roomValues;
}

selectRoom(event){
    const selectedOption = event.detail.value;
    this.selectedRoom = selectedOption;
    
    this.isShowModal = false;
    this.addRoom();
}
@track surfaceLWCItems=[];
@track item_Size;
quoteItemsFromSurfaceLWC(event){
    // alert(event.detail);
    this.surfaceLWCItems.push(event.detail);
    
    this.item_Size = this.surfaceLWCItems.length;
    //alert('list::'+this.surfaceLWCItems.length);
    if(this.surfaceLWCItems.length > 0){
        this.progressValue = true;
        this.surfaceAdded = true;
    }else{
        this.progressValue = false;
        this.surfaceAdded = false;
    }
}

childValues(event){
    //alert('inside parent');
    /*const objChild = this.template.querySelector('c-surface-Child-L-W-C');
    this.quoteLineItemListFromChild = objChild.passToParent();
    console.log('list in parent:: '+this.quoteLineItemListFromChild.length);*/
    const objDiscountLWC = this.template.querySelector('c-Product-Discount-L-W-C');
    //objDiscountLWC.quoteLineItemRecordList = this.quoteLineItemListFromChild;
    objDiscountLWC.calledFromParent();
    this.handleSetActiveSectionProductLevel();
}

@track progressValue = false;
/* hanldeProgressValueChange(event) {
    this.progressValue = event.detail;
    //alert('inside parent::'+this.progressValue);
}*/

@track surfaceAdded = false;
/*handleSurfaceValueChange(event){
    this.surfaceAdded = event.detail;
}*/

@track productIds=[];
@track proIds=[];
handleProductList(event){
    this.productIds = [];
    this.productIds = this.surfaceLWCItems;
    console.log('productIds::'+this.productIds);

    let pIds = [];
    for(var i=0;i<this.productIds.length;i++){
        pIds.push(this.productIds[i].productId);
    }
    console.log('productIds---Length::'+pIds.length);
    this.proIds = [];
    if(pIds.length > 0){
        let tempIds = JSON.stringify(pIds);
        getProductOptions({productIds:tempIds})
        .then(result => {
            if(result.length > 0){
                for(var j=0;j<result.length;j++){
                    this.proIds = [...this.proIds ,{value: result[j].Id, label: result[j].Name}];
                } 
                console.log('proIds::'+this.proIds.length);
            }               
        })
        .catch(error => {
            console.log('Errorured in getProductDiscountList method:- '+error);
        });
    }
}

quoteLevelDiscount(event){
    const objQuoteDiscountLWC = this.template.querySelector('c-Quote-Discount-L-W-C');
    objQuoteDiscountLWC.calledFromParent();
    this.handleSetActiveSectionQuoteLevel();
}

paymentdetail(event){
    const objpaymentDetailLWC = this.template.querySelector('c-payment-Detail-L-W-C');
    objpaymentDetailLWC.calledFromParent();
    this.handleSetActiveSectionPaymentDetailLevel();
}

callOtherCharge(event){
    //alert('hi');
    const objOtherChargeLWC = this.template.querySelector('c-other-Charge-L-W-C');
    objOtherChargeLWC.calledFromParent();
    
}

handleSetActiveSectionQuoteLevel() {
    const accordion = this.template.querySelector('.quote-discount-accordion');
    accordion.activeSectionName = 'Quote Level Discount';
}

handleSetActiveSectionProductLevel() {
    const accordion = this.template.querySelector('.product-discount-accordion');
    accordion.activeSectionName = 'Product Level Discount';
}

handleSetActiveSectionPaymentDetailLevel() {
    const accordion = this.template.querySelector('.payment-details-accordion');
    accordion.activeSectionName = 'Payment Detail';
}
@track isOtherChargeAdded = false;
handleOtherChargeEvent(event){
    //alert(event.detail);
    this.isOtherChargeAdded = event.detail;
}

@track area;
totalAreaSqft(event){
    
    this.area = event.target.value;
}

@track bhk;
totalBHK(event){
    
    this.bhk = event.target.value;
}

@track gender;
genderSelect(event){
    
    this.gender = event.target.value;
}

@track ageBand;
ageBandSelect(event){
   
    this.ageBand = event.target.value;
}

@track maritalStatus;
maritalStatusSelect(event){
    
    this.maritalStatus = event.target.value;
}

@track profession;
professionSelect(event){
    
    this.profession = event.target.value;
}

@track familyType;
familytypeSelect(event){
    
    this.familyType = event.target.value;
}

@track kids;
kidsSelect(event){
    
    this.kids = event.target.value;
}

@track quoteName;
fetchQuoteName(event){
   
    this.quoteName = event.target.value;
}

@track tier;
@track isTier = false;
tierChange(event){
    
    this.tier = event.target.value;
    if(this.tier == 'Platinum' || this.tier == 'Gold'){
        this.isTier = true;
    }else{
        this.isTier = false;
    }
    console.log('tier value-->'+this.tier);
}

@track numberOfPainter;
numberOfPainterChange(event){
   
    
    this.numberOfPainter = event.target.value;
    
}

@track areaAppliedPerPainter;
areaAppliedPerPainterChange(event){
    
    this.areaAppliedPerPainter = event.target.value;
}

@track siteType;
siteTypeChange(event){
    console.log('siteType::'+event.target.value);
    this.siteType = event.target.value;
}

@track bufferTime;
bufferTimeChange(event){
    console.log('bufferTime::'+event.target.value);
    this.bufferTime = event.target.value;
}

@track newServices;
newServiceseChange(event){
    console.log('newServices::'+event.target.value);
    this.newServices = event.target.value;
}
dealerChange(event){
    console.log('dealer::'+event.target.value);
    this.selectedDealer = event.target.value;
}
expirationDateChange(event){
    console.log('expirationDate::'+event.target.value);
    this.expirationDate = event.target.value;
    
}

areaChange(event){
    console.log('areachange::'+event.target.value);
    var chargeName = event.target.dataset.id;
    console.log('chargeName:: '+chargeName);
    if(chargeName == 'MaskingCharge'){
        this.maskingKitCharge.area = event.target.value;
        this.maskingKitCharge.productId = this.maskingProductId;
    }else{
        this.mechanisedCharge.area = event.target.value;
        this.mechanisedCharge.productId = this.mechanisedProductId;
    }
    
}

productModelChange(event){
    console.log('productModal::'+event.target.value);
    var chargeName = event.target.dataset.id;
    console.log('chargeName:: '+chargeName);
    if(chargeName == 'MaskingCharge'){
        this.maskingKitCharge.pricingModal = event.target.value;
    }else{
        this.mechanisedCharge.pricingModal = event.target.value;
    }
}

priceChange(event){
    console.log('pricechange::'+event.target.value);
    var chargeName = event.target.dataset.id;
    console.log('chargeName:: '+chargeName);
    if(chargeName == 'MaskingCharge'){
        this.maskingKitCharge.price = event.target.value;
        this.maskingKitCharge.productId = this.maskingProductId;
    }else{
        this.mechanisedCharge.price = event.target.value;
        this.mechanisedCharge.productId = this.mechanisedProductId;
    }
}

quantityChange(event){
    console.log('quantity::'+event.target.value);
    var chargeName = event.target.dataset.id;
    console.log('chargeName:: '+chargeName);
    if(chargeName == 'MaskingCharge'){
        this.maskingKitCharge.quantity = event.target.value;
    }else{
        this.mechanisedCharge.quantity = event.target.value;
    }
}

remarksChange(event){
    console.log('remarks::'+event.target.value);
    var chargeName = event.target.dataset.id;
    console.log('chargeName:: '+chargeName);
    if(chargeName == 'MaskingCharge'){
        this.maskingKitCharge.remarks = event.target.value;
    }else{
        this.mechanisedCharge.remarks = event.target.value;
    }
}

areaChangeFromSurfaceLWC(event){
    
    var sq = event.detail.seq;
    var value = event.detail.value;
    this.surfaceLWCItems[sq].area = value;
    //alert(this.surfaceLWCItems[sq].area);
}

priceChangeFromSurfaceLWC(event){
    var sq = event.detail.seq;
    var value = event.detail.value;
    this.surfaceLWCItems[sq].price = value;
}

productChangeFromSurfaceLWC(event){
    var sq = event.detail.seq;
    var value = event.detail.value;
   
    this.surfaceLWCItems[sq].productId = value;
    this.surfaceLWCItems[sq].service = event.detail.service
    console.log('in parent handler :'+ JSON.stringify(this.surfaceLWCItems))
}

remarksChangeFromSurfaceLWC(event){
    var sq = event.detail.seq;
    var value = event.detail.value;
    this.surfaceLWCItems[sq].remarks = value;
}

pricingModalChangeFromSurfaceLWC(event){
    var sq = event.detail.seq;
    var value = event.detail.value;
    this.surfaceLWCItems[sq].pricingModal = value;
}

quantityChangeFromSurfaceLWC(event){
    var sq = event.detail.seq;
    var value = event.detail.value;
    this.surfaceLWCItems[sq].quantity = value;
}

handleUpperProductChange(event){        
    var sq = event.detail.seq;
    var value = event.detail.value;
    this.surfaceLWCItems[sq].upperProducts = value;
    
}


cancelQuote(){
    this.dispatchEvent(new CustomEvent('close'));
}

saveQuote(){
    var isValid = true;
            
  
            if(this.isTier && (this.maskingKitCharge.area == undefined || this.maskingKitCharge.price == undefined || this.maskingKitCharge.undefined)){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Add Masking charge details for Platinum/Gold Tier.',
                        variant: 'error'
                    })
                    
                );
                return;
            }
            else if(this.isTier && this.maskingKitCharge.price > 9999999.99){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Masking Kit Price cannot exceed Rs 99,99,999',
                        variant: 'error'
                    })
                    );
                    return;
            }
            else if(this.isTier && (this.mechanisedCharge.area == undefined || this.mechanisedCharge.price == undefined || this.mechanisedCharge.undefined)){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Add Mechanised charge details for Platinum/Gold Tier.',
                        variant: 'error'
                    })
                    
                );
                return;
            }
            else if(this.isTier && this.mechanisedCharge.price > 9999999.99){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Mechanised Charge Price cannot exceed Rs 99,99,999',
                        variant: 'error'
                    })
                    );
                    return;
            }

            
        

    ////////////////// Lightning input fields validation ////////////////////
this.template.querySelectorAll('lightning-input-field').forEach(element => {
        //alert('val::'+element.reportValidity());
        if(!element.reportValidity()){
            isValid = false;
        }
    });
    //////////////////////////Mechanised Charge & Masking Charge Validation ////////////////////////
   
    /////////////////////Dealer validation ///////////////////////////////////
    if(this.selectedDealer != null && this.selectedDealer != undefined){

    } else{
        isValid = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please Select Dealer',
                variant: 'error'
            })
            
        );
    }
    ///////////////////Expiration Date Validation ////////////////////////
    
    if(this.expirationDate != null && this.expirationDate != undefined){
       if(this.expirationDate < this.dateInternal){
        isValid = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please Select a Future Expiration Date',
                variant: 'error'
            })
            
        );

       }

    } else{
        isValid = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please Select Expiration Date',
                variant: 'error'
            })
            
        );
    }
    
        
    if(isValid){
        //////////////Number of Rooms/////////////////////////
        if(this.quoteLineItemList.length == 0){
            isValid = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Atleast one Room should be added to save the quote',
                    variant: 'error'
                })
                
            );
        }else{
            this.productDiscountList = [];
            this.quoteLevelDiscountList = [];
            this.otherChargeRecord = null;
            this.paymentDetailList = [];
            //let quoteItems = [];
            //const objChild = this.template.querySelector('c-surface-Child-L-W-C');
            //quoteItems = objChild.passToParent();
            //alert('inside save sureface line item:: '+quoteItems.length);
            //alert(this.surfaceLWCItems.length);
            
            if(this.surfaceLWCItems.length == 0){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'There is no surface added. Please add Surface under selected Room',
                        variant: 'error'
                    })
                    
                );
            }
            else{
                console.log("surface lwc items :"+ JSON.stringify(this.surfaceLWCItems))
                if(this.surfaceLWCItems !== undefined){
                    for(var q=0;q<this.surfaceLWCItems.length;q++){
                        console.log(this.surfaceLWCItems[q])
                        if(this.surfaceLWCItems[q].productId === undefined || this.surfaceLWCItems[q].productId === null || 
                            this.surfaceLWCItems[q].area === undefined || this.surfaceLWCItems[q].area === "" || this.surfaceLWCItems[q].price === undefined || this.surfaceLWCItems[q].price === ""
                            || this.surfaceLWCItems[q].quantity === undefined || this.surfaceLWCItems[q].quantity === ""){
                                this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Required details missing for Room: '+ this.surfaceLWCItems[q].room +' Surface: ' + this.surfaceLWCItems[q].surface,
                                    variant: 'error'
                                })
                                );
                                return;
                        }
                        else if(this.surfaceLWCItems[q].price > 9999999.99){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Price cannot exceed Rs 99,99,999 for Room: '+ this.surfaceLWCItems[q].room +' Surface: ' + this.surfaceLWCItems[q].surface,
                                    variant: 'error'
                                })
                                );
                                return;
                        }
                        else if(this.surfaceLWCItems[q].price <0){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Price cannot be negative for Room: '+ this.surfaceLWCItems[q].room +' Surface: ' + this.surfaceLWCItems[q].surface,
                                    variant: 'error'
                                })
                                );
                                return;
                        }
                        else if(this.surfaceLWCItems[q].area <0){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Area cannot be negative for Room: '+ this.surfaceLWCItems[q].room +' Surface: ' + this.surfaceLWCItems[q].surface,
                                    variant: 'error'
                                })
                                );
                                return;
                        }
                    }
                }
                if(this.template.querySelector('c-Product-Discount-L-W-C') != null && this.template.querySelector('c-Product-Discount-L-W-C') != undefined){
                    const productDiscountLWC = this.template.querySelector('c-Product-Discount-L-W-C');
                    this.productDiscountList = productDiscountLWC.getList();
                    console.log('inside save product discount List:: '+this.productDiscountList.length);
                }
                //alert('hi::');
                const quoteLevelDiscountLWC = this.template.querySelector('c-Quote-Discount-L-W-C');
                this.quoteLevelDiscountList = quoteLevelDiscountLWC.getList();
                console.log('inside save quote level discount List:: '+this.quoteLevelDiscountList.length);

                const otherchargeLWC = this.template.querySelector('c-other-Charge-L-W-C');
                this.otherChargeRecord = otherchargeLWC.getList();
                console.log('inside save other charge Record:: '+this.otherChargeRecord);

                if(this.otherChargeRecord !== undefined && this.otherChargeRecord.price !== undefined && this.otherChargeRecord.price > 9999999.99){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Other Charges Price cannot exceed Rs 99,99,999',
                            variant: 'error'
                        })
                        );
                        return;
                }
                const paymentDetailLWC = this.template.querySelector('c-payment-Detail-L-W-C');
                this.paymentDetailList = paymentDetailLWC.getList();
                var total_perc = paymentDetailLWC.getPercentage();
                console.log('inside save payment Detail List:: '+this.paymentDetailList.length);
                if(this.paymentDetailList.length == 0){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please add the payment details.',
                            variant: 'error'
                        })
                        
                    );
                }else if (this.kids !=null && this.kids !=undefined && this.kids>2){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Maximum number of kids can be 2',
                            variant: 'error'
                        })
                        
                    );
                }
                /*else if (this.numberOfPainter !=null && this.numberOfPainter !=undefined && this.numberOfPainter>2){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Maximum number of painters can be 2',
                            variant: 'error'
                        })
                        
                    );
                    
                }*/
                else if (this.bufferTime !=null && this.bufferTime !=undefined && this.bufferTime > 50){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Buffer time cannot be greater than 50%',
                            variant: 'error'
                        })
                        
                    );
                    
                }else if(total_perc != 100){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Payment details percentage should be 100%.',
                            variant: 'error'
                        })
                        
                    );
                }else{
                    this.showSpinner =true
                    let fieldList=[];
                    fieldList.push({label: 'area', value:this.area});
                    fieldList.push({label: 'bhk', value:this.bhk});
                    fieldList.push({label: 'gender', value:this.gender});
                    fieldList.push({label: 'ageBand', value:this.ageBand});
                    fieldList.push({label: 'maritalStatus', value:this.maritalStatus});
                    fieldList.push({label: 'profession', value:this.profession});
                    fieldList.push({label: 'familyType', value:this.familyType});
                    fieldList.push({label: 'kids', value:this.kids});
                    fieldList.push({label: 'quoteName', value:this.quoteName});
                    fieldList.push({label: 'tier', value:this.tier});
                    fieldList.push({label: 'numberOfPainter', value:this.numberOfPainter});
                    fieldList.push({label: 'areaAppliedPerPainter', value:this.areaAppliedPerPainter});
                    fieldList.push({label: 'siteType', value:this.siteType});
                    fieldList.push({label: 'bufferTime', value:this.bufferTime});
                    fieldList.push({label: 'newServices', value:this.newServices});
                    fieldList.push({label: 'selectedDealer', value:this.selectedDealer});
                    fieldList.push({label: 'expirationDate', value:this.expirationDate});

                    let tempquoteLineItem = JSON.stringify(this.surfaceLWCItems);
                    let tempproductdiscount = JSON.stringify(this.productDiscountList);
                    let tempquotelevelDiscount = JSON.stringify(this.quoteLevelDiscountList);
                    let tempOtherCharge = JSON.stringify(this.otherChargeRecord);
                    let temppaymentDetail = JSON.stringify(this.paymentDetailList);
                    fieldList = JSON.stringify(fieldList);
                    let tempSHC = JSON.stringify(this.siteHealthCard);
                    let tempMaskingCharge = JSON.stringify(this.maskingKitCharge);
                    let tempMechanisedCharge = JSON.stringify(this.mechanisedCharge);
                    //alert('hi');
                    
                    saveQuote({quoteLineItemList:tempquoteLineItem, productdiscountList:tempproductdiscount,quoteLeveldiscountList:tempquotelevelDiscount,
                                otherchargeList:tempOtherCharge,paymentDetailsList:temppaymentDetail,fieldset:fieldList,shc:tempSHC,
                                maskingCharge:tempMaskingCharge, mechanisedCharge:tempMechanisedCharge})
                    .then(result => {
                       
                        console.log('result::'+result.length);
                        if(result.length > 18){
                            this.showSpinner =false
                            this.mandatoryProductMsg = result;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message:'Mandatory Products are missing',
                                    variant: 'error'
                                })
                                
                            );
                        }else{
                           
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Quote Created Successfully!',
                                    variant: 'success'
                                })
                                
                            );
                            this.quoteId = result;
                            saveQuotePDF({
                                shcId: this.quoteId,
                                objName: 'Quote'
                            }).then(result => {
                                console.log('Inside file SAVE:: '+result);
                                
                                this.mandatoryProductMsg = null;
                                this.isSave = true;
                                this.showSpinner =false
                            }).catch(error => {
                                console.log('Inside file error: '+ JSON.stringify(error))
                                this.showSpinner =false
                            })
                        }
                        
                    })
                    .catch(error => {
                        this.showSpinner =false
                        console.log('Error occurred in SaveQuote method:- '+ JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Quote Creation Failed.',
                                variant: 'error'
                            })
                            
                        );
                    });
                }
            }
        }
    }else{
        if(this.quoteName != null && this.quoteName != undefined){
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter Quote Name.',
                    variant: 'error'
                })
                
            );
        }

        if(this.tier != null && this.tier != undefined){
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select Tier.',
                    variant: 'error'
                })
                
            );
        }

        if(this.newServices != null && this.newServices != undefined){
        }else{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select New Services.',
                    variant: 'error'
                })
                
            );
        }

        if(this.isTier && this.maskingKitCharge.productId == undefined){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Masking charge details not available in the Product table.',
                    variant: 'error'
                })
                
            );
        }else{
            if(this.isTier && (this.maskingKitCharge.area == undefined || this.maskingKitCharge.price == undefined || this.maskingKitCharge.undefined)){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Add Masking charge details for Platinum/Gold Tier.',
                        variant: 'error'
                    })
                    
                );
            }
        }

        if(this.isTier && this.mechanisedCharge.productId == undefined){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Mechanised charge details not available in the Product table.',
                    variant: 'error'
                })
                
            );
        }else{
            if(this.isTier && (this.mechanisedCharge.area == undefined || this.mechanisedCharge.price == undefined || this.mechanisedCharge.undefined)){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Add Mechanised charge details for Platinum/Gold Tier.',
                        variant: 'error'
                    })
                    
                );
            }
        }
        
        
    }
}

deleteRoom(event){
    console.log('seq::'+event.target.dataset.id);
    console.log('Before delete quotelineItem '+JSON.stringify(this.quoteLineItemList))
    var seq = event.target.dataset.id;
     ///////////////////////////////
//    let elements = this.template.querySelectorAll("c-surface-Child-L-W-C")
//         for (let i = 0; i < elements.length; i++) {
//             try{
//             let x = elements[i].qNumber()
//             console.log('in parent qNumber ' +x +' sequ '+ seq)
//            if (x == seq) {
//                elements[i].deleteSurfaces();
//                break;
//             }
//         }
//         catch(e){
//             console.log(e.message)
//         }
//         } 
    //////////////////////////////////// 
    var index;
    for(var q=0;q<this.quoteLineItemList.length;q++){
        if(this.quoteLineItemList[q].sequence == seq){
            //alert('ddd: '+this.quoteLineItemList.indexOf(this.quoteLineItemList[q]));
            index = this.quoteLineItemList.indexOf(this.quoteLineItemList[q]);
        }
    }
    
    this.quoteLineItemList.splice(index,1);
    
    if(this.quoteLineItemList.length == 0){
        this.noLineItem = true;
    }
    
    console.log('After delete quotelineItem '+JSON.stringify(this.quoteLineItemList))
   
    }
    ///////////////////////////
    // deleteMultipleSurfaceItems(event){
    //     var sq = event.detail.value;
    // }
    ///////////////////////////
    deleteItemsFromSurfaceLWC(event){
        console.log('Before delete surfaceLwc '+JSON.stringify(this.surfaceLWCItems))
   
        var sq = event.detail.value;
        console.log('Delete surface sequence no '+sq)
        var index;
        //alert(this.surfaceLWCItems.length);
        for(var q=0;q<this.surfaceLWCItems.length;q++){
            if(this.surfaceLWCItems[q].sequence == sq){
                index = this.surfaceLWCItems.indexOf(this.surfaceLWCItems[q]);
            }
        }
        this.surfaceLWCItems.splice(index,1);
        for(var q=0;q<this.surfaceLWCItems.length;q++){
            this.surfaceLWCItems[q].sequence = q;
        }
        this.item_Size = this.surfaceLWCItems.length;
        if(this.surfaceLWCItems.length > 0){
            this.progressValue = true;
            this.surfaceAdded = true;
        }else{
            this.progressValue = false;
            this.surfaceAdded = false;
        }
        console.log('After delete surfaceLwc '+JSON.stringify(this.surfaceLWCItems))
   
        //alert('hh');
    }


}