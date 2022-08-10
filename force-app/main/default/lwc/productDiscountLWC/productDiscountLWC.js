import { LightningElement,api,track,wire } from 'lwc';
import getProductDiscountList from '@salesforce/apex/Quotation.getProductDiscountList';

export default class ProductDiscountLWC extends LightningElement {
    @api quoteLineItemRecordList = [];
    @track discountList = [];
    @api productList = [];
    @track discountTypeList = [];

    @api
      calledFromParent() {
        //alert('inside child:'+this.quoteLineItemRecordList.length);
        console.log( 'quoteLineItemRecordList in product discount:' + this.quoteLineItemRecordList.length);
        
            let tempRecord = JSON.stringify(this.discountList);
            getProductDiscountList({pList:tempRecord})
            .then(result => {
                this.discountList = JSON.stringify(result);
                this.discountList = JSON.parse(this.discountList);
                console.log('discountList::'+this.discountList.length);
                this.discountTypeList = [];
                this.discountTypeList = [...this.discountTypeList ,{value: 'Percentage', label: '%'}];
                this.discountTypeList = [...this.discountTypeList ,{value: 'Amount', label: '₹'}];
                
            })
            .catch(error => {
                console.log('Errorured in getProductDiscountList method:- '+error);
            }); 
        
     }

     productselect(event){
        console.log('Product select::'+event.target.value);
        var seq = event.target.dataset.id;
        this.discountList[seq].selectedProduct = event.target.value;
     }

     discountTypeselect(event){
        console.log('discount type select::'+event.target.value);
        var seq = event.target.dataset.id;
        this.discountList[seq].discountType = event.target.value;
     }

     discountAmountSelect(event){
        console.log('discount value select::'+event.target.value);
        var seq = event.target.dataset.id;
        this.discountList[seq].discountPrice = event.target.value;
     }

     @api
      getList() {
          return this.discountList;
      }

    deleteDiscount(event){
        console.log('seq::'+event.target.dataset.id);
        var seq = event.target.dataset.id;
        var index;
            for(var q=0;q<this.discountList.length;q++){
                if(this.discountList[q].sequence == seq){
                    index = this.discountList.indexOf(this.discountList[q]);
                }
            }
        this.discountList.splice(index,1);
        if(this.discountList.length == 0){
            //this.clicktoSurface();
            //this.showButtons();
        }
    }
}