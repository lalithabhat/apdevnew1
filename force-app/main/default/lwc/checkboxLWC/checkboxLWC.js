import { LightningElement, wire, track,api } from 'lwc';
import getPicklistValues from '@salesforce/apex/GetPickList.getPicklistValues'; 
import getOneLevelUpProduct from '@salesforce/apex/GetPickList.getOneLevelUpProduct';

export default class CheckboxLWC extends LightningElement {
    @track values = [];
    @track pickListValueList=[];
    @api classVal;
    //@api filelapiname;
    /*@wire(getPicklistValues, {ObjectApi_name: '$objectapiname', Field_name: '$filelapiname'}) 
    lookupDetailsList({data}) {
        if(data) {
            for(let key in data) {
                if (data.hasOwnProperty(key)) { 
                    this.pickListValueList.push({label: data[key], value: key, classVal:"slds-m-left_x-small slds-m-bottom_x-small slds-button  removeColor"});
                }
            }
        }
    }*/
    @wire(getOneLevelUpProduct, {productId: '$classVal'}) 
    getOneLevelUpProduct({data}) {
        //alert(this.classVal);
        if(data) {
            for(let key in data) {
                if (data.hasOwnProperty(key)) { 
                    this.pickListValueList.push({label: data[key], value: key, classVal:"slds-m-left_x-small slds-m-bottom_x-small slds-button  removeColor"});
                }
            }
        }
    }

    handleClick(event){
        var index;
        var classUpdata='';
        event.preventDefault();
        if(!this.values.includes(event.target.name)){
            this.values.push(...[event.target.name]);
            classUpdata='slds-m-left_x-small slds-m-bottom_xx-small slds-button addColor';
        }else{
            index= this.values.indexOf(event.target.name);
            this.values.splice(index, 1);
            classUpdata='slds-m-left_x-small slds-m-bottom_x-small slds-button removeColor';
        }
        let foundelement = this.pickListValueList.find(ele => ele.value === event.target.name);
        foundelement.classVal = classUpdata;
        this.pickListValueList = [...this.pickListValueList];
        const selectedEvent = new CustomEvent("checkboxvalueupdate", {
            detail: this.values
        });
        this.dispatchEvent(selectedEvent);
    }
    handleChange(){

    }
}