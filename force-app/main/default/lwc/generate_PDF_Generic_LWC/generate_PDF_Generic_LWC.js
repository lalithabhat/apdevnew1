import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import getPublicURL from '@salesforce/apex/SharePanelGlobal.getPublicURL'
import savePDF from '@salesforce/apex/SharePanelGlobal.savePDF'
import sendPDFCustomer from '@salesforce/apex/SharePanelGlobal.sendPDFCustomer'

export default class Generate_PDF_Generic_LWC extends NavigationMixin(LightningElement) {
    @api objName;
    @api recordId;
    @api buttonName;

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

    @track showSpinner =true;
    connectedCallback() {
        //alert('hi::');
        console.log('recordId::'+this.recordId);
        console.log('objName::'+this.objName);
        console.log('buttonName::'+this.buttonName);
        getPublicURL({ recordId: this.recordId,objName:this.objName,buttonName:this.buttonName }).then(result => {
            console.log(result)
            if(result.publicURL != null && result.publicURL != undefined){
                this.publicURL = result.publicURL;
                this.downloadURL = result.downloadURL
                this.showSpinner =false;
            }else{
                this.generatePDF();
            }
        }).catch(error => {
            this.showSpinner =false;
            this.errorMessage = 'Could not obtain file URL'
            this.isError =true;
           // this.newToast('Error!', 'An unexpected error occured!', 'error')
            this.showSpinner = false;
            console.log(JSON.stringify(error))
        })
    }

    generatePDF(event) {
        this.showSpinner =true;
        console.log('spinner stat '+this.showSpinner)
        savePDF({ shcId: this.recordId,objName:this.objName,buttonName:this.buttonName }).then(result => {
            console.log('savePDF::'+result);
            if(result.publicURL != null && result.publicURL != undefined){
                this.publicURL = result.publicURL;
                this.downloadURL = result.downloadURL;
                this.isError =false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Document generated Successfully!',
                        variant: 'success'
                    })
                    
                );
               
            }
            this.showSpinner =false
        }).catch(error => {
            this.showSpinner =false
            this.errorMessage = 'Failed to generate document.'
            this.isError =true;
           // this.newToast('Error!', 'An unexpected error occured!', 'error')
            this.showSpinner = false;
            console.log(JSON.stringify(error))
        })
    }

    download(event) {
        //alert('download:: '+this.downloadURL);
        //alert('publicURL:: '+this.publicURL);
        let fileURL = ''
        if (event.target.name === 'Download')
            fileURL = this.downloadURL;
        else fileURL = this.publicURL;

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

    sendToOpportunity(event) {
        console.log(event.target.name)
        let toastMsg =''
        if(event.target.name === 'Payment')
        toastMsg = 'Payment Link sent to customer via SMS & Email';
        else if(event.target.name === 'Approval')
        toastMsg = 'Approval Link sent to customer via SMS & Email';
        else toastMsg = event.target.name + ' sent to customer';
        sendPDFCustomer({
            shcId: this.recordId,
            medium: event.target.name,
            url: this.publicURL,
            objName: this.objName,
            buttonName: this.buttonName
        }).then(r => {
            //alert('hi');
            this.newToast('Success', toastMsg, 'success');
        })
            .catch(e => {
                //alert('bye');
                console.log(JSON.stringify(e))
                this.newToast('Error Occured', 'An unexpected error occured.', 'error')
            })
    } 

    newToast(title, message, varient) {
        //alert('hi');
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: varient,
        });
        this.dispatchEvent(evt);
    }

}