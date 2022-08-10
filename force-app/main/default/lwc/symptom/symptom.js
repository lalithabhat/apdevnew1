import { LightningElement, api, track, wire } from 'lwc';
import getDependentPicklistValues from '@salesforce/apex/SHC_Helper.getDependentPicklistValues'
import getReco from '@salesforce/apex/SHC_Helper.getReco';
import getProdName from '@salesforce/apex/SHC_Helper.getProductNameById'

const FIELDS = ['Product2.Name'];  ///get product Name
export default class Symptom extends LightningElement {
    @api recordId;
    @api test;
    @api symptomType;
    @api index;
    @api area;
    @api intext;
    
    @api checked =false;
    @api severity = '';
    @api affectedArea =0;
    @api addProduct = undefined;
    @api recoProduct = undefined;

    showSpinner = false
    severityWire = []

   
    disabled = false

    userSeletedReco = '';
    manualProdName = '';
    recoProdName = '';
   
    @track dataWrap = {
        index: '',
        type: '',
        area: '',
        checked: false,
        observation: '',
        affectedArea: 0,
        severity: '',
        files: [],
        reco: '',
        intext: '',
        recoProduct : undefined,
        addProduct : undefined
    }
    @track items = [];
    @track recoMsg = 'Recommendation Not Available / Removed'
    
    connectedCallback() {
       
        this.showSpinner =true;
        this.dataWrap.index = this.index
        this.dataWrap.type = this.test
        this.dataWrap.intext = this.intext

        this.dataWrap.severity = this.severity
        if(this.affectedArea !== undefined  || this.affectedArea !==0)
        this.dataWrap.affectedArea = this.affectedArea
        else this.dataWrap.affectedArea =undefined
        this.dataWrap.checked =this.checked
        this.dataWrap.addProduct = this.addProduct
        this.dataWrap.recoProduct = this.recoProduct
        if(this.dataWrap.recoProduct !== undefined) {
            this.showRecoBox =true
         }

        getDependentPicklistValues({ objName: 'Health_Card_Observation__c', dependentField: 'Severity__c', seletedControllingOption: this.test })
            .then(result => {
                this.severityWire = result
                //if(this.severityWire.severityWire.length >0)  this.severityDefault ={label: this.severityWire[0], value:this.severityWire[0]} ;
            })
            .catch(e => {
                console.log(JSON.stringify(e))
            }).finally(f=>{
                this.showSpinner =false
            })
        
      }



    get options() {
        let severityOptions = []
        for (let i = 0; i < this.severityWire.length; i++) severityOptions.push({ label: this.severityWire[i], value: this.severityWire[i] })
        return severityOptions
    }
    

   

    handlePillRemove(e) {

        let userReco = []

        this.userSeletedReco = '';
        for (let i = 0; i < this.items.length; i++) {
            if (this.items[i].Id !== e.currentTarget.dataset.id) {   //userReco.slice(i,1);
                userReco.push(this.items[i]);
                this.userSeletedReco = this.userSeletedReco + this.items[i].Name + ' | '
            }
        }
        this.items = userReco
        this.dataWrap.reco = this.userSeletedReco
        this.dataWrap.recoProduct = undefined;
        console.log(this.dataWrap)
        this.sendToParent();

    }
    handleCB(e) {
        try {
            this.checked = e.target.checked
            this.dataWrap.checked = e.target.checked
            this.sendToParent();
        }
        catch (e) { console.log(e.message) }


    }
    handleIp(e) {

        if (e.target.name === 'observation') {
            this.dataWrap.observation = e.target.value;
            this.sendToParent();
        }
        else if (e.target.name === 'severity') {
            this.dataWrap.severity = e.target.value;
            getReco({ symptom: this.test, severity: e.target.value })
                .then(result => {
                    
                    if (result !== null) {
                        this.recoProdName = result.Product__r.Name
                        this.dataWrap.recoProduct = result.Product__c
                        this.showRecoBox = true
                    }
                    else {
                        this.showRecoBox =false
                        this.recoMsg = 'No Recommendation Available'
                        this.dataWrap.recoProduct = undefined
                        this.recoProdName = ''
                    }
                    let recoTemp = ''
                    recoTemp = this.recoProdName 
                    if (this.recoProdName != '') recoTemp += ' | '
                    if(this.manualProdName != '') recoTemp += this.manualProdName;
                    this.dataWrap.reco = recoTemp
                    this.sendToParent()
                }).catch(error => {
                    console.log(JSON.stringify(error))
                })
        }

        else if (e.target.name === 'affectedArea') {
            this.dataWrap.affectedArea = e.target.value;
            this.sendToParent();
        }

    }
    //////////////////////////////////////////Product lookup/////////////////////////////////////////////////////////////////
    childObjectApiName = 'Health_Card_Observation__c'; //Contact is the default value
    targetFieldApiName = 'Product__c'; //AccountId is the default value
    showRecoBox = false;

    
    @api value;

    handleChangeReco(event) {
        
        if (!this.template.querySelector('lightning-input-field').reportValidity()) {
            this.showRecoBox = false;
            this.recoMsg = 'Recommendation Removed'
            this.recoProdName =''
            this.dataWrap.reco = this.manualProdName;
            this.dataWrap.recoProduct = undefined;
            this.sendToParent()
        }
    }

    handleChange(event) {
        
      if(event.detail.value[0] ==='' || event.detail.value[0] === undefined || event.detail.value[0]=== null) {
        this.dataWrap.reco = this.recoProdName
        this.dataWrap.addProduct = undefined
        this.sendToParent()
      }
      else{
       this.dataWrap.addProduct = event.detail.value[0]
            getProdName({ pid: event.detail.value[0] })
                .then(r => {
                    this.manualProdName = r
                    let recoTemp = ''
                    recoTemp = this.recoProdName 
                    if (this.recoProdName != '') recoTemp += ' | '
                    if(this.manualProdName != '') recoTemp += this.manualProdName;
                    this.dataWrap.reco = recoTemp
                    this.sendToParent()
                }).catch(e =>{
                    console.log(JSON.stringify(e))
                })
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    sendToParent() {
        console.log(this.dataWrap)
        const selectedEvent = new CustomEvent('change', { detail: this.dataWrap });
        this.dispatchEvent(selectedEvent);
    }

    @api checkValidity() {
        const isInputCorrect = [...this.template.querySelectorAll("lightning-input, lightning-combobox")]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        return { validity: isInputCorrect, area: this.area }
      
    }

   

}