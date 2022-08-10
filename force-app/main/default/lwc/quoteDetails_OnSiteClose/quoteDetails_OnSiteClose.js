import {  LightningElement,api,track,wire } from 'lwc';
import getQuoteRecords from '@salesforce/apex/QuoteDetails_OnSiteClose.getQuoteRecords';

export default class QuoteDetails_OnSiteClose extends LightningElement {
    @api recordId;
    @track mapData=[];
   
    @wire(getQuoteRecords, {siteId:'$recordId'})
    getQuoteRecords({data, error}){
        if(data){
            this.mapData = JSON.stringify(data);
            this.mapData = JSON.parse(this.mapData);
        }else if (error) {
            this.error = error;
            console.log('Error while getQuoteRecords::'+error);
        }
    }
}