import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyTeam from '@salesforce/apex/MyTeam_View_Controller.getMyTeam'
// const columns = [
//     {label: 'Name', fieldName: 'name', sortable: true,initialWidth: 150},
//     { label: 'Position Id', fieldName: 'positionId', initialWidth: 100},
//     { label: 'Dealer', fieldName: 'dealer', sortable: true,initialWidth: 200 },
//     { label: 'Role', fieldName: 'role', sortable: true,initialWidth: 80 },
//     { label: 'MTD Value', fieldName: 'mtd', sortable: true, type: 'currency', initialWidth: 80 },
//     { label: 'YTD Value', fieldName: 'ytd', sortable: true, type: 'currency', initialWidth: 80 },
// ];


export default class MyTeamView extends NavigationMixin (LightningElement) {
   // contacts = [{ name: 'Harshal' }, { name: 'Surya' }]
    error
    noData =false
    data //= data;
    //columns = columns;
    @wire(getMyTeam)
    wiredContacts({ error, data }) {
        if (data) {
            this.data = data;
            if(data.length ===0) this.noData =true
            this.error = undefined;
        } else if (error) { 
            this.error = error;
            this.data = undefined;
            console.log('My Team View Error '+JSON.stringify(error))
        }
      //  console.log(this.contacts)
    }

    handleClick(e){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Update_Contacts__c'
            },
            state: {
                'ContactId': e.target.dataset.id
               }
        });
    }


    // sortBy(field, reverse, primer) {
    //     const key = primer
    //         ? function (x) {
    //             return primer(x[field]);
    //         }
    //         : function (x) {
    //             return x[field];
    //         };

    //     return function (a, b) {
    //         a = key(a);
    //         b = key(b);
    //         return reverse * ((a > b) - (b > a));
    //     };
    // }

    // onHandleSort(event) {
    //     const { fieldName: sortedBy, sortDirection } = event.detail;
    //     const cloneData = [...this.data];

    //     cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
    //     this.data = cloneData;
    //     this.sortDirection = sortDirection;
    //     this.sortedBy = sortedBy;
    // }
}