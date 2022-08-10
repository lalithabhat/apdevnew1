import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import getPublicURL from '@salesforce/apex/SharePanelGlobal.getPublicURL'
import savePDF from '@salesforce/apex/SharePanelGlobal.savePDF'
import sendPDFCustomer from '@salesforce/apex/SharePanelGlobal.sendPDFCustomer'
import getSite from '@salesforce/apex/SiteTriggerHandler.getSite'
import getURL from '@salesforce/apex/SiteTriggerHandler.getURL'
import setStatus from '@salesforce/apex/SiteTriggerHandler.setStatus'
export default class SharePanelGlobal extends NavigationMixin(LightningElement) {
    @api objName;
    @api recordId
    @api buttonName
    contentVerionId = ''
    publicURL = ''
    downloadURL = ''
    showSpinner = true;
    errorMessage;
    isError = false;
    showShare = false;

    showSan =false;
    showWarranty = false;

    warrantyURL ={}
    sanAssureURL ={}
    connectedCallback() {
        //alert('hi::');
        console.log('recordId::' + this.recordId);
        console.log('objName::' + this.objName);
        console.log('buttonName::' + this.buttonName);
       
        getSite({ recordId: this.recordId }).then(r => {
            if (r.Status__c === 'Active' && r.Tier__c == 'Platinum') {
                setStatus({ recordId: this.recordId, status: 'TA Audit Pending' }).then(r => {

                })
            }
            else if (r.Tier__c == 'Platinum' && r.Status__c === 'TA Audit Complete' || r.Status__c === 'Approved' || r.Status__c === 'Rejected' ||r.Status__c === 'Completed') {
                this.showShare = true
            }
            else if(r.Tier__c !=='Platinum'){
                this.showShare = true
            }

            if(r.Status__c == 'Completed' && (r.New_Service__c === 'San Assure' || r.New_Service__c === 'San Assure +' || r.New_Service__c ==='San Assure Advanced')){
                this.showSan =true
                getURL({recordId :this.recordId , docType :'SanAssure'}).then(result =>{
                    this.sanAssureURL ={public : result.publicURL, download : result.downloadURL}
                    console.log('in get url '+ JSON.stringify(result))
                })
            }
            if(r.Tier__c == 'Platinum' && r.Status__c == 'Completed'){
                this.showWarranty =true
                getURL({recordId :this.recordId , docType :'Warranty'}).then(result =>{
                    this.warrantyURL ={public : result.publicURL, download : result.downloadURL}
                })
            }
        })
            getPublicURL({ recordId: this.recordId, objName: this.objName, buttonName: this.buttonName }).then(result => {
                console.log(result)
                if (result.publicURL != null && result.publicURL != undefined) {
                    this.publicURL = result.publicURL;
                    this.downloadURL = result.downloadURL
                } else {
                    this.generatePDF();
                }
                this.showSpinner =false
            }).catch(error => {
                this.errorMessage = 'Could not obtain file URL'
                this.isError = true;
                // this.newToast('Error!', 'An unexpected error occured!', 'error')
                this.showSpinner = false;
                console.log(JSON.stringify(error))
            })
        }
    
        generatePDF(event) {
            savePDF({ shcId: this.recordId, objName: this.objName, buttonName: this.buttonName
        }).then(result => {
            console.log('savePDF::' + result);
            if (result.publicURL != null && result.publicURL != undefined) {
                this.publicURL = result.publicURL;
                this.downloadURL = result.downloadURL;
                this.isError = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Document generated Successfully!',
                        variant: 'success'
                    })

                );
            }
        }).catch(error => {
            this.errorMessage = 'Failed to generate document.'
            this.isError = true;
            // this.newToast('Error!', 'An unexpected error occured!', 'error')
            this.showSpinner = false;
            console.log(JSON.stringify(error))
        })
    }

    download(event) {
        console.log(event.target.name)
        console.log(this.sanAssureURL)
        let fileURL = ''
        if (event.target.name === 'siteDownload') fileURL = this.downloadURL;
        else if(event.target.name === 'siteView') fileURL = this.publicURL;
        else if(event.target.name === 'warrantyDownload') fileURL = this.warrantyURL.download;
        else if(event.target.name === 'warrantyView') fileURL = this.warrantyURL.public;
        else if(event.target.name === 'sanDownload') fileURL = this.sanAssureURL.download;
        else if(event.target.name === 'sanView') fileURL = this.sanAssureURL.public;

        console.log('file url' +this.fileURL)
        
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
        let toastMsg =  event.target.name + ' sent to customer';
        sendPDFCustomer({
            shcId: this.recordId,
            medium: event.target.name,
            url: this.publicURL,
            objName: this.objName,
            buttonName: event.target.title
        }).then(r => {
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