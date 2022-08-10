import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
/*import getLead from '@salesforce/apex/Get_SA_Available_Slot.getLead'; 
import getCAFromId from '@salesforce/apex/Get_SA_Available_Slot.getCAFromId'; 
import getAvailableSlots from '@salesforce/apex/Get_SA_Available_Slot.getAvailableSlots';
import saveEvent from '@salesforce/apex/Get_SA_Available_Slot.saveEvent';
import getSAFromId from '@salesforce/apex/Get_SA_Available_Slot.getSAFromId';
import getSAFromPincode from '@salesforce/apex/Get_SA_Available_Slot.getSAFromPincode';
import get_CA_Slots from '@salesforce/apex/Get_SA_Available_Slot.get_CA_Slots'; */
import isCalendarBlocked from '@salesforce/apex/Get_SA_Available_Slot.isCalendarBlocked';
import getContactList from '@salesforce/apex/Get_SA_Available_Slot.getContactList';
import getSlots from '@salesforce/apex/Get_SA_Available_Slot.getSlots';
import getCAList from '@salesforce/apex/Get_SA_Available_Slot.getCAList';
import bookSlot from '@salesforce/apex/Get_SA_Available_Slot.bookSlot';
import assignCAWithoutAppointmentApex from '@salesforce/apex/Get_SA_Available_Slot.assignCAWithoutAppointmentApex';
import checkDateValidation from '@salesforce/apex/Get_SA_Available_Slot.checkDateValidation';
import deleteAppointment from '@salesforce/apex/Get_SA_Available_Slot.deleteAppointment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Lead.Status';
import OWNERID_FIELD from '@salesforce/schema/Lead.OwnerId';
import ID_FIELD from '@salesforce/schema/Lead.Id'
import STARTDATE_FIELD from '@salesforce/schema/Lead.Last_Appointment_Start_Date_Time__c';
import ENDDATE_FIELD from '@salesforce/schema/Lead.Last_Appointment_End_Date_Time__c';
import DECLINEDREASON_FIELD from '@salesforce/schema/Lead.Reason_For_SA_Declined__c';
import DECLINED_FIELD from '@salesforce/schema/Lead.SA_Declined__c';
import DEALER_FIELD from '@salesforce/schema/Lead.Dealer__c';
import ASSIGNWITHOUT_FIELD from '@salesforce/schema/Lead.Assign_without_Appointment__c';
import ASSIGNWITHOUDATE_FIELD from '@salesforce/schema/Lead.Assign_Without_Appointment_Datetime__c';
import ASSIGNTO_FIELD from '@salesforce/schema/Lead.Assigned_To__c';
import RESCHEDULEDATE_FIELD from '@salesforce/schema/Lead.Appointment_Rescheduled_On__c';
import LEAD_OBJECT from "@salesforce/schema/Lead";

import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import updateLeadApex from "@salesforce/apex/Get_SA_Available_Slot.updateLeadApex"
let i = 0, j = 0, contactMap;
export default class Calendar_Scheduler extends NavigationMixin(LightningElement) {
    @api recordId;
    @track Lead;
    @track items = [];
    @api selectedSAId;
    @api selectedDate;
    @api activeTab;
    @track VisitDate = null;
    @track availableSlotsList = [];
    @track slotsForRadio = [];
    @track selectedSlot;
    @track isSuccess = false;
    @track slot_Not_Available = false;
    @track isError = false;
    @track is_SA_Visit = false;
    @track is_CA_Visit = false;
    @track alrady_Caledar_Blocked = false;
    @track existing_EventList = false;
    @track CARecord;
    @track CAName;
    @track dealerName;
    @api LeadAPI = 'Lead';
    @api sourceField = 'Reason_For_SA_Declined__c';
    @track SADeclinedreason;


    @track No_SA = false;
    @track BU = false;
    @track NO_BHS_USER = false;
    @track IS_BHS = false;
    @track IS_SLEEK = false;
    @track No_CA = false;
    @track todayDate;
    //@track lastDate;
    @track isValidDate;
    @track lastEvent_OwnerName;
    @track lastEvent_StartDateTime;
    @track lastEvent_EndDateTime;
    @track lastEvent_Mobile = 'Mobile Number: ';
    @track lastEvent_Id;
    @track isReschduleClick = false;
    @track eventId;
    @track selectedSlot_Date;
    @track mapData = [];
    @track userType;
    @track no_User_For_Pincode = false;
    @track is_SA = false;
    @track is_CA = false;
    @track wiredAccountList = [];


