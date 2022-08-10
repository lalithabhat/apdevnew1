import { LightningElement,api,track,wire } from 'lwc';

export default class SlotLWC extends LightningElement {
    @api slotList=[];
    @api selectedSlot_Child;
    @api selectedSlot_Date_Child;
    
    selectSlots(event){
        //event.preventDefault();
        const selectedOption = event.detail.value;
        this.selectedSlot_Child = selectedOption;        
        this.selectedSlot_Date_Child = event.target.dataset.id;
        console.log('selectedSlot::'+this.selectedSlot_Child);
        console.log('selectedDate::'+this.selectedSlot_Date_Child);
        const detail = {};
        detail["value"] = this.selectedSlot_Child;
        detail["label"] = this.selectedSlot_Date_Child;
        const selectedEvent = new CustomEvent("slotvaluechange", {
            detail: detail
          });
      
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);
    }

    @api
    getSlotFromChild(){
        console.log('inside child::'+this.selectedSlot_Child);
        return this.selectedSlot_Child;
    }

    @api
    getSlotDateFromChild(){
        console.log('inside child::'+this.selectedSlot_Date_Child);
        return this.selectedSlot_Date_Child;
    }
}