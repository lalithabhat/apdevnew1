import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import createSHC from '@salesforce/apex/SHC_Helper.createSHC'
import getDependentPicklistValues from '@salesforce/apex/SHC_Helper.getDependentPicklistValues'
import saveHealthCard from '@salesforce/apex/SHC_Helper.savePDF'
import sendToCustomer from '@salesforce/apex/SHC_Helper.sendToCustomer'
import deleteFile from '@salesforce/apex/SHC_Helper.deleteFile'

import getSHCData from '@salesforce/apex/SHC_Helper2.getSHCData'
import getSymptoms from '@salesforce/apex/SHC_Helper2.getSymptoms'
import getFiles from '@salesforce/apex/SHC_Helper2.getFiles'
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
export default class ShcEditable extends NavigationMixin(LightningElement) {
    @api recordId
    @api isEdit =false
    @api isClone =false
    @api isNewBiz = false
    interiorSymptomMap = new Map()
    @track interiorSymptomList = []
    exteriorSymptomMap = new Map()
    @track exteriorSymptomList = []
    @track showSpinner = false;

    smartCareMap = new Map();
    smarCareList = [];
    shcId = ''

    @wire(getDependentPicklistValues, { objName: 'Health_Card_Observation__c', dependentField: 'Symptom__c', seletedControllingOption: 'Symptoms of Interior Surfaces' })
    symptomTypeOptions
    @wire(getDependentPicklistValues, { objName: 'Health_Card_Observation__c', dependentField: 'Symptom__c', seletedControllingOption: 'Symptoms of Exterior Surfaces' })
    symptomsExterior
    @wire(getDependentPicklistValues, { objName: 'Health_Card_Observation__c', dependentField: 'Symptom__c', seletedControllingOption: 'Smartcare Warranty Solutions' })
    smartCare

    @track fileList = []
    