    constructor() {
        super();
        var d = new Date();
        var day = d.getDate();
        var month = d.getMonth() + 1;
        var year = d.getFullYear();
        var fDate = year + '-' + month + '-' + day;
        console.log('fDate::' + fDate);
        this.todayDate = fDate;

        /*var max_Date = new Date(); // Now
        max_Date.setDate(max_Date.getDate() + 60);
        var day2 = d.getDate();
        var month2 = max_Date.getMonth() + 1;
        var year2 = max_Date.getFullYear();
        var fDate2 = year2 + '-' + month2 + '-' +day2;
        console.log('fDate2::'+fDate2);
        this.lastDate = fDate2;*/
    }
    /* connectedCallback() {
         alert('hi::'+this.recordId);
         //this.exisitngEventDetails();
     }*/
    startSchedule(event) {
        console.log('inside startSchedule::');
        contactMap = new Map();
        getContactList({ lId: this.recordId })
            .then(result => {
                console.log('inside contact List method::');
                for (i = 0; i < result.userList.length; i++) {
                    this.items = [...this.items, {
                        value: result.userList[i].SA__c, label: result.userList[i].SA__r.Name + ' | ' + result.userList[i].Role__c + ' | P' +
                            result.userList[i].Priority__c + ' | ' + result.userList[i].SA__r.MobilePhone
                    }];
                    contactMap.set(result.userList[i].SA__c, result.userList[i]);
                }
                this.BU = result.BU;
                console.log('BU::' + this.BU);
                //this.activeTab = 'tab1';
                console.log('items list in Pincode::: ' + this.items.length);
                if (this.BU == 'SPS') {
                    if (this.items.length == 0) {
                        this.No_SA = true;
                        this.fetchCA();
                    } else if (this.items.length > 0) {
                        this.selectedSAId = this.items[0].value;
                        //this.dealerName = contactMap.get(String(this.selectedSAId)).SA__r.AccountId;
                        this.userType = 'SA';
                        this.getSlotForSA();
                        this.is_SA = true;
                    }
                }

                if (this.BU == 'BHS') {
                    this.IS_BHS = true;
                    if (this.items.length == 0) {
                        this.NO_BHS_USER = true;
                        //this.No_SA = true;
                        this.no_User_For_Pincode = true;
                    } else if (this.items.length > 0) {
                        this.selectedSAId = this.items[0].value;
                        this.userType = 'BHS';
                        this.getSlotForBHS();
                    }
                }

                if (this.BU == 'SLEEK') {
                    this.IS_SLEEK = true;
                }

                if (this.alrady_Caledar_Blocked) {
                    this.alrady_Caledar_Blocked = false;
                }



                /* if(this.BU == 'SPS' && this.items.length == 0){
                     this.No_SA = true;
                 }
                 if(this.BU == 'BHS'){
                     this.IS_BHS = true;
                     if(this.items.length == 0){
                         this.NO_BHS_USER = true;
                         this.No_SA = true;
                     }
                 }
                 if(this.BU == 'SLEEK'){
                     this.IS_SLEEK = true;
                 }
                 if(this.alrady_Caledar_Blocked){
                     this.alrady_Caledar_Blocked = false;
                     this.isReschduleClick = true;
                 }    */


            })
            .catch(error => {
                console.log('Errorured in get contact List method:- ' + error);
            });
    }

    resetValues(event) {
        console.log('inside resetValues method');
        this.items = [];
        this.selectedSAId = undefined;
        contactMap = new Map();
        this.BU = null;
        this.No_SA = false;
        this.IS_BHS = false;
        this.is_SA = false;
        this.is_CA = false;
        this.selectedDate = undefined;
        this.mapData = [];
        this.no_User_For_Pincode = false;
        this.CARecord = null;
        this.selectedSlot = null;
        this.SADeclinedreason = null;
        this.selectedSlot_Date = null;
        this.template.querySelector('.visitDate').value = null;
    }

