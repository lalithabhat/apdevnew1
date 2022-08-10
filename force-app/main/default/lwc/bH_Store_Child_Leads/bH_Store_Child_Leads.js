import { LightningElement, api, track, wire } from 'lwc';
///import getLeadDetails from '@salesforce/apex/BH_Store_Child_Creation.getLeadDetails'
import getleadOptions from '@salesforce/apex/BH_Store_Child_Creation.getleadOptions';
import insertLeads from '@salesforce/apex/BH_Store_Child_Creation.insertLeads'
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

export default class BH_Store_Child_Leads extends NavigationMixin(LightningElement) {
    @api recordId
    showSpinner = false
    @track wiredActivities
    @track childLeadOptions = []
    optedLead = new Set()
    @wire(getleadOptions, { recordId: '$recordId' })
    handleWire(value) {

        const { data, error } = value;
        this.wiredActivities = value; // track the provisioned value
        if (data) {
         //   console.log(' in data' + JSON.stringify(data))
            this.childLeadOptions = data

        }
        else {
            console.log(error)
        }
    }
    disabled = true

    createLeadsHandler() {
        this.showSpinner = true
        console.log('in create  handler')
        console.log(Array.from(this.optedLead))
        // try{
        insertLeads({ buList: Array.from(this.optedLead), recordId: this.recordId })
            .then(r => {

                getRecordNotifyChange([{ recordId: this.recordId }])

                this.childLeadOptions = []
                this.refreshWire()
                this.showSpinner = false
                this.optedLead.clear()
                this.showNotification('Success', 'Child Leads Created Successfully', 'success');


            }).catch(e => {
                this.showSpinner = false
                this.showNotification('Error Occurred', JSON.stringify(e.body.message) + JSON.stringify(e.body.stackTrace), 'error');
                console.log(JSON.stringify(e))
            })
        // }
        //     catch(e){console.log(e)}
    }
    handleCheckbox(event) {
        // try{
        console.log(event.target.dataset.bu)
        if (event.target.checked)
            this.optedLead.add(event.target.dataset.bu)
        else
            this.optedLead.delete(event.target.dataset.bu)

        if (this.optedLead.size == 0)
            this.disabled = true
        else this.disabled = false
        console.log(this.optedLead)
        // }
        // catch(e){console.log(e)}

    }



    refreshWire() {
        this.showSpinner = true
        refreshApex(this.wiredActivities)
            .then(r => {
                console.log('in refresh')
               // console.log(JSON.stringify(this.wiredActivities.data))
               let  wireData = JSON.parse(JSON.stringify(this.wiredActivities))
               console.log(wireData)
               try{
               // if (wireData.data) {
                   // console.log(' in data' + JSON.stringify(wireData.data))
                    this.childLeadOptions = wireData.data
                    console.log(this.childLeadOptions)
               }
               catch(e){console.log(e)}
                // }
                // else {
                //    // console.log(error)
                // }
                this.showSpinner = false

            })
            .catch(e => {

                this.showSpinner = false
            })
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}