    shcDetails = {
        oppId: '',
        obvInterior: '',
        obvExterior: '',
        obvSmartcare: '',
        files: [],
        mode :'',
        shcId: '',
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////
    symptomTypeOptionsN
    symptomsExteriorN
    @track smartCareDisplay = []
    //////////////////////////////////////////////////////////////////////////////////////////////////////
    connectedCallback() {
        this.showSpinner = true;
        this.shcDetails.oppId = this.recordId;

        if(this.isEdit){ //fetch previous data
        getSHCData({ shcId: this.recordId }).then(r => {
            this.shcDetails.obvInterior = (r.Interior_Surface_Observations__c === undefined) ? '' : r.Interior_Surface_Observations__c
            this.shcDetails.obvExterior = (r.Exterior_Surface_Observations__c === undefined) ? '' : r.Exterior_Surface_Observations__c
            this.shcDetails.obvSmartcare = (r.SmartCare_Observations__c === undefined) ? '' : r.SmartCare_Observations__c
           
        })
        
        getDependentPicklistValues({ objName: 'Health_Card_Observation__c', dependentField: 'Symptom__c', seletedControllingOption: 'Symptoms of Interior Surfaces' })
            .then(result => {
                this.symptomTypeOptionsN = result;
                getSymptoms({ shcId: this.recordId, surfaceType: 'Symptoms of Interior Surfaces' })
                    .then(r => {
                        for (let i = 0; i < r.length; i++) { //iterating over areas
                            let symCollection = []
                            for (let j = 0; j < r[i].symptoms.length; j++) { ///iterating symptoms of an area
                                let symObj = {
                                    index: i,
                                    type: r[i].symptoms[j].symptomType,
                                    area: r[i].area,
                                    checked: true,
                                    affectedArea: r[i].symptoms[j].affectedArea,
                                    severity: r[i].symptoms[j].severity,
                                    recoProduct : r[i].symptoms[j].recoProduct,
                                    addProduct : r[i].symptoms[j].addProduct
                                }
                                symCollection.push(symObj)
                            }
                            let symDisplayList = []
                            for (let i = 0; i < this.symptomTypeOptionsN.length; i++) symDisplayList.push({ label: this.symptomTypeOptionsN[i], severity: '', affectedArea: undefined, checked: false })

                            for (let i = 0; i < symCollection.length; i++) {
                                for (let j = 0; j < symDisplayList.length; j++) {
                                    if (symDisplayList[j].label === symCollection[i].type) {
                                        symDisplayList[j].severity = symCollection[i].severity
                                        symDisplayList[j].affectedArea = symCollection[i].affectedArea
                                        symDisplayList[j].checked = true
                                        symDisplayList[j].recoProduct = symCollection[i].recoProduct
                                        symDisplayList[j].addProduct = symCollection[i].addProduct
                                    }
                                }
                            }

                            this.interiorSymptomMap.set(i, { index: i, Area: r[i].area, tIndex: i.toString(), symptomCollection: symCollection, symptomDisplay: symDisplayList })
                            this.interiorSymptomList = []
                            for (let [key, value] of this.interiorSymptomMap) {
                                if (value !== undefined) this.interiorSymptomList.push(value)
                            }

                        }

                    })



            })

        getDependentPicklistValues({ objName: 'Health_Card_Observation__c', dependentField: 'Symptom__c', seletedControllingOption: 'Symptoms of Exterior Surfaces' })
            .then(result => {
                this.symptomsExteriorN = result;
                getSymptoms({ shcId: this.recordId, surfaceType: 'Symptoms of Exterior Surfaces' })
                    .then(r => {
                        for (let i = 0; i < r.length; i++) { //iterating over areas
                            let symCollection = []
                            for (let j = 0; j < r[i].symptoms.length; j++) { ///iterating symptoms of an area
                                let symObj = {
                                    index: i,
                                    type: r[i].symptoms[j].symptomType,
                                    area: r[i].area,
                                    checked: true,
                                    affectedArea: r[i].symptoms[j].affectedArea,
                                    severity: r[i].symptoms[j].severity,
                                    recoProduct : r[i].symptoms[j].recoProduct,
                                    addProduct : r[i].symptoms[j].addProduct
                                }
                                symCollection.push(symObj)
                            }
                            let symDisplayList = []
                            for (let i = 0; i < this.symptomsExteriorN.length; i++) symDisplayList.push({ label: this.symptomsExteriorN[i], severity: '', affectedArea: undefined, checked: false })

                            for (let i = 0; i < symCollection.length; i++) {
                                for (let j = 0; j < symDisplayList.length; j++) {
                                    if (symDisplayList[j].label === symCollection[i].type) {
                                        symDisplayList[j].severity = symCollection[i].severity
                                        symDisplayList[j].affectedArea = symCollection[i].affectedArea
                                        symDisplayList[j].checked = true
                                        symDisplayList[j].recoProduct = symCollection[i].recoProduct
                                        symDisplayList[j].addProduct = symCollection[i].addProduct
                                    }
                                }
                            }

                            this.exteriorSymptomMap.set(i, { index: i, Area: r[i].area, tIndex: i.toString(), symptomCollection: symCollection, symptomDisplay: symDisplayList })
                            this.exteriorSymptomList = []
                            for (let [key, value] of this.exteriorSymptomMap) {
                                if (value !== undefined) this.exteriorSymptomList.push(value)
                            }

                        }

                    })



            })

        getDependentPicklistValues({ objName: 'Health_Card_Observation__c', dependentField: 'Symptom__c', seletedControllingOption: 'Smartcare Warranty Solutions' })
            .then(result => {
                for (let i = 0; i < result.length; i++) this.smartCareMap.set(result[i], '');
                getSymptoms({ shcId: this.recordId, surfaceType: 'Smartcare Warranty Solutions' })
                    .then(rSym => {
                        for (let i = 0; i < rSym.length; i++) this.smartCareMap.set(rSym[i].area, rSym[i].reco)
                        for (let [key, value] of this.smartCareMap) {
                            this.smartCareDisplay.push({ label: key, value: value })
                        }
                      
                    })

            })

            getFiles({shcId: this.recordId})
            .then(result =>{
                for(let i=0; i<result.length; i++){
                    this.fileList.push({docId: result[i].docId , name: result[i].name, index: i, isExisting : true}) 
                }
               
                if(result.length >= 10) this.disableFiles =true
            })

        }

       
        this.showSpinner = false;
    }



    @track showPostSave = false;

    @wire(getDependentPicklistValues, { objName: 'Health_Card_Observation__c', dependentField: 'Symptom__c', seletedControllingOption: 'Smartcare Warranty Solutions' })
    smartCare
    value = '';

    handleFileName(event){
        this.fileList[parseInt(event.currentTarget.dataset.index)].name = event.target.value;
     
    }
    handleRemoveFile(event){
        if(!this.isEdit && !this.isClone || (this.isEdit && !this.isClone) || (this.isClone && !this.fileList[event.currentTarget.dataset.index].isExisting)){
            deleteFile({ cdId: event.target.name }) 
            
        }
        this.fileList.splice(parseInt(event.currentTarget.dataset.index), 1);
        for(let i=0; i< this.fileList.length; i++){
            this.fileList[i].index = i+1
        }
        
        if(this.fileList.length >=10) //size=10 
        this.disableFiles =true;
        else this.disableFiles =false;
    }
    disableFiles =false;
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        let index = this.fileList.length
        if(index ===9) //size=10 
        this.disableFiles =true;
        else this.disableFiles =false;
        const name =  uploadedFiles[0].name.split('.');
        this.fileList.push({docId: uploadedFiles[0].documentId , name: name[0], index: index, isExisting: false})
        console.log(this.fileList)
    }

