import {  LightningElement, api, track } from 'lwc';
import getProductItems from '@salesforce/apex/WorkCreationController.getProductItems';

const delay = 350;
export default class ReusableCustomDropdownWithSearchLwc extends LightningElement {
    @api fieldLabel;
    @api disabled = false;
    @track openDropDown = false;
    @track inputValue = '';
    @api placeholder = '';
    @api options;
    @track optionsToDisplay;
    @api value = '';
    @track label = '';
    delaytimeout;
    @api seq;
    @api productfamily;

    //constructor
    constructor() {
        super();
    }

    connectedCallback() {
        if(this.options.length > 0){

        }else{
            if(this.productfamily != null && this.productfamily != undefined){
                getProductItems({productFamily:this.productfamily})
                .then(result => {
                    for(var i=0; i<result.length; i++) {
                        this.options = [...this.options ,{value: result[i].Id, label: result[i].Name + '|' + result[i].ProductCode}];                                   
                    }
                    console.log('options::'+this.options.length);
                    this.setOptionsAndValues();
                })
                .catch(error => {
                    console.log('Errorured in options method:- '+error);
                });
            }
        }
        
    }

    renderedCallback() {
        if (this.openDropDown) {
            this.template.querySelectorAll('.search-input-class').forEach(inputElem => {
                inputElem.focus();
            });
        }
    }

    //Public Method to set options and values
    @api setOptionsAndValues() {
        this.optionsToDisplay = (this.options && this.options.length > 0 ? this.options : []);
        //alert('value::'+value);
        if (this.value && this.value != "") {
            let label = this.getLabel(this.value);
            if (label && label != "") {
                this.label = label;
            }
        }
        else {
            this.label = "";
        }
    }

    //Method to get Label for value provided
    getLabel(value) {
        let selectedObjArray = this.options.filter(obj => obj.value === value);
        if (selectedObjArray && selectedObjArray.length > 0) {
            return selectedObjArray[0].label;
        }
        return null;
    }

    //Method to open listbox dropdown
    openDropDown(event) {
        this.toggleOpenDropDown(true);
    }

    //Method to close listbox dropdown
    closeDropdown(event) {
	
        if (event.relatedTarget && event.relatedTarget.tagName == "UL" && event.relatedTarget.className.includes('customClass')) {
            console.log(JSON.stringify(event.relatedTarget.className));
            if (this.openDropDown) {
                this.template.querySelectorAll('.search-input-class').forEach(inputElem => {
                    inputElem.focus();
                });
            }
        }
        else {
            window.setTimeout(() => {
                this.toggleOpenDropDown(false);
            }, 300);
        }
    }

    //Method to handle readonly input click
    handleInputClick(event) {
        this.resetParameters();
        this.toggleOpenDropDown(true);
    }

    //Method to handle key press on text input
    handleKeyPress(event) {
        const searchKey = event.target.value;
        this.setInputValue(searchKey);
        if (this.delaytimeout) {
            window.clearTimeout(this.delaytimeout);
        }

        this.delaytimeout = setTimeout(() => {
            //filter dropdown list based on search key parameter
            this.filterDropdownList(searchKey);
        }, delay);
    }

    //Method to filter dropdown list
    filterDropdownList(key) {
        const filteredOptions = this.options.filter(item => item.label.toLowerCase().includes(key.toLowerCase()));
        this.optionsToDisplay = filteredOptions;
    }

    //Method to handle selected options in listbox
    optionsClickHandler(event) {
        const value = event.target.closest('li').dataset.value;
        const label = event.target.closest('li').dataset.label;
        this.setValues(value, label);
        this.toggleOpenDropDown(false);
        const detail = {};
        detail["value"] = value;
        detail["label"] = label;
        detail["seq"] = this.seq;
        //alert('seq inside child::'+this.seq);
        this.dispatchEvent(new CustomEvent('change', { detail: detail }));
    }

    //Method to reset necessary properties
    resetParameters() {
        this.setInputValue("");
        this.optionsToDisplay = this.options;
    }

    //Method to set inputValue for search input box
    setInputValue(value) {
        this.inputValue = value;
    }

    //Method to set label and value based on
    //the parameter provided
    setValues(value, label) {
        this.label = label;
        this.value = value;
    }

    //Method to toggle openDropDown state
    toggleOpenDropDown(toggleState) {
        this.openDropDown = toggleState;
    }

    //getter setter for labelClass
    get labelClass() {
        return (this.fieldLabel && this.fieldLabel != "" ? "slds-form-element__label slds-show" : "slds-form-element__label slds-hide")
    }

    //getter setter for dropDownClass
    get dropDownClass() {
        return (this.openDropDown ? "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open" : "slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click");
    }

    //getter setter for isValueSelected
    get isValueSelected() {
        return (this.label && this.label != "" ? true : false);
    }

    get isDropdownOpen() {
        return (this.openDropDown ? true : false);
    }
}