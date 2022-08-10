import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import saveHealthCard from '@salesforce/apex/SharePanelGlobal.savePDF'
import sendToCustomer from '@salesforce/apex/SharePanelGlobal.sendToCustomer'
import getDocURL from '@salesforce/apex/SharePanelGlobal.getDocURL'
export default class SharePanelGlobal extends NavigationMixin(LightningElement) {
    @api objName;
    @api recordId
    contentVerionId = ''
    publicURL = ''
    downloadURL = ''
    showSpinner = false;
    @api showOpenButton = false;
    @api hidePaymentButton = false;
    @api hideQuoteApproval = false;
    errorMessage;
    isError = false;
    @api hideGoToQuote = false;
    openRecord(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {

                recordId: this.recordId,
                objectApiName: 'Quote',
                actionName: 'view',
            },

        });
    }
    connectedCallback() {

        getDocURL({ shcId: this.recordId }).then(result => {
            console.log(result)
            this.publicURL = result.publicURL;
            this.downloadURL = result.downloadURL
        }).catch(error => {
            this.errorMessage = 'Could not obtain file URL'
            this.isError =true;
           // this.newToast('Error!', 'An unexpected error occured!', 'error')
            this.showSpinner = false;
            console.log(JSON.stringify(error))
        })
    }
    @api saveFile() {
        this.showSpinner = true
        saveHealthCard({
            shcId: this.recordId,
            objName: this.objName
        }).then(result => {
            console.log(result);
            this.contentVerionId = result.contentDocumentID;
            this.publicURL = result.publicURL;
            this.downloadURL = result.downloadURL
            console.log('versionID ' + this.contentVerionId)
            this.newToast('Success!', 'Record Created Successfully', 'success')
            this.showSpinner = false;
        }).catch(error => {
            this.newToast('Error!', 'An unexpected error occured!', 'error')
            this.showSpinner = false;
            console.log(JSON.stringify(error))
        })
    }
    sendToOpportunity(event) {
        console.log(event.target.name)
        let toastMsg =''
        if(event.target.name === 'Payment')
        toastMsg = 'Payment Link sent to customer via SMS & Email';
        else if(event.target.name === 'Approval')
        toastMsg = 'Approval Link sent to customer via SMS & Email';
        else toastMsg = event.target.name + ' sent to customer';
        sendToCustomer({
            shcId: this.recordId,
            medium: event.target.name,
            url: this.publicURL,
            objName: this.objName
        }).then(r => {
            this.newToast('Success', toastMsg, 'success')
        })
            .catch(e => {
                console.log(JSON.stringify(e))
                this.newToast('Error Occured', 'An unexpected error occured.', 'error')
            })
    } 

    download(event) {

        let fileURL = ''
        if (event.target.name === 'Download')
            fileURL = this.downloadURL
        else fileURL = this.publicURL

        console.log(this.downloadURL)
        console.log(this.publicURL)
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: fileURL
            }
        }).then(url => {
            window.open(url, "_blank");
        });
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