    checkDate(event) {
        this.selectedDate = event.detail.value;
        //this.selectedSlot = null;
        //this.selectedSlot_Date = null;
        checkDateValidation({ appointment_Date: this.selectedDate })
            .then(result => {
                if (result == 'false') {
                    alert('Invalid Date. Value must be today or future date.');
                    this.isValidDate = false;
                } else {
                    this.isValidDate = true;
                    if (this.selectedSAId != null && this.selectedSAId != undefined) {
                      //  console.log('In date handler '+ this.template.querySelector('c-slot-L-W-C').selectedSlot)
                      //  this.template.querySelector('c-slot-L-W-C').selectedSlot = undefined;
                      //  this.template.querySelector('c-slot-L-W-C').selectedSlot_Date = undefined;
                        this.selectedSlot = undefined;
                        this.selectedSlot_Date = undefined;
                        if (this.userType == 'SA') {
                            this.getSlotForSA();
                        } else if (this.userType == 'CA') {
                            this.getSlotForCA();
                        } else if (this.userType == 'BHS') {
                            this.getSlotForBHS();
                        }
                    } else {
                        this.startSchedule();
                    }

                }
            })
            .catch(error => {
                console.log('Errorured in get slots for SA method:- ' + error);
            });
    }

    /* exisitngEventDetails(){
         //alert('inside exisitngEventDetails');
         //console.log('recordId::'+this.recordId);
         isCalendarBlocked({lId:this.recordId})
                         .then(result => {
                             this.existing_EventList = JSON.stringify(result);
                             this.existing_EventList = JSON.parse(this.existing_EventList);
                             if(this.existing_EventList.length > 0){
                                 console.log('eventList::'+this.existing_EventList.length);
                                 alert('eventList::'+this.existing_EventList.length);
                                 this.alrady_Caledar_Blocked = true;
                                 this.lastEvent_OwnerName = 'Assigned to: ' + this.existing_EventList[0].Owner.Name;
                                 this.lastEvent_StartDateTime = this.existing_EventList[0].StartDateTime;
                                 this.lastEvent_EndDateTime = this.existing_EventList[0].EndDateTime;
                                 this.lastEvent_Mobile = 'Mobile Number: ' + this.existing_EventList[0].Owner_Mobile_No__c;
                                 this.lastEvent_Id = this.existing_EventList[0].Id;
                                 this.eventId = this.existing_EventList[0].Id;
                                 this.activeTab = 'tab4';
                             }else{
                                 this.alrady_Caledar_Blocked = false;
                             }
                         })
                         .catch(error => {
                             console.log('Errorured in exisitngEventDetails method:- '+error);
                         });
     }*/




    //////// Get existng calendar
    /*@wire(isCalendarBlocked, {lId:'$recordId' })
    isCalendarBlocked({data, error}){
           if(data){
               //this.alrady_Caledar_Blocked = data;
               this.existing_EventList = JSON.stringify(data);
               this.existing_EventList = JSON.parse(this.existing_EventList);
               //alert(this.existing_EventList.length);
               if(this.existing_EventList.length > 0){
                   this.alrady_Caledar_Blocked = true;
                   //alert('owner1::'+this.existing_EventList[0].Owner.Name);
                   //alert('owner2::'+this.existing_EventList[0].owner.Name);
                   this.lastEvent_OwnerName = 'Assigned to: ' + this.existing_EventList[0].Owner.Name;
                   this.lastEvent_StartDateTime = this.existing_EventList[0].StartDateTime;
                   this.lastEvent_EndDateTime = this.existing_EventList[0].EndDateTime;
                   this.lastEvent_Mobile = 'Mobile Number: ' + this.existing_EventList[0].Owner_Mobile_No__c;
                   this.lastEvent_Id = this.existing_EventList[0].Id;
                   this.eventId = this.existing_EventList[0].Id;
               }
           }else if (error) {
               this.error = error;
           }
       }   */

