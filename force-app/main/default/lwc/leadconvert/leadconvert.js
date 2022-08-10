import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import convert from '@salesforce/apex/convertlead.convert';
export default class Leadconvert extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName = 'Lead';
    @track error;
    @track leadName;
    @track companyName;
    constructor() {
        super();
        console.log('Record Id:' + this.recordId);
    }
    connectedCallback() {
        console.log('convert lead called:' + this.recordId);
        convert({
            leadId: this.recordId
        })
            .then(result => {
                console.log('result:', result);
                if (result.success) {
                    const toastSuccess = new ShowToastEvent({
                        'title': 'Success',
                        'message': result.message,
                        'variant': 'success'
                    });
                    this.dispatchEvent(toastSuccess);
                    this.navigateToRecordDetail(result.recId);
                    this.closeQuickAction();
                } else {
                    if(result.isError) {
                        const toastError = new ShowToastEvent({
                            'title': 'Error',
                            'message': result.message,
                            'variant': 'error',
                            'mode': 'sticky'
                        });
                        this.dispatchEvent(toastError);
                        this.closeQuickAction();
                    } else {
                        const toastError = new ShowToastEvent({
                            'title': 'Exception',
                            'message': result.message,
                            'variant': 'error',
                            'mode': 'sticky'
                        });
                        this.dispatchEvent(toastError);
                        this.closeQuickAction();
                    }
                }


            })
            .catch(error => {
                console.log('error:', error);

                const toastError = new ShowToastEvent({
                    'title': 'System Exception',
                    'message': 'An unknown exception occurred while converting the lead:' + error,
                    'variant': 'error'
                });
                this.dispatchEvent(toastError);
                this.closeQuickAction();
            })
    }
    navigateToRecordDetail(selectedRecId) {
        console.log('navigation mixin:', selectedRecId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecId,
                actionName: 'view'
            }
        });
    }
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }

}