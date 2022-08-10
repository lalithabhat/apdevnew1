({
	// code in the helper is reusable by both
    // the controller.js and helper.js files
    handleSearch: function( component, oldContact ) {
        //alert('oldContact::'+oldContact);
        var action = component.get( "c.getContactRecords" );
        action.setParams({
            searchTerm: oldContact
        });
        action.setCallback( this, function( response ) {
            /*var event = $A.get( "e.c:ContactSearch" );
            event.setParams({
                "contacts": response.getReturnValue()
            });
            event.fire();*/
            //component.set( "c.contactList", response.getReturnValue());
            //alert(component.get( "c.contactList"));
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contactList", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction( action );
    },
    
    getContacts : function(component) {
        var action = component.get("c.getContacts");
        action.setParams({
            //"id" : component.get('v.recordId') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.contacts", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    getSelectedContact : function(component) {
        
    }
})