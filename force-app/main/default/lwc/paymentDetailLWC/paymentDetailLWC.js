import { LightningElement,api,track,wire } from 'lwc';
import getPaymentDetailList from '@salesforce/apex/Quotation.getPaymentDetailList';

export default class PaymentDetailLWC extends LightningElement {
    @track paymentDetailList = [];
    @track percentage_added = 0;
    @track percentageCSS = 'redColor';
    @track isListEmpty = true;

    @api
    calledFromParent() {
        let tempRecord = JSON.stringify(this.paymentDetailList);
        getPaymentDetailList({existingList:tempRecord})
          .then(result => {
              this.paymentDetailList = JSON.stringify(result);
              this.paymentDetailList = JSON.parse(this.paymentDetailList);
              console.log('paymentDetailList:: '+this.paymentDetailList.length);
              if(this.paymentDetailList.length > 0){
                  this.isListEmpty = false;
              }
              if(this.percentage_added == 100){
                 this.percentageCSS = 'greencolor';
              }else{
                 this.percentageCSS = 'redcolor';
              }
          })
          .catch(error => {
              console.log('Errorured in getPaymentDetailList method:- '+error);
          });
    }

    percentageSelect(event){
        console.log('Percentage select::'+event.target.value);
        var seq = event.target.dataset.id;
        this.paymentDetailList[seq].milestonePercentage = event.target.value;
     }

     stageSelect(event){
        console.log('stage select::'+event.target.value);
        var seq = event.target.dataset.id;
        this.paymentDetailList[seq].milestoneStage = event.target.value;
     }

     calculatePercentage(event){
         //alert('hi::'+event.target.value);
         this.percentage_added = 0;
         for(var i=0;i<this.paymentDetailList.length;i++){
            if(this.paymentDetailList[i].milestonePercentage != null && this.paymentDetailList[i].milestonePercentage != undefined){
                this.percentage_added = Number(this.percentage_added) + Number(this.paymentDetailList[i].milestonePercentage);
            }
        }
        if(this.percentage_added == 100){
           // alert('hi');
            this.percentageCSS = 'greencolor';
        }else{
            this.percentageCSS = 'redcolor';
        }
        //alert('this.percentage_added::'+this.percentage_added);
        //this.percentage_added = Number(this.percentage_added) + Number(event.target.value);
     }

     @api
      getList() {
          return this.paymentDetailList;
      }

      @api
      getPercentage() {
          return this.percentage_added;
      }

      deleteRow(event){
        console.log('seq::'+event.target.dataset.id);
        var seq = event.target.dataset.id;
        var index;
            for(var q=0;q<this.paymentDetailList.length;q++){
                if(this.paymentDetailList[q].sequence == seq){
                    index = this.paymentDetailList.indexOf(this.paymentDetailList[q]);
                }
            }
        this.paymentDetailList.splice(index,1);
        this.calculatePercentage();
        if(this.paymentDetailList.length == 0){
            this.isListEmpty = true;
        }
    }

}