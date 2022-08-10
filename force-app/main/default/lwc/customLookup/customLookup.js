import lookUp from '@salesforce/apex/Lookup.search';
import { api, LightningElement, track, wire } from 'lwc';
import getOneLevelUpProduct from '@salesforce/apex/GetPickList.getOneLevelUpProduct';


export default class customLookUp extends LightningElement {

    @api objName;
    @api iconName;
    @api filter = '';
    @api searchPlaceholder='Search';
    @api selectedName;
    @track records;
    @api isValueSelected;
    @track blurTimeout;
    @api productId;
    searchTerm;
    //css
    @track boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    @track inputClass = '';
    
    @wire(lookUp, {searchTerm : '$searchTerm', myObject : '$objName', filter : '$filter'})
    wiredRecords({ error, data }) {
        if (data) {
            this.error = undefined;
            this.records = data;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }
    handleClick() {
        this.searchTerm = '';
        this.inputClass = 'slds-has-focus';
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus slds-is-open';
    }
    onBlur() {
        this.blurTimeout = setTimeout(() =>  {this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus'}, 300);
    }
    onSelect(event) {
        this.productId = event.currentTarget.dataset.id;
        let selectedId = event.currentTarget.dataset.id;
        let selectedName = event.currentTarget.dataset.name;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  selectedId });
        this.dispatchEvent(valueSelectedEvent);
        this.isValueSelected = true;
        this.selectedName = selectedName;
        if(this.blurTimeout) {
            clearTimeout(this.blurTimeout);
        }
        this.boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    }

    handleRemovePill() {
        this.isValueSelected = false;
        this.productId = null;
        const valueSelectedEvent = new CustomEvent('lookupselected', {detail:  undefined });
        this.dispatchEvent(valueSelectedEvent);
        const selectedEvent = new CustomEvent("upperproductchange", {
            detail: undefined
        });
        this.dispatchEvent(selectedEvent);
    }

    onChange(event) {
        this.searchTerm = event.target.value;
    }

    handleChangeCheckbox(event){
        const selectedEvent = new CustomEvent("upperproductchange", {
            detail: event.detail
        });
        this.dispatchEvent(selectedEvent);
    }

}