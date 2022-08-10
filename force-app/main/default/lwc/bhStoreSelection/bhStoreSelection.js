import { LightningElement,api,wire } from 'lwc';
import getStore from '@salesforce/apex/AP_BHStoreManagementService.getStore';

const actions = [
    { label: 'Show details', name: 'show_details', value:'storeid'}
];
const columns = [
    { label: 'Store' , fieldName: 'storename' },
    { label: 'Match', fieldName: 'weightage' },
   /* {type: "button", typeAttributes: {
        label: 'Show Details',
        name: 'show_details',
        title: 'Show details',
        disabled: false,
        value: 'storeid',
        iconPosition: 'left',
    }},*/
    {
        type: 'action',
        typeAttributes: { rowActions: actions },
    },

];
export default class BhStoreSelection extends LightningElement {

@api recordId;
storedata;
columns=columns;
storeinfo=[];
store;
record;
table;
items;
options;
chk=false;
color;
color1;
color2;
color3;
color4;
color5;
color6;

showStore(){

    getStore({leadId:this.recordId})
    .then(data => {
    this.storedata=data;
    console.log(this.storedata);
    this.table=true;
    for(var i=0;i<this.storedata.length;i++){
       
           this.storeinfo[i]=this.storedata[i].storename+' is a '+storedata[i].weightage+' match';
    }
    console.log('storeinfo '+storeinfo);
    }).catch(e => {
        console.log(JSON.stringify(e));
    })
}
handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
        case 'show_details':
            this.showRowDetails(row);           
            break;
        default:
    }
}
//-------------------------------------------------------------------------------------------------//

showRowDetails(row) {
    this.record = row;
   
  this.store=this.record.storeid;
    console.log(this.store);
    for(var i=0;i<this.storedata.length;i++){
        if(this.storedata[i].storeid==this.store){
           this.items=this.storedata[i].items;
          
        }
    }
   if(this.items.includes('Furniture')==true){
    this.color1=true;
    this.color='"slds-align_absolute-center slds-var-m-around_large greencolor"';
   }
   if(this.items.includes('Furnishing')==true){
    this.color2=true;
   }
   if(this.items.includes('Lights')==true){
    this.color3=true;
   }
   if(this.items.includes('Home Automation')==true){
   this.color4=true;
   }
   if(this.items.includes('Rugs')==true){
    this.color5=true;
   }
   if(this.items.includes('Madeups')==true){
    this.color6=true;
   }
    this.chk=true;
    console.log(this.items);
}


}