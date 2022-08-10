import { LightningElement, api, track, wire } from 'lwc';
import addSurface from '@salesforce/apex/Quotation.addSurface';
import getProductDetails from '@salesforce/apex/Quotation.getProductDetails';
import getServiceName from '@salesforce/apex/Quotation.getServiceName';
import getProductCost from '@salesforce/apex/Quotation.getProductCost';
export default class SurfaceChildLWC extends LightningElement {
  @api quoteLineItemRecord;
  @api surfaceValues = [];
  @track selectedSurface;
  @track isShowModal = false;
  @track quoteLineItemRecordList = [];
  @api existingListSize;
  @api dealerId;
  @api tier;
  
  connectedCallback() {
    console.log('In surface callback ' + JSON.stringify(this.quoteLineItemRecord))
  }
  
  showModalBox(event) {
    this.isShowModal = true;
    this.selectedSurface = null;
  }

  get surfaceOptions() {

    return this.surfaceValues;
  }

  selectSurface(event) {
    const selectedOption = event.detail.value;
    this.selectedSurface = selectedOption;
    console.log('this.selectedSurface::' + this.selectedSurface);
    this.isShowModal = false;
    this.addSurface();
  }

  addSurface(event) {
    let tempRecord;
    addSurface({ room: this.quoteLineItemRecord.room, selectedSurface: this.selectedSurface, size: this.existingListSize })
      .then(result => {
        console.log(JSON.stringify(result))
        this.quoteLineItemRecordList.push(result);
        this.quoteLineItemRecordList = JSON.stringify(this.quoteLineItemRecordList);
        this.quoteLineItemRecordList = JSON.parse(this.quoteLineItemRecordList);
       
        for (let i = 0; i < this.quoteLineItemRecordList.length; i++) {
          if (this.quoteLineItemRecordList[i].service === 'undefined')
            this.quoteLineItemRecordList[i].service = undefined;
            if(this.quoteLineItemRecordList[i].productCost === 0)
            this.quoteLineItemRecordList[i].productCost = undefined;
        }
        console.log('after surface add::' + JSON.stringify(this.quoteLineItemRecordList));

        const selectedEvent2 = new CustomEvent("quotelineitemschange", {
          detail: result
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent2);
        // this.showButtons();
      })
      .catch(error => {
        console.log('Errorured in addSurface method:- ' + error);
      });
  }

  areaChange(event) {
    var seq = event.target.dataset.id;
    //this.quoteLineItemRecordList[seq].area = event.target.value;
    const detail = {};
    detail["value"] = event.target.value;
    detail["seq"] = seq;
    this.dispatchEvent(new CustomEvent('areachange', { detail: detail }));
  }
  price;
  priceChange(event) {
    console.log('Price::' + event.target.value);
    var seq = event.target.dataset.id;
    const detail = {};
    detail["seq"] = seq;
    //   if(event.target.value > 9999999){
    //     this.price =  event.target.value.slice(0, 7) 
    //     detail["value"] = event.target.value.slice(0, 7);
    //   }
    //  else{
    this.price = event.target.value
    detail["value"] = event.target.value;
    // }
    //this.quoteLineItemRecordList[seq].price = event.target.value;




    this.dispatchEvent(new CustomEvent('pricechange', { detail: detail }));
  }
  productChange(event) {
    console.log('product::' + event.detail);
    var seq = event.target.dataset.id;
    //this.quoteLineItemRecordList[seq].productId = event.target.value;
    //this.productId = event.target.value;
    // this.productSelected = true;
    const detail = {};
    detail["value"] = event.detail;
    detail["seq"] = seq;
    console.log('seq' + seq)
    console.log('product id on product chnage' + event.detail)
    getProductCost({IdofProduct : event.detail, tierName : this.tier})
    .then(r =>{
      console.log('cost '+r)
      for (let i = 0; i < this.quoteLineItemRecordList.length; i++) {
        console.log('seq in loop '+this.quoteLineItemRecordList[i].sequence)
        if (this.quoteLineItemRecordList[i].sequence == seq) {
          console.log('in if')
          this.quoteLineItemRecordList[i].productCost = 'Product Price (Per sqft): ₹'+ r
          break;
        }
      }
      console.log('after productCost add::' + JSON.stringify(this.quoteLineItemRecordList));

    })
    .catch(e =>{
      console.log('product cost error '+JSON.stringify(e))
    })
    getServiceName({ productId: event.detail, dealerId: this.dealerId }).then(r => {

      
        let service = undefined
        console.log('QLI :' + seq + ' ' + JSON.stringify(this.quoteLineItemRecordList))
        if (r !== 'undefined') {
          service = r
        }
        for (let i = 0; i < this.quoteLineItemRecordList.length; i++) {
          if (this.quoteLineItemRecordList[i].sequence == seq) {
            this.quoteLineItemRecordList[i].service = service
            
            break;
          }
        }


        detail["service"] = service
       
        this.dispatchEvent(new CustomEvent('productvalchange', { detail: detail }));
        if (event.detail != null && event.detail != undefined) {
          this.passProductList();
        }
     


    }).catch(e => {
      console.log('get serive name error : ' + JSON.stringify(e))
    })

    // console.log(this.quoteLineItemRecordList[seq])
    // this.dispatchEvent(new CustomEvent('productvalchange', { detail: detail }));
    // if (event.detail != null && event.detail != undefined) {
    //   this.passProductList();
    // }
  }
  remarksChange(event) {
    console.log('Remarks::' + event.target.value);
    var seq = event.target.dataset.id;
    //this.quoteLineItemRecordList[seq].remarks = event.target.value;
    const detail = {};
    detail["value"] = event.target.value;
    detail["seq"] = seq;
    this.dispatchEvent(new CustomEvent('remarkschange', { detail: detail }));
  }
  productModelChange(event) {
    console.log('Product modal::' + event.target.value);
    var seq = event.target.dataset.id;
    //this.quoteLineItemRecordList[seq].pricingModal = event.target.value;
    const detail = {};
    detail["value"] = event.target.value;
    detail["seq"] = seq;
    this.dispatchEvent(new CustomEvent('productmodelchange', { detail: detail }));
  }
  quantityChange(event) {
    console.log('Quantity::' + event.target.value);
    var seq = event.target.dataset.id;
    //this.quoteLineItemRecordList[seq].quantity = event.target.value;
    const detail = {};
    detail["value"] = event.target.value;
    detail["seq"] = seq;

   
    this.dispatchEvent(new CustomEvent('quantitychange', { detail: detail }));
  }


  @api
  checkMandatoryDetails() {

  }


  passProductList(event) {
    const selectedEvent = new CustomEvent("productchange", {
      detail: this.quoteLineItemRecordList
    });

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  hideModalBox() {
    this.isShowModal = false;
  }

  deleteSurface(event) {
    console.log('seq::' + event.target.dataset.id);
    var seq = event.target.dataset.id;
    var index;
    for (var q = 0; q < this.quoteLineItemRecordList.length; q++) {
      if (this.quoteLineItemRecordList[q].sequence == seq) {
        index = this.quoteLineItemRecordList.indexOf(this.quoteLineItemRecordList[q]);
      }
    }
    this.quoteLineItemRecordList.splice(index, 1);
    for (var q = 0; q < this.quoteLineItemRecordList.length; q++) {
      this.quoteLineItemRecordList[q].sequence = q;
    }

    const detail = {};
    detail["value"] = seq;
    this.dispatchEvent(new CustomEvent('deleteitemsfromsurface', { detail: detail }));

  }

  handleChangeCheckbox(event) {
    var seq = event.target.dataset.id;
    //this.quoteLineItemRecordList[seq].upperProducts = event.detail;
    const detail = {};
    detail["value"] = event.detail;
    detail["seq"] = seq;
    this.dispatchEvent(new CustomEvent('upperproductchange', { detail: detail }));
  }

}