    @wire(isCalendarBlocked, { lId: '$recordId' })
    isCalendarBlocked(result) {
        //console.log('sizewwwwww:: '+this.existing_EventList.length);
        //this.alrady_Caledar_Blocked = data;
        this.wiredAccountList = result;
        //alert('hi'+result.data);
        if (result.data) {
            this.existing_EventList = result.data;
            if (this.existing_EventList.length > 0) {
                this.alrady_Caledar_Blocked = true;
                //alert('owner1::'+this.existing_EventList[0].Owner.Name);
                //alert('owner2::'+this.existing_EventList[0].owner.Name);
                this.lastEvent_OwnerName = 'Assigned to: ' + this.existing_EventList[0].Owner.Name;
                this.lastEvent_StartDateTime = this.existing_EventList[0].StartDateTime;
                this.lastEvent_EndDateTime = this.existing_EventList[0].EndDateTime;
                if (this.existing_EventList[0].Owner_Mobile_No__c != null && this.existing_EventList[0].Owner_Mobile_No__c != undefined) {
                    this.lastEvent_Mobile = 'Mobile Number: ' + this.existing_EventList[0].Owner_Mobile_No__c;
                }

                this.lastEvent_Id = this.existing_EventList[0].Id;
                this.eventId = this.existing_EventList[0].Id;
                this.resetValues();
            } else {
                this.alrady_Caledar_Blocked = false;
            }
        }

    }

    ////////// Get Lead Details
    /* @wire(getLead, {lId:'$recordId' })
     getLead({data, error}){
         
        if(data){
            //console.log('data::'+data);
            this.Lead = JSON.stringify(data);
            this.Lead = JSON.parse(this.Lead);
            //alert('inside lead method:: '+this.lead);
            console.log('Lead Name:'+this.Lead.Name);
            console.log('SA Name:'+this.Lead.SA_Name__c);
            console.log('SA_Declined__c:'+this.Lead.SA_Declined__c);
            console.log('CA_Name:'+this.Lead.CA_Name__c);
            if((this.Lead.SA_Name__c != null && this.Lead.SA_Name__c != undefined) && !this.Lead.SA_Declined__c){
                this.is_SA_Visit = true;
                console.log('inside SA::');
            }else if(this.Lead.CA_Name__c != null && this.Lead.CA_Name__c != undefined){
                this.is_CA_Visit = true;
                console.log('inside CA::');
            }
        
            
        }else if (error) {
            this.error = error;
            this.Lead = undefined;
        }
    }*/
    //////// Get SA List  
    /* ShowSA(event){
         console.log('SA Name in ShowSA:'+this.Lead.SA_Name__c);
         if(this.Lead.Multiple_SA__c){
             getSAFromPincode({pincode:this.Lead.Pincode__c})
                 .then(result => {
                        // this.availableSlotsList = JSON.stringify(result);
                        // this.availableSlotsList = JSON.parse(this.availableSlotsList);
                         //this.availableSlotsList = result;
                         for( i=0; i<result.length; i++) {
                              this.items = [...this.items ,{value: result[i].SA__c , label: result[i].SA__r.Name}];                                   
                          }  
                         this.activeTab = 'tab1';
                         console.log('items list in Pincode::: '+this.items.length);
                 })
                 .catch(error => {
                     console.log('Errorured in get SA From Pincode method:- '+error);
                 });
         }else{
             getSAFromId({sId:this.Lead.SA_Name__c})
                 .then(result => {
                         for( i=0; i<result.length; i++) {
                              this.items = [...this.items ,{value: result[i].Id , label: result[i].Name}];                                   
                          }  
                         this.activeTab = 'tab1';
                         console.log('items list in ID::: '+this.items.length);
                 })
                 .catch(error => {
                     console.log('Errorured in get SA From Id method:- '+error);
                 });
         }
     }
 
     showCA(event){
         //alert('hi::');
        // this.items = [...this.items ,{value: this.Lead.CA_Name__c , label: this.Lead.CA_Name__r.Name}];
        // this.activeTab = 'tab1';
        getCAFromId({cId:this.Lead.CA_Name__c})
             .then(result => {
                     for( i=0; i<result.length; i++) {
                             this.items = [...this.items ,{value: result[i].Id , label: result[i].Name}];                                   
                         }  
                     this.activeTab = 'tab1';
                     console.log('items list in ID::: '+this.items.length);
             })
             .catch(error => {
                 console.log('Errorured in get CA From Id method:- '+error);
             });
     }*/

