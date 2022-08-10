({
	handleEvent : function(component, event, helper) {
        //alert('hi');
		var response = event.getParam("selectedContact"); 
        var response2 = event.getParam("contactType");
        //alert(response2);
        if(response2 == 'oldContact'){
            component.set("v.selectedOldContact", response);
        }else if(response2 == 'newContact'){
            component.set("v.selectedNewContact", response);
        }
        
	},
    
    submit: function(component, event, helper) {
        component.set('v.loaded', false);
        var oldContact = component.get("v.selectedOldContact");
        //alert(oldContact);
        var newContact = component.get("v.selectedNewContact");
        if(oldContact == undefined && oldContact == null){
            component.set('v.loaded', true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Select Old Contact",
                "type": "info"
            });
            toastEvent.fire();
        }else if(newContact == undefined || newContact == null){
            component.set('v.loaded', true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Select New Contact",
                "type": "info"
            });
            toastEvent.fire();
        }else{
            helper.checkValidation(component,oldContact,newContact);
        }
        
    }
})