import { LightningElement,api,track,wire } from 'lwc';
import addOtherCharge from '@salesforce/apex/Quotation.addOtherCharge';
import deleteOtherCharge from '@salesforce/apex/Quotation.deleteOtherCharge';
export default class OtherChargeLWC extends LightningElement {
    @track otherChargeRecord;
    @api otherChargeAdded;
    @track producName;
    @track productId;

    @api
    calledFromParent() {
      //alert('inside other charge lwc::'+this.otherChargeAdded);
        if(!this.otherChargeAdded){
            addOtherCharge({qId:null})
            .then(result => {
                //this.otherChargeRecord = result;
                this.otherChargeRecord = JSON.stringify(result);
                this.otherChargeRecord = JSON.parse(this.otherChargeRecord);
                var istrue=true;
                this.productId = this.otherChargeRecord.productId;
                this.productName = this.otherChargeRecord.productName;
                const selectedEvent = new CustomEvent("otherchargeadded", {
                  detail: istrue
                  });
                  // Dispatches the event.
                  this.dispatchEvent(selectedEvent);
            })
            .catch(error => {
                console.log('Errorured in addOtherCharge method:- '+error);
            });
        }
        
    }
    //@track selectedProduct;
    //@track productSelected = false;

    deleteFromParent() {
      //alert('hi');
     /* this.otherChargeRecord.area = null;
      this.otherChargeRecord.price = null;
      this.otherChargeRecord.productId = null;
      this.otherChargeRecord.remarks = null;
      this.otherChargeRecord.pricingModal = null;*/
      let tempRecord= JSON.stringify(this.otherChargeRecord);
      deleteOtherCharge({OCRecord:tempRecord})
          .then(result => {
              //this.otherChargeRecord = result;
              this.otherChargeRecord = JSON.stringify(result.quoteItem);
              this.otherChargeRecord = JSON.parse(this.otherChargeRecord);
              const selectedEvent2 = new CustomEvent("otherchargeadded", {
                detail: false
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent2);
          })
          .catch(error => {
              console.log('Errorured in deleteOtherCharge method:- '+error);
          });
      //alert('value::'+this.otherChargeRecord.area);
    }

    areaChange(event){
        console.log('area::'+event.target.value);
        this.otherChargeRecord.area = event.target.value;
        //alert(this.quoteLineItemRecordList[seq].area);
      }
      priceChange(event){
        console.log('Price::'+event.target.value);
        this.otherChargeRecord.price = event.target.value;
      }
      productChange(event){
        console.log('product::'+event.target.value);
        this.otherChargeRecord.productId = event.target.value;
        //this.selectedProduct = event.target.value;
       // if(this.selectedProduct != null && this.selectedProduct != undefined){
        //  this.productSelected = true;
        //}
        
      }
      remarksChange(event){
        console.log('Remarks::'+event.target.value);
        this.otherChargeRecord.remarks = event.target.value;
      }
      productModelChange(event){
        console.log('Product modal::'+event.target.value);
        this.otherChargeRecord.pricingModal = event.target.value;
      }
      quantityChange(event){
        console.log('Quantity::'+event.target.value);
        this.otherChargeRecord.quantity = event.target.value;
      }

      @api
      getList() {
        //alert(this.otherChargeRecord);
          return this.otherChargeRecord;
      }

}