    /* @wire(getSAList, { lId: '$recordId'})
      wiredContacts({ error, data }) {
          if (data) {
              for( i=0; i<data.length; i++) {
                 // console.log('id=' + data[i].Id);
                  this.items = [...this.items ,{value: data[i].Id , label: data[i].Name}];                                   
              }                
              this.error = undefined;
          } else if (error) {
              this.error = error;
              this.items = undefined;
          }
      }*/
    duummy(event) {
        alert('hi');
    }
    get statusOptions() {
        console.log('inside status options::' + this.items);
        return this.items;
    }
    selectSA(event) {
        const selectedOption = event.detail.value;
        this.selectedSAId = selectedOption;
        if (this.userType == 'SA') {
            this.getSlotForSA();
        } else if (this.userType == 'CA') {
            this.getSlotForCA();
        } else if (this.userType == 'BHS') {
            this.getSlotForBHS();
        }
    }


    getSlotForSA(event) {
        // alert('SA :'+this.selectedSAId);
        // alert('Date :'+this.selectedDate);
        this.slot_Not_Available = false;
        if (this.selectedSAId != null && this.selectedSAId != undefined && this.selectedSAId != '') {
            //var Selected_visit_Date = this.template.querySelector('.visitDate').value;
            //console.log('Selected_visit_Date::: '+Selected_visit_Date);
            if (this.selectedDate != null && this.selectedDate != undefined && this.selectedDate != '') {
                //  alert('hi');
                var role = contactMap.get(String(this.selectedSAId)).Role__c;
                getSlots({ userId: this.selectedSAId, role: role, appointment_Date: this.selectedDate, lId: this.recordId })
                    .then(result => {
                        console.log('result in get SA slot' + JSON.stringify(result))
                        //alert('result[0].noUser:: '+result[0].noUser);
                      if(result !== undefined){
                        if (result[0].noUser) {
                            this.no_User_For_Pincode = true;
                        } else {
                            this.no_User_For_Pincode = false;
                        }
                        this.availableSlotsList = JSON.stringify(result);
                        this.availableSlotsList = JSON.parse(this.availableSlotsList);
                        
                        console.log('available list::: ' + this.availableSlotsList.length);
                    
                        if (this.availableSlotsList.length == 0) {
                            this.slot_Not_Available = true;
                        }
                    }
                    else{
                        this.slot_Not_Available = true;
                    }
                        this.createSlotMap();
                    })
                    .catch(error => {
                        console.log('Errorured in get slots for SA method:- ' + error);
                    });


                /*if(this.is_SA_Visit){
                    getAvailableSlots({lId:this.Lead.Id, uId:this.selectedSAId,visitDate:Selected_visit_Date})
                        .then(result => {
                                this.availableSlotsList = JSON.stringify(result);
                                this.availableSlotsList = JSON.parse(this.availableSlotsList);
                                //this.availableSlotsList = result;
                                this.activeTab = 'tab2';
                                console.log('available list::: '+this.availableSlotsList.length);
                                if(this.availableSlotsList.length == 0){
                                    this.slot_Not_Available = true;
                                }
                        })
                        .catch(error => {
                            console.log('Errorured in get slots for SA method:- '+error);
                        });
                }else if(this.is_CA_Visit){
                    get_CA_Slots({cId:this.Lead.CA_Name__c, uId:this.selectedSAId, lId:this.Lead.Id, visitDate:Selected_visit_Date})
                    .then(result => {
                            this.availableSlotsList = JSON.stringify(result);
                            this.availableSlotsList = JSON.parse(this.availableSlotsList);
                            //this.availableSlotsList = result;
                            this.activeTab = 'tab2';
                            console.log('available list::: '+this.availableSlotsList.length);
                            if(this.availableSlotsList.length == 0){
                                this.slot_Not_Available = true;
                            }
                    })
                    .catch(error => {
                        console.log('Errorured in get slots for CA method:- '+error);
                    });
                }*/
            } else {
                alert('Please select Visit Date');
            }
        } else {
            alert('Please select SA');
        }
    }

