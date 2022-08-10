import { LightningElement,api,track,wire } from 'lwc';
import getQuoteLevelDiscountList from '@salesforce/apex/Quotation.getQuoteLevelDiscountList';

export default class QuoteDiscountLWC extends LightningElement {
    @track discountList = [];
    @track discountTypeList = [];

    @api
      calledFromParent() {
         console.log('inside quote level discount LWC');
         let tempRecord = JSON.stringify(this.discountList);
         getQuoteLevelDiscountList({dList:tempRecord})
          .then(result => {
              this.discountList = JSON.stringify(result);
              this.discountList = JSON.parse(this.discountList);
              console.log('discountList in quote Level discount::'+this.discountList.length);
              this.discountTypeList = [];
              this.discountTypeList = [...this.discountTypeList ,{value: 'Percentage', label: '%'}];
              this.discountTypeList = [...this.discountTypeList ,{value: 'Amount', label: '₹'}];
              
          })
          .catch(error => {
              console.log('Errorured in getQuoteLevelDiscountList method:- '+error);
          }); 
      }

      discountNameSelect(event){
        console.log('Discount Name select::'+event.target.value);
        var seq = event.target.dataset.id;
        this.discountList[seq].discountName = event.target.value;
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