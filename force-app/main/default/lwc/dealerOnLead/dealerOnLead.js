import { LightningElement, api, track } from 'lwc';
import getDealer from '@salesforce/apex/DealerOnLeadHandler.getDealer'
import updateLead from '@salesforce/apex/DealerOnLeadHandler.updateLead'
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { getRecordNotifyChange } from 'lightning/uiRecordApi';


export default class DealerOnLead extends LightningElement {
    @api recordId
    @track value = '';
    noDealer =false;
    singleDealer = false;
    disabled = true;
    showSpinner= false;
    @track dealerOptions = []
    connectedCallback(){
        console.log('dist Selection')
        getDealer({leadId: this.recordId}).then(r =>{
           for(var key in r){
                this.dealerOptions.push({label:r[key], value:key}); 
            }
            console.log(this.dealerOptions.length)
           if(this.dealerOptions.length ===0) this.noDealer =true;
           else if(this.dealerOptions.length ===1){
               this.value = this.dealerOptions[0].value;
               this.disabled =false;
           }
            console.log(this.dealerOptions)
          
        })
    }
    get options() {
        return this.dealerOptions;
    }
    handleChange(e){
        this.value = e.detail.value
        this.disabled =false;
    }
    save(){
        this.showSpinner =true;
        updateLead({
            leadId : this.recordId,
            dealerId : this.value
        }).then(r =>{
            this.newToast('Success', 'Dealer Updated On Lead', 'success');
            getRecordNotifyChange([{recordId: this.recordId}])
           // location.reload();
            
        }).catch(e =>{
            this.newToast('Error','Unknown Error Occurred', 'error');
            console.log(JSON.stringify(e))
        }).finally(f =>{
           this.showSpinner =false;
        })
    }
    newToast(title, message, varient) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: varient,
        });
        this.dispatchEvent(evt);
    }
}