    getSlotForCA(event) {
        if (this.selectedSAId != null && this.selectedSAId != undefined && this.selectedSAId != '') {
            //c/schedule_Appointment_LWCvar Selected_visit_Date = this.template.querySelector('.visitDate2').value;
            // console.log('Selected_visit_Date::: '+Selected_visit_Date);
            if (this.selectedDate != null && this.selectedDate != undefined && this.selectedDate != '') {
                //console.log('selected SA ID:: '+this.selectedSAId);
                //console.log('Lead ID:: '+this.Lead.Id);
                var role = 'CA';
                getSlots({ userId: this.selectedSAId, role: role, appointment_Date: this.selectedDate, lId: this.recordId })
                    .then(result => {
                        this.availableSlotsList = JSON.stringify(result);
                        this.availableSlotsList = JSON.parse(this.availableSlotsList);
                        //this.availableSlotsList = result;
                        //this.activeTab = 'tab3';
                        console.log('available list::: ' + this.availableSlotsList.length);
                        this.createSlotMap();
                    })
                    .catch(error => {
                        console.log('Errorured in get slots for CA method:- ' + error);
                    });
            } else {
                alert('Please select Visit Date');
            }
        } else {
            alert('Please select CA');
        }
    }

    getSlotForBHS(event) {
        if (this.selectedSAId != null && this.selectedSAId != undefined && this.selectedSAId != '') {
            //var Selected_visit_Date = this.template.querySelector('.visitDate').value;
            //console.log('Selected_visit_Date::: '+Selected_visit_Date);
            if (this.selectedDate != null && this.selectedDate != undefined && this.selectedDate != '') {
                // console.log('selected SA ID:: '+this.selectedSAId);
                //console.log('Lead ID:: '+this.Lead.Id);
                var role = 'BHS';
                getSlots({ userId: this.selectedSAId, role: role, appointment_Date: this.selectedDate, lId: this.recordId })
                    .then(result => {
                        this.availableSlotsList = JSON.stringify(result);
                        this.availableSlotsList = JSON.parse(this.availableSlotsList);
                        //this.availableSlotsList = result;
                        //this.activeTab = 'tab2';
                        console.log('available list::: ' + this.availableSlotsList.length);
                        this.createSlotMap();
                    })
                    .catch(error => {
                        console.log('Error occurred in get slots for BHS method:- ' + error);
                    });
            } else {
                alert('Please select Visit Date');
            }
        } else {
            alert('Please select User');
        }
    }

