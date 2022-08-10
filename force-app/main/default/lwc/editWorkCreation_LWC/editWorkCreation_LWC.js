import { LightningElement, api, track, wire } from 'lwc';
import getQuoteDetails from '@salesforce/apex/WorkCreationController.getQuoteDetails';
import addProductItem from '@salesforce/apex/WorkCreationController.addProductItem';
import saveWork from '@salesforce/apex/WorkCreationController.saveWork';
import getProductItems from '@salesforce/apex/WorkCreationController.getProductItems';
import getWorkDetails from '@salesforce/apex/WorkCreationController.getWorkDetails';
import getExistingConsumption from '@salesforce/apex/WorkCreationController.getExistingConsumption';
import getContractorList from '@salesforce/apex/WorkCreationController.getContractorList';
import updateWork from '@salesforce/apex/WorkCreationController.updateWork';
import getQuoteLevelProduct from '@salesforce/apex/WorkCreationController.getQuoteLevelProduct';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getServiceName from '@salesforce/apex/Quotation.getServiceName';
import getShadeImage from '@salesforce/apex/WorkCreationController.getShadeImage';
import validateConsumption from '@salesforce/apex/WorkCreationController.validateConsumption';
import isMoneyApprovalRequired from '@salesforce/apex/WorkCreationController.isMoneyApprovalRequired';
export default class EditWorkCreation_LWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @track quote;
    @track work;
    @track workId;
    @track isEdit = false;
    @track workAdded = false;
    @track productList = [];
    @track productSeq = 0;
    @track quoteNumber;
    @track selectedConsumption;
    @track contractorMissing = false;
    @track siteMissing = false;
    @track contractorList = [];
    @track quoteNotValid = false;
    @track quoteLevelProducts = [];

    dealerId = ''
    consumptionError = undefined
    approvalMessage = undefined
    ///////////////Fetch Image Logic ///////////////////////
    shadeCodeInput = ''
    imageValue = undefined;  //temp value
    imgSpinner = false;
    @track imageList = []
    imageError = undefined
    disableAdd = true
    addImage(e) {

        let index = this.imageList.length;
        this.imageList.push({ shadeCode: this.shadeCodeInput, imageVal: this.imageValue, index: index })
        this.shadeCodeInput = ''
        this.imageValue = undefined
        this.disableAdd = true

    }
    deleteImage(e) {
        console.log(e.target.dataset.index)
        this.imageList.splice(e.target.dataset.index, 1);
        console.log(this.imageList.length);
        for (let i = 0; i < this.imageList.length; i++) {
            this.imageList[i].index = i;
        }
    }
    getImage() {
        this.imgSpinner = true;
        console.log('calling api')
        getShadeImage({ shadeCode: this.shadeCodeInput })
            .then(r => {
                this.imageError = undefined;
                this.imageValue = r;
                this.imgSpinner = false
                this.disableAdd = false
            })
            .catch(e => {
                this.imageValue = undefined
                this.imageError = e.body.message
                console.log('Image fetch error ' + JSON.stringify(e))
                this.imgSpinner = false
                this.disableAdd = true
            })
    }
    handleShadeIp(e) {
        this.shadeCodeInput = e.target.value;
        if (this.shadeCodeInput != undefined && this.shadeCodeInput.length >= 4)
            this.getImage()
    }
    //////// Get Quote Details
    @wire(getQuoteDetails, { qId: '$recordId' })
    getQuoteDetails({ data, error }) {
        if (data) {
            //alert('data:::'+data);
            this.quote = JSON.stringify(data);
            this.quote = JSON.parse(this.quote);
            console.log('Quote:: ' + this.quote);
            this.quoteNumber = this.quote.Id;
            this.dealerId = this.quote.Dealer__c
            if (this.quote.Status != 'Accepted') {
                this.quoteNotValid = true;
            } else {
                if (this.quote.Site__c != null && this.quote.Site__c != undefined) {
                    getQuoteLevelProduct({ qId: this.recordId })
                        .then(result => {
                            this.quoteLevelProducts = JSON.stringify(result);
                            this.quoteLevelProducts = JSON.parse(this.quoteLevelProducts);
                            console.log('quoteLevelProducts::' + this.quoteLevelProducts.length);
                        })
                        .catch(error => {
                            console.log('Errorured in get Quote Level Product list method:- ' + error);
                        });
                } else {
                    this.siteMissing = true;
                }
                /*  if(this.quote.Contractor__c != null && this.quote.Contractor__c != undefined){
                      this.contractorMissing = false; 
                      this.selectedContractor = this.quote.Contractor__c;
                  }else{
                      this.contractorMissing = true;*/
                //alert(this.quote.Dealer__c);
                getContractorList({ dealerId: this.quote.Dealer__c })
                    .then(result => {
                        for (var i = 0; i < result.length; i++) {
                            var contractorname = '';
                            if (result[i].Contractor__r.Rating__c != null && result[i].Contractor__r.Rating__c != undefined) {
                                contractorname = result[i].Contractor__r.Name + ' | ' + result[i].Contractor__r.Rating__c;
                            } else {
                                contractorname = result[i].Contractor__r.Name + ' | ';
                            }
                            this.contractorList = [...this.contractorList, { value: result[i].Contractor__c, label: contractorname }];
                        }
                        console.log('contractorList::' + this.contractorList);
                    })
                    .catch(error => {
                        console.log('Errorured in getContractorList method:- ' + error);
                    });
                // }
            }


        } else if (error) {
            this.error = error;
        }
    }

    //////// Get Work Details
    @wire(getWorkDetails, { wId: '$recordId' })
    getWorkDetails({ data, error }) {
        if (data) {
            //alert('data:::'+data);
            this.work = JSON.stringify(data);
            this.work = JSON.parse(this.work);
            console.log('work:: ' + this.work);
            this.workId = this.work.Id;
            this.isEdit = true;
            this.workAdded = true;
            getQuoteDetails({ qId: this.work.Quote__c })
                .then(result => {
                    this.quote = JSON.stringify(result);
                    this.quote = JSON.parse(this.quote);
                    console.log('Quote:: ' + this.quote);
                    this.quoteNumber = this.quote.Id;
                    if (this.quote.Contractor__c != null) {
                        this.contractorMissing = false;
                        this.selectedContractor = this.quote.Contractor__c;
                    } else {
                        this.contractorMissing = true;
                    }

                    getQuoteLevelProduct({ qId: this.quote.Id })
                        .then(result => {
                            this.quoteLevelProducts = JSON.stringify(result);
                            this.quoteLevelProducts = JSON.parse(this.quoteLevelProducts);
                            console.log('quoteLevelProducts::' + this.quoteLevelProducts.length);
                        })
                        .catch(error => {
                            console.log('Errorured in get Quote Level Product list method:- ' + error);
                        });

                })
                .catch(error => {
                    console.log('Errorured in getQuoteDetails method:- ' + error);
                });

            getExistingConsumption({ wId: this.workId })
                .then(result => {
                    this.productList = JSON.stringify(result);
                    this.productList = JSON.parse(this.productList);
                    console.log('productList:: ' + this.productList);

                })
                .catch(error => {
                    console.log('Errorured in getExistingConsumption method:- ' + error);
                });

        } else if (error) {
            this.error = error;
        }
    }


    addWork(event) {
        this.workAdded = true;
        // this.handleSetActiveSectionWorkDetails();
    }

    /*handleSetActiveSectionWorkDetails() {
         const accordion = this.template.querySelector('.work-accordion');
         accordion.activeSectionName = 'Work Details';
     }*/

    @track selectedContractor;
    contractorChange(event) {
        console.log('selectedContractor::' + event.detail.value);
        this.selectedContractor = event.detail.value;
    }
    @track moneyCollected;
    moneyCollectedChange(event) {
        console.log('money Collected::' + event.target.value);
        this.moneyCollected = event.target.value;
    }

    @track kickOff;
    kickOffChange(event) {
        console.log('kickOff::' + event.target.value);
        this.kickOff = event.target.value;
    }

    @track deadLine;
    deadLineChange(event) {
        console.log('deadLine::' + event.target.value);
        this.deadLine = event.target.value;
        console.log('Site Dealine date:: ' + this.quote.Site__r.Deadline__c);
        if (this.kickOff > this.deadLine) {
            alert('Deadline Date should be greater than Kickoff Date');
        } else if (this.deadLine > this.quote.Site__r.Deadline__c) {
            alert('Deadline date should be less than site Deadline Date: ' + this.quote.Site__r.Deadline__c);
        }
    }

    @track description;
    descriptionChange(event) {
        console.log('description::' + event.target.value);
        this.description = event.target.value;
    }

    @track shadeCode;
    shadeCodeChange(event) {
        console.log('shadeCode::' + event.target.value);
        this.shadeCode = event.target.value;
    }

    @track productItems = [];
    productFamilyChane(event) {
        console.log('productFamily::' + event.target.value);
        var seq = event.target.dataset.id;
        this.productList[seq].consumption.Product_Family__c = event.target.value;
        this.productItems = [];
        getProductItems({ productFamily: event.target.value })
            .then(result => {
                for (var i = 0; i < result.length; i++) {
                    //   this.productItems = [...this.productItems ,{value: result[i].Id, label: result[i].Name + ' | ' + result[i].ProductCode}];
                    this.productItems = [...this.productItems, { value: result[i].Id, label: result[i].Name }];
                }
                console.log('productItems::' + this.productItems.length);

            })
            .catch(error => {
                console.log('Errorured in productItems method:- ' + error);
            });
    }

    quantityChange(event) {

        var seq = event.target.dataset.id;
        this.productList[seq].consumption.Quantity__c = event.target.value;
    }
    amountChange(event) {
        console.log('value::' + event.target.value);
        var seq = event.target.dataset.id;
        this.productList[seq].consumption.Amount__c = event.target.value;
    }

    productChange(event) {
        var seq = event.detail.seq;
        this.productList[seq].consumption.Product__c = event.detail.value;
        console.log(this.productList)
        getServiceName({ productId: event.detail.value, dealerId: this.dealerId }).then(r => {
            if (r === 'undefined')
                this.productList[seq].service = undefined
            else
                this.productList[seq].service = r
        })
    }

    cancelWork() {
        this.dispatchEvent(new CustomEvent('close'));
    }
    showSpinner = false;
    saveWork(event) {
        console.log('PW ' + JSON.stringify(this.productList))
        this.showSpinner = true

        if (this.moneyCollected != null && this.moneyCollected != undefined && this.kickOff != null && this.kickOff != undefined &&
            this.deadLine != null && this.deadLine != undefined) {
            //  && this.shadeCode != null && this.shadeCode != undefined) {
            if (this.selectedContractor != null && this.selectedContractor != undefined) {
                if (this.kickOff > this.deadLine) {
                    this.showSpinner = false
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Deadline Date should be grater than kickoff date.',
                            variant: 'error'
                        })

                    );

                }
                else if (this.imageList.length == 0) {
                    this.showSpinner = false
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please select at least one Shade.',
                            variant: 'error'
                        })
                    );
                }

                else if (this.deadLine > this.quote.Site__r.Deadline__c) {
                    this.showSpinner = false
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Deadline date should be less than site Deadline Date: ' + this.quote.Site__r.Deadline__c,
                            variant: 'error'
                        })

                    );
                } else if (this.moneyCollected > this.quote.Total_Amount_after_discount__c) {
                    this.showSpinner = false
                    //alert(Number(this.quote.Total_Amount_after_discount__c) + Number(this.moneyCollected));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Money Collected should not be greater than Quote amount ',
                            variant: 'error'
                        })

                    );
                } else {

                    var totalWorkAMount = 0;
                    totalWorkAMount = Number(this.moneyCollected) + Number(this.quote.Total_Money_Received__c);
                    if (totalWorkAMount > Number(this.quote.Total_Amount_after_discount__c)) {
                        this.showSpinner = false
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Total money received is exceeding than total Quote amount ',
                                variant: 'error'
                            })

                        );
                    }
                    else {


                        //alert('bye');
                        /*let fieldList = [];
                        fieldList.push({ label: 'moneyCollected', value: this.moneyCollected });
                        fieldList.push({ label: 'kickOff', value: this.kickOff });
                        fieldList.push({ label: 'deadLine', value: this.deadLine });
                        fieldList.push({ label: 'description', value: this.description });
                        fieldList.push({ label: 'shadeCode', value: this.shadeCode });
                        fieldList = JSON.stringify(fieldList);
                        let tempItems = JSON.stringify(this.productList);
                        console.log('temp Items : ' + tempItems)
                        let tempRecord = JSON.stringify(this.quote);
                        console.log('Before saveWork ' + JSON.stringify(this.imageList))*/
                        console.log(this.productList)

                        for (let i = 0; i < this.productList.length; i++) {
                            if (this.productList[i].consumption.Product__c === undefined ||
                                this.productList[i].consumption.Quantity__c === undefined ||
                                this.productList[i].consumption.Quantity__c === '') {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error',
                                        message: 'Consumption Fields Missing',
                                        variant: 'error'
                                    })

                                );
                                this.showSpinner = false
                                return
                            }
                        }
                        this.consumptionError = undefined
                                        this.approvalMessage =undefined
                        validateConsumption({ pw: this.productList, dealerId: this.dealerId }).then(r => {
                            this.consumptionError = r
                            console.log('consumption error '+this.consumptionError)
                            isMoneyApprovalRequired({ siteId: this.quote.Site__c, moneyCollected: this.moneyCollected })
                                .then(r1 => {
                                  
                                   this.approvalMessage = r1
                                    console.log('consumption error '+this.consumptionError)
                                    if (this.consumptionError !== '' || this.approvalMessage !== '') {
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Please Review The Work Details!',
                                              //  message: 'Please review Consumptions',
                                                variant: 'warning',
                                            })
        
                                        );
                                        this.showModalBox();
                                        this.showSpinner = false
                                        return
                                    }
                                    else {
                                        this.consumptionError = undefined
                                        this.approvalMessage =undefined
                                        this.callSaveWork();
                                    }
                                })
                                .catch(e1 => {
                                    console.log('isMoneyApprovalRequired error ' + JSON.stringify(e1))
                                })
                            
                            
                            // else {
                            //     this.consumptionError = undefined
                            //     this.callSaveWork();
                                /*saveWork({ fieldList: fieldList, productItems: tempItems, quote: tempRecord, selectedContractor: this.selectedContractor, shadeImages: this.imageList })
                                    .then(result => {
                                        this.showSpinner = false
                                        //alert('result::'+result);
                                        this[NavigationMixin.Navigate]({
                                            type: 'standard__recordPage',
                                            attributes: {
                                                recordId: result,
                                                objectApiName: 'Milestone1_Milestone__c',
                                                actionName: 'view',
                                            },
                                        });
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Success',
                                                message: 'Work added successfully!',
                                                variant: 'success'
                                            })
        
                                        );
                                        //this.cancelWork();
                                    })
                                    .catch(error => {
                                        this.showSpinner = false
        
                                        console.log('Errorured in SaveWork method:- ' + JSON.stringify(error));
                                        this.dispatchEvent(
                                            new ShowToastEvent({
                                                title: 'Failed to add the Work.',
                                                message: error.body.message,
                                                variant: 'error',
                                                mode: 'sticky'
                                            })
        
                                        );
                                    });*/
                          //  }
                        }).catch(e => {
                            this.showSpinner = false
                            console.log('Consumption Validation error ' + JSON.stringify(e))
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Failed to validate consumption.',
                                    message: 'test', // e.body.message,
                                    variant: 'error',
                                    mode: 'sticky'
                                })

                            );
                        })

                    }

                }
            } else {
                //alert(hi);
                this.showSpinner = false
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select contractor',
                        variant: 'error'
                    })

                );
            }
        } else {
            this.showSpinner = false
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Mandatory fields on work can not be blank.',
                    variant: 'error'
                })

            );
        }

    }

    updateWork(event) {
        let fieldList = [];
        fieldList.push({ label: 'moneyCollected', value: this.moneyCollected });
        fieldList.push({ label: 'kickOff', value: this.kickOff });
        fieldList.push({ label: 'deadLine', value: this.deadLine });
        fieldList.push({ label: 'description', value: this.description });
        fieldList.push({ label: 'shadeCode', value: this.shadeCode });
        fieldList = JSON.stringify(fieldList);
        let tempItems = JSON.stringify(this.productList);
        let tempRecord = JSON.stringify(this.work);
        if (this.moneyCollected != null && this.moneyCollected != undefined && this.kickOff != null && this.kickOff != undefined &&
            this.deadLine != null && this.deadLine != undefined && this.shadeCode != null && this.shadeCode != undefined) {
            if (this.kickOff > this.deadLine) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Deadline Date should be grater than kickoff date.',
                        variant: 'error'
                    })

                );
            } else if (this.deadLine > this.quote.Site__r.Deadline__c) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Deadline date should be less than site Deadline Date: ' + this.quote.Site__r.Deadline__c,
                        variant: 'error'
                    })

                );
            } else if (this.moneyCollected > this.quote.Total_Amount_after_discount__c) {
                //alert(Number(this.quote.Total_Amount_after_discount__c) + Number(this.moneyCollected));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Money Collected should not be greater than Quote amount ',
                        variant: 'error'
                    })

                );
            } else {
                var totalWorkAMount = 0;
                totalWorkAMount = Number(this.moneyCollected) + Number(this.quote.Total_Money_Received__c);
                if (totalWorkAMount > Number(this.quote.Total_Amount_after_discount__c)) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Total money received is exceeding than total Quote amount ',
                            variant: 'error'
                        })

                    );
                } else {
                    updateWork({ fieldList: fieldList, productItems: tempItems, workId: tempRecord })
                        .then(result => {

                            //alert('result::'+result);
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: result,
                                    objectApiName: 'Milestone1_Milestone__c',
                                    actionName: 'view',
                                },
                            });
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Work updated successfully!',
                                    variant: 'success'
                                })

                            );
                            //this.cancelWork();
                        })
                        .catch(error => {
                            console.log('Errorured in updateWork method:- ' + error);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Failed to update the Work.' + error,
                                    variant: 'error'
                                })

                            );
                        });
                }

            }
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Mandatory fields on work can not be blank.',
                    variant: 'error'
                })

            );
        }

    }

    addProduct(event) {
        console.log('inside addProduct:' + this.productList.length);
        let tempRecord = JSON.stringify(this.productList);
        this.productSeq = Number(this.productSeq) + 1;
        this.selectedConsumption = 'Consumption ' + this.productSeq;
        addProductItem({ existingList: tempRecord, selectedConsumption: this.selectedConsumption })
            .then(result => {
                this.productList = JSON.stringify(result);
                this.productList = JSON.parse(this.productList);
                for (let i = 0; i < this.productList.length; i++) {
                    if (this.productList[i].service === 'undefined')
                        this.productList[i].service = undefined
                }
                console.log('after product add::' + this.productList.length);
                this.isShowModal = false;
            })

            .catch(error => {
                console.log('Errorured in addProduct method:- ' + error);
            });
    }

    @track isShowModal = false;
    showModalBox() {
        this.isShowModal = true;
    }

    hideModalBox() {
        this.isShowModal = false;
    }
    @track selectedConsumption;
    fetchConsumptionName(event) {
        console.log('selectedConsumption::' + event.target.value);
        this.selectedConsumption = event.target.value;
    }



    deleteProduct(event) {
        console.log('seq::' + event.target.dataset.id);
        var seq = event.target.dataset.id;
        var index;
        for (var q = 0; q < this.productList.length; q++) {
            if (this.productList[q].sequence == seq) {
                index = this.productList.indexOf(this.productList[q]);
            }
        }
        this.productList.splice(index, 1);
        if (this.productList.length == 0) {
            this.productSeq = 0;
        } else {
            this.productSeq = Number(this.productSeq) - 1;
        }
    }

    handleScrollClick() {
        const topDiv = this.template.querySelector('[data-id="consumption"]');
        console.log('scroll ' + topDiv)
        topDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
    }

    callSaveWork(e) {
        //alert('bye');
        this.showSpinner = true
        let fieldList = [];
        fieldList.push({ label: 'moneyCollected', value: this.moneyCollected });
        fieldList.push({ label: 'kickOff', value: this.kickOff });
        fieldList.push({ label: 'deadLine', value: this.deadLine });
        fieldList.push({ label: 'description', value: this.description });
        fieldList.push({ label: 'shadeCode', value: this.shadeCode });

        if (e !== undefined && e.currentTarget.dataset.consumption == true)
            fieldList.push({ label: 'volumeApproval', value: true });
        else
            fieldList.push({ label: 'volumeApproval', value: false });
        fieldList = JSON.stringify(fieldList);
        let tempItems = JSON.stringify(this.productList);
       // console.log('temp Items : ' + tempItems)
        let tempRecord = JSON.stringify(this.quote);
       // console.log('Before saveWork ' + JSON.stringify(this.imageList))

        saveWork({ fieldList: fieldList, productItems: tempItems, quote: tempRecord, selectedContractor: this.selectedContractor, shadeImages: this.imageList })
            .then(result => {
                this.showSpinner = false
                //alert('result::'+result);
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: result,
                        objectApiName: 'Milestone1_Milestone__c',
                        actionName: 'view',
                    },
                });
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Work added successfully!',
                        variant: 'success'
                    })

                );
                //this.cancelWork();
            })
            .catch(error => {
                this.showSpinner = false

                console.log('Errorured in SaveWork method:- ' + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Failed to add the Work.',
                        message: error.body.message,
                        variant: 'error',
                        mode: 'sticky'
                    })

                );
            });
    }
}