    handleObvChange(e) {
        if (e.target.name === 'interior') this.shcDetails.obvInterior = e.detail.value
        else if (e.target.name === 'exterior') this.shcDetails.obvExterior = e.detail.value
        else this.shcDetails.obvSmartcare = e.detail.value
        // console.log(this.shcDetails)
    }
    sendToOpportunity(event) {
        //  console.log(event.target.name)
        let toastMsg = ''
        if (event.target.name === 'Payment')
            toastMsg = 'Payment Link sent to customer via SMS & Email';
        else toastMsg = event.target.name + ' sent to customer';
        sendToCustomer({
            shcId: this.shcId,
            medium: event.target.name,
            url: this.publicURL,
            objName: 'site_health_card__c'
        }).then(r => {
            this.newToast('Success', toastMsg, 'success')
        })
            .catch(e => {
                this.newToast('Error Occured', 'An unexpected error occured.', 'error')
            })
    }
    download(e) {
        let fileURL = ''
        if (e.target.name === 'Download')
            fileURL = this.downloadURL
        else fileURL = this.publicURL

        //  console.log(this.downloadURL)
        //  console.log(this.publicURL)
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: fileURL
            }
        }, false);
    }


    openSHCRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {

                recordId: this.shcId,
                objectApiName: 'Site_Health_Card__c',
                actionName: 'view',
            },

        });

    }

    contentVerionId = ''
    publicURL = ''
    downloadURL = ''

    incompleteMsg(areaName) {
        this.newToast('Symptoms Missing', 'Please select at least one symptom for ' + areaName, 'error');
        this.showSpinner = false;
    }
    save(event) {

        this.showSpinner = true
        ////////////////////////////////////one symptom seleted validation////////////////////////////////
        let oneSmartCareSelected = false;
        for (let [key, value] of this.smartCareMap) {
            if (value !== '' && value !== undefined) {
                oneSmartCareSelected = true;
                break;
            }
        }
        if (this.interiorSymptomList.length === 0 && this.exteriorSymptomList.length === 0
            && oneSmartCareSelected === false) {
            this.newToast('Symptoms Missing', 'Please select at least one symptom for Interior/Exterior Surface or SmartCare Warranty to proceed', 'error');
            this.showSpinner = false;
            return
        }

        /////////////////////////////////////area blank validation/////////////////////////////////////
        const isInputsCorrect = [...this.template.querySelectorAll("lightning-input")]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (!isInputsCorrect) {
            
            this.newToast('Fields Missing', 'Please fill all Area Names and File Names', 'error');
            this.showSpinner = false;
            return;
        }
        //////////////////////////////////// interior checkbox validation/////////////////////////////

        for (let [key, value] of this.interiorSymptomMap) {
            //let collection = value.symptomCollection
            if (value !== undefined) {
                if (value.symptomCollection === undefined || value.symptomCollection.length === 0) {
                    this.incompleteMsg(value.Area)
                    return //return because error
                }
                else {
                    let oneSymptomSelected = false;
                    for (let i = 0; i < value.symptomCollection.length; i++) {
                        if (value.symptomCollection[i].checked) {
                            oneSymptomSelected = true
                            break;
                        }
                    }
                    if (oneSymptomSelected === false) {
                        this.incompleteMsg(value.Area)
                        return //return because no symptom selected
                    }
                }
            }
        }
        ///////////////////////////////////////exterior checkbox validation////////////////////////////

        for (let [key, value] of this.exteriorSymptomMap) {
            //let collection = value.symptomCollection
            if (value !== undefined) {
                if (value.symptomCollection === undefined || value.symptomCollection.length === 0) {
                    this.incompleteMsg(value.Area)
                    return //return because error
                }
                else {
                    let oneSymptomSelected = false;
                    for (let i = 0; i < value.symptomCollection.length; i++) {
                        if (value.symptomCollection[i].checked) {
                            oneSymptomSelected = true
                            break;
                        }
                    }
                    if (oneSymptomSelected === false) {
                        this.incompleteMsg(value.Area)
                        return //return because no symptom selected
                    }
                }
            }
        }

        /////////////////////////////symptom fields validation///////////////////////////////////////
        let elements = this.template.querySelectorAll("c-symptom")
        for (let i = 0; i < elements.length; i++) {
            let x = elements[i].checkValidity()
            if (x.validity === false) {
                this.newToast('Required Fields Missing', 'Please complete all required fields for ' + x.area, 'error');
                this.showSpinner = false;
                return;
            }
        }
        ///////////////////////////////////////////////////////////////////////////////////
        
        let finalList = []
        
        for (let [key, value] of this.interiorSymptomMap) {
            if (value !== undefined) {
                for (let i = 0; i < value.symptomCollection.length; i++) {
                    if (value.symptomCollection[i].checked) {
                        
                        finalList.push({
                            area: value.Area,
                            index: value.symptomCollection[i].index,
                            mainType: 'Symptoms of Interior Surfaces',
                            //mainType: 'Symptoms of Interior Surfaces',
                            symptomType: value.symptomCollection[i].type,
                            observation: value.symptomCollection[i].observation,
                            severity: value.symptomCollection[i].severity,
                            affectedArea: value.symptomCollection[i].affectedArea,
                            files: value.symptomCollection[i].files,
                            reco: value.symptomCollection[i].reco,
                            recoProduct : value.symptomCollection[i].recoProduct,
                            addProduct : value.symptomCollection[i].addProduct
                        })
                    }

                }
            }

        }
       
        for (let [key, value] of this.exteriorSymptomMap) {
            if (value !== undefined) {
                for (let i = 0; i < value.symptomCollection.length; i++) {
                    if (value.symptomCollection[i].checked) {
                        //  console.log('files in collection')
                        //  console.log(value.symptomCollection[i].files)
                        finalList.push({
                            area: value.Area,
                            index: value.symptomCollection[i].index,
                            mainType: 'Symptoms of Exterior Surfaces',
                            symptomType: value.symptomCollection[i].type,
                            observation: value.symptomCollection[i].observation,
                            severity: value.symptomCollection[i].severity,
                            affectedArea: value.symptomCollection[i].affectedArea,
                            files: value.symptomCollection[i].files,
                            reco: value.symptomCollection[i].reco,
                            recoProduct : value.symptomCollection[i].recoProduct,
                            addProduct : value.symptomCollection[i].addProduct
                        })
                    }
                }

            }
            // finalList.push(this.processValues(value, ))
        }
       
        for (let [key, value] of this.smartCareMap) {
            finalList.push({
                mainType: 'Smartcare Warranty Solutions',
                symptomType: key,
                reco: value,

            })

        }

        let filesFinal = []
        for (let i = 0; i < this.fileList.length; i++) {
            if (this.fileList[i].docId !== '') filesFinal.push({docId: this.fileList[i].docId, name: this.fileList[i].name, isExisting: this.fileList[i].isExisting})
        }

        if(this.isNewBiz) this.shcDetails.mode = 'newBiz'
        else if(this.isClone) this.shcDetails.mode ='clone'
        else if(this.isEdit)  this.shcDetails.mode ='edit'
        else  this.shcDetails.mode ='new'
        this.shcDetails.shcId =this.recordId;
        this.shcDetails.files = filesFinal;
        createSHC({
            swList: finalList,
            shcW: this.shcDetails
        }).then(result => {
            this.shcId = result;
            this.showPostSave = true;
            saveHealthCard({
                shcId: result,
                objName: 'site_health_card__c'
            }).then(result => {
               
                this.contentVerionId = result.contentDocumentID;
                this.publicURL = result.publicURL;
                this.downloadURL = result.downloadURL
                
                this.newToast('Success!', 'Site Health Card Created Successfully', 'success')
                this.showSpinner = false;
            }).catch(error => {
                this.newToast('Error!', 'An unexpected error occured!', 'error')
                this.showSpinner = false;
                console.log(JSON.stringify(error))
            })


        }).catch(error => {
            this.newToast('Error!', 'An unexpected error occured!', 'error')
            console.log(JSON.stringify(error))
            this.showSpinner = false
        })
    
    }
    handleSmartCare(e) {
    this.smartCareMap.set(e.target.name, e.detail.value)
     }
    handleChildChange(e) {

        if (e.detail.index !== undefined) {
            let symObj = {
                index: e.detail.index,
                type: e.detail.type,
                area: e.detail.area,
                checked: e.detail.checked,
                observation: e.detail.observation,
                affectedArea: e.detail.affectedArea,
                severity: e.detail.severity,
                files: e.detail.files,
                reco: e.detail.reco,
                recoProduct : e.detail.recoProduct,
                addProduct : e.detail.addProduct

            }
            if (e.detail.intext === 'int') {
                let mapVal = this.interiorSymptomMap.get(parseInt(e.detail.index));
                let tempObj = mapVal.symptomCollection
                let isUpdated = false;
                for (let i = 0; i < tempObj.length; i++) {
                   if (tempObj[i].type === symObj.type) {
                        tempObj[i] = symObj;
                        isUpdated = true
                        break
                    }
                }
                if (!isUpdated) tempObj.push(symObj)
                mapVal.symptomCollection = tempObj;
               
                console.log(mapVal.symptomCollection)
                this.interiorSymptomMap.set(parseInt(e.detail.index), mapVal);
               
                console.log(this.interiorSymptomMap)
            }
            else {
                let mapVal = this.exteriorSymptomMap.get(parseInt(e.detail.index));
                let tempObj = mapVal.symptomCollection
                let isUpdated = false;
                for (let i = 0; i < tempObj.length; i++) {
                    
                    if (tempObj[i].type === symObj.type) {
                        tempObj[i] = symObj;
                        isUpdated = true
                        break
                    }
                }
                if (!isUpdated) tempObj.push(symObj)
                mapVal.symptomCollection = tempObj;
                this.exteriorSymptomMap.set(parseInt(e.detail.index), mapVal);
            }
        }

    }

    disableInterior = false;
    disableExterior = false;

    add(e) {
        if (e.currentTarget.dataset.type === 'interior') {
            let x = this.interiorSymptomMap.size
            if (e.currentTarget.dataset.ad === 'a') {
                this.interiorSymptomMap.set(x, { index: x, Area: 'New Area', tIndex: x.toString(), symptomCollection: [] })
            }
            else {
               
                this.interiorSymptomMap.set(parseInt(e.currentTarget.dataset.index), undefined)
            }
            this.interiorSymptomList = []
            for (let [key, value] of this.interiorSymptomMap) {
                if (value !== undefined) this.interiorSymptomList.push(value)

            }

            if (this.interiorSymptomList.length === 4) this.disableInterior = true;
            else this.disableInterior = false

        }
        else {
            let x = this.exteriorSymptomMap.size
            if (e.currentTarget.dataset.ad === 'a') {
                this.exteriorSymptomMap.set(x, { index: x, Area: 'New Area', tIndex: x.toString(), symptomCollection: [] })
            }
            else {
                
                this.exteriorSymptomMap.set(parseInt(e.currentTarget.dataset.index), undefined)
            }
            this.exteriorSymptomList = []
            for (let [key, value] of this.exteriorSymptomMap) {
                if (value !== undefined) this.exteriorSymptomList.push(value)

            }
            if (this.exteriorSymptomList.length === 4) this.disableExterior = true;
            else this.disableExterior = false

        }


    }
 
    handleChange(e) {

        if (e.currentTarget.dataset.type === 'interior') {
            let temp = this.interiorSymptomMap.get(parseInt(e.target.name))
            temp.Area = e.target.value
            this.interiorSymptomMap.set(parseInt(e.target.name), temp)
            this.interiorSymptomList = []
            for (let [key, value] of this.interiorSymptomMap) {
                if (value !== undefined) this.interiorSymptomList.push(value)
            }
        }
        else {
            let temp = this.exteriorSymptomMap.get(parseInt(e.target.name))
            temp.Area = e.target.value
            this.exteriorSymptomMap.set(parseInt(e.target.name), temp)
            this.exteriorSymptomList = []
            for (let [key, value] of this.exteriorSymptomMap) {
                if (value !== undefined) this.exteriorSymptomList.push(value)
            }
        }

    }


    get acceptedFormats() {
        return ['.png', '.jpg', '.jpeg'];
    }
    reset() {
       
        window.location.reload();
        //eval("$A.get('e.force:refreshView').fire();");
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