    fetchCA(event) {
        console.log('inside fetch CA Details');
        let tempAllRecords = JSON.stringify(this.CARecord);
        getCAList({ lId: this.recordId, CARecord: tempAllRecords })
            .then(result => {
                console.log('CA fetched Data:: ' + result);
                if (result != null && result != undefined) {
                    this.items = [];
                    this.userType = 'CA';
                    this.CARecord = JSON.stringify(result);
                    this.CARecord = JSON.parse(this.CARecord);
                    //this.activeTab = 'tab2';
                    this.CAName = 'CA Name: ' + this.CARecord.CA.Name;
                    this.selectedSAId = this.CARecord.CA_Contact.Id;
                    this.dealerName = this.CARecord.dealer.Id;
                    var phone = this.CARecord.phone;
                    this.items = [...this.items, {
                        value: this.CARecord.CA_Contact.Id, label: this.CARecord.CA.Name + ' | ' + 'CA' + ' | P1' +
                            ' | ' + phone
                    }];
                    this.is_SA = false;
                    this.is_CA = true;
                    this.getSlotForCA();
                } else {
                    console.log('inside no CA');
                    this.No_CA = true;
                    if (this.selectedSAId != null && this.selectedSAId != undefined && this.selectedSAId != '') {
                        //alert('No CAs available');
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Information',
                                message: 'No CAs are available',
                                variant: 'error'
                            })

                        );
                    } else {
                        this.no_User_For_Pincode = true;
                    }
                }
                this.No_SA = true;
            })
            .catch(error => {
                console.log('Errorured in fetch CA method:- ' + error);
            });
    }

    assignWithoutAppointment(event) {
        console.log('inside assignWithoutAppointment');
        assignCAWithoutAppointmentApex({ lId: this.recordId, userId: this.selectedSAId })
            .then(result => {
                // alert(result);
                if (result.message == 'Success') {
                    this.isSuccess = true;
                    //this.activeTab = 'tab6';
                    // this.dispatchEvent(
                    //     new ShowToastEvent({
                    //         title: 'Success',
                    //         message: 'User assigned successfully',
                    //         variant: 'success'
                    //     })
                    // );
                    this.updateLead('assignWithoutAppointment', result.userId, result.startTime, null);
                    //this.resetValues();
                    //refreshApex(this.wiredAccountList);
                } else {
                    this.isSuccess = false;
                    console.log(JSON.stringify(result.userId))
                    //this.activeTab = 'tab6';
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'User assigned Failed',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                this.isSuccess = false;
               
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'User assignment Failed.',
                        message:  error.body.message,
                        variant: 'error'
                    })
                );
            });
    }


    sourceChange(event) {
        console.log(event.detail.value)
        this.SADeclinedreason = event.detail.value;
        console.log(this.SADeclinedreason)

    }




    createSlotMap() {
        this.mapData = [];
        if (this.availableSlotsList.length > 0) {
            for (j = 0; j < this.availableSlotsList.length; j++) {
                this.slotsForRadio = [];
                let k = 0;
                for (k = 0; k < this.availableSlotsList[j].available_Slots.length; k++) {
                    this.slotsForRadio = [...this.slotsForRadio, { value: this.availableSlotsList[j].available_Slots[k], label: this.availableSlotsList[j].available_Slots[k] }];
                }
                this.mapData.push({ value: this.slotsForRadio, key: this.availableSlotsList[j].scheduleDate });
            }

        }
        //this.template.querySelector('c-slot-L-W-C').fromParent();
    }


    selectSlots(event) {
        //event.preventDefault();
        const selectedOption2 = event.detail.value;
        this.selectedSlot = selectedOption2;
        this.selectedSlot_Date = event.target.dataset.id;
        console.log('this.selectedSlot::' + this.selectedSlot);
        console.log('this.selectedSlot_Date::' + this.selectedSlot_Date);
        //alert('selected Date:'+event.detail.id);
        // alert('selectedSlot_Date::'+this.selectedSlot_Date);

    }

    getSelectedDetail(event) {
        console.log('value::' + event.detail.value);
        console.log('label::' + event.detail.label);
        this.selectedSlot = event.detail.value;
        this.selectedSlot_Date = event.detail.label;
    }

    bookSlot(event) {
        this.isSuccess = false;
        this.isError = false;
        //alert('date::'+this.selectedSlot_Date);
        /* if(this.template.querySelector('c-slot-L-W-C') != null && this.template.querySelector('c-slot-L-W-C') != undefined){
          this.selectedSlot = this.template.querySelector('c-slot-L-W-C').getSlotFromChild();
         }
         if(this.template.querySelector('c-slot-L-W-C') != null && this.template.querySelector('c-slot-L-W-C') != undefined){
          this.selectedSlot_Date = this.template.querySelector('c-slot-L-W-C').getSlotDateFromChild();
         }*/

        console.log('inside book slot method::' + this.selectedSlot);
        console.log('inside book slotDate method::' + this.selectedSlot_Date);
        if (this.selectedSlot != null && this.selectedSlot != undefined && this.selectedSlot != '' && this.selectedSlot_Date != null && this.selectedSlot_Date != undefined) {
            let tempRecord = JSON.stringify(this.selectedSlot);
            bookSlot({ lId: this.recordId, slot: this.selectedSlot, appointmentDate: this.selectedSlot_Date, userId: this.selectedSAId, SADeclinedReason: this.SADeclinedreason, isReschdule: this.isReschduleClick, eventId: this.eventId })
                .then(result => {
                    console.log('in book slot '+ JSON.stringify(result))
                    // alert(result);
                    if (result.message == 'Success') {
                        this.isSuccess = true;
                        refreshApex(this.wiredAccountList);
                        // this.dispatchEvent(
                        //     new ShowToastEvent({
                        //         title: 'Success',
                        //         message: 'Appointment scheduled successfully',
                        //         variant: 'success'
                        //     })
                        // );
                       this.updateLead('bookSlot', result.userId, result.startTime, result.endTime);
                    } 
                    else if(result.message ==='Booked By another Agent'){
                        this.isSuccess =false
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Slot booked by another User. Please try with another slot.',
                                variant: 'error'
                            })
                        );
                    }
                    else {
                        this.isSuccess = false;
                        //alert('Failed to booked slot. Some internal occurred');
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Failed to book slot. Internal error occurred',
                                variant: 'error'
                            })
                        );
                    }
                })
                .catch(error => {
                    //console.log('Errorured in Event Insertion:- '+error.body.message);
                    this.isSuccess = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Failed to book slot. Internal error occurred',
                            variant: 'error'
                        })
                    );
                });

        } else {
            alert('Please select Date and slot to process');
        }
    }

    close(event) {

        window.open('/' + this.recordId, '_parent');
    }

    modifyAppointment(event) {
        this.alrady_Caledar_Blocked = false;
        this.isReschduleClick = true;
        this.resetValues();
    }

    deleteAppointment(event) {
        console.log('inside deleteAppointment');
        deleteAppointment({ eventId: this.eventId, leadId: this.recordId })
            .then(result => {
                //alert(result);
                if (result == 'Success') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Appointment Cancelled',
                            variant: 'success'
                        })

                    );
                    refreshApex(this.wiredAccountList);
                    getRecordNotifyChange([{recordId: this.recordId}])

                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Failed to cancel.Internal error occurred',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to cancel. Internal error occurred',
                        variant: 'error'
                    })
                );
            });
    }

    viewRecord(event) {
        window.open('/' + this.lastEvent_Id, '_blank');
    }

    openCalendar(event) {
        window.open('/00U', '_blank');
    }

    restartLWC(event) {
        /*const navConfig = {
            type: "standard__component",
            attributes: {
              componentName: "c__Calendar_Schedular"
            },
            state: {
              c__recordId: this.recordId
            }
          };
      
          this[NavigationMixin.Navigate](navConfig);*/
        //eval("$A.get('e.force:refreshView').fire();");
        //alert('hii');
        if (this.isReschduleClick) {
            this.alrady_Caledar_Blocked = true;
            this.restartLWCInModify();
            //alert('bye');
        } else {
            this.resetValues();
        }
        //alert('ggg');
    }

    restartLWCInModify() {
        refreshApex(this.wiredAccountList);
        //this.alrady_Caledar_Blocked = true;
    }
    /* refreshComponent(event){
          alert('hi');
          eval("$A.get('event.force:refreshView').fire();");
          this.activeTab = 'tab4';
          alert('bye');
      }*/

    updateLead(method, userId, sTime, eTime) {

        console.log('stime '+ sTime +'etime '+ eTime + 'userId '+ userId)
        updateLeadApex({
            method: method,
            userId: userId,
            sTime: sTime,
            eTime: eTime,
            recordId: this.recordId,
            selectedSAId: this.selectedSAId,
            SADeclinedreason: this.SADeclinedreason,
            dealerName: this.dealerName
        })
            .then(r => {
                if(r ===''){
                console.log('lead updated in apex')
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Appointment scheduled successfully',
                        variant: 'success'
                    })
                );
                getRecordNotifyChange([{recordId: this.recordId}])
                }
                else{
                    console.log('error in lead update '+ r)
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Failed to book slot. Internal error occurred',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(e => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to book slot. Internal error occurred',
                        variant: 'error'
                    })
                );
                console.log('error in lead update '+ JSON.stringify(e))
            })
        
        
        //alert(method+userId+sTime+eTime);
        /*  const fields = {};
          fields[ID_FIELD.fieldApiName] = this.recordId;
          fields[OWNERID_FIELD.fieldApiName] = userId;
          fields[STATUS_FIELD.fieldApiName] = 'Allocation Done';
          fields[ASSIGNTO_FIELD.fieldApiName] = this.selectedSAId;
          
          if(method == 'bookSlot'){
              fields[STARTDATE_FIELD.fieldApiName] = sTime;
              fields[ENDDATE_FIELD.fieldApiName] = eTime;
          }
          if(method == 'assignWithoutAppointment'){
              fields[ASSIGNWITHOUT_FIELD.fieldApiName] = true;
              fields[ASSIGNWITHOUDATE_FIELD.fieldApiName] = sTime;
          }
          if(this.SADeclinedreason != null && this.SADeclinedreason != undefined){
              fields[DECLINED_FIELD.fieldApiName] = true;
          }
          console.log('decline reason'+ this.SADeclinedreason)
          fields[DECLINEDREASON_FIELD.fieldApiName] = this.SADeclinedreason;
          if(this.dealerName != null && this.dealerName != undefined){
              fields[DEALER_FIELD.fieldApiName] = this.dealerName;
          }
  
          const recordInput = {
              fields: fields
            };
            updateRecord(recordInput).then((record) => {
              //console.log(record);
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Success',
                      message: 'Lead record updated',
                      variant: 'success'
                  })
                  
              );
            });
              */
    }
}