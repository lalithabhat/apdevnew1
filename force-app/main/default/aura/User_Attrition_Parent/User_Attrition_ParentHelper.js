({
	checkValidation : function(component,oldContact,newContact) {
        //alert(oldContact);
        //alert(newContact);
		var action = component.get("c.checkValidationAPex");
        action.setParams({ oldContact : oldContact,
                           newContact : newContact
                         });        

        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(response.getReturnValue());
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'Success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": 'Record owner updated successfully!',
                        "type": "success"
                    });
                    toastEvent.fire();
                    component.set('v.loaded', true);
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": response.getReturnValue(),
                        "type": "error"
                    });
                    toastEvent.fire();
                    component.set('v.loaded', true);
                }
            }
            else {
                console.log("Failed with checkValidation: " + state);
            }
        });
        $A.enqueueAction(action);
	}
})