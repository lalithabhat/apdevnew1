({
    doInit: function (cmp, event, helper){
        helper.getContacts(cmp);
    },
	onOldContactChange: function( component, event, helper ) {
        var oldContact = component.get( "v.oldContact" );
        // we wait a small delay to check when user is done typing
        var delayMillis = 500;
        // get timeout id of pending search action
        var timeoutId = component.get( "v.searchTimeoutId" );
        // cancel pending search action and reset timer
        clearTimeout( timeoutId );
        // delay doing search until user stops typing
        // this improves client-side and server-side performance
        timeoutId = setTimeout( $A.getCallback( function() {
            //alert('oldContact'+oldContact);
            helper.handleSearch( component, oldContact );
        }), delayMillis );
        component.set( "v.searchTimeoutId", timeoutId );
    },
    optionsClickHandler: function (component, event, helper){        
        var contactId = event.currentTarget.dataset.id;
        var contactName = event.currentTarget.dataset.div;
        //alert(event.currentTarget.dataset.div);
        component.set("v.selectedContactName",contactName);
        component.set("v.selectedContactId",contactId); 
        component.set("v.showSearch",false);
         component.set("v.hideBoxResult",false);
        var evt = $A.get( "e.c:ContactSearch" );
        evt.setParams({
            "selectedContact": contactId,
            "contactType":component.get("v.fromParent")
        });
        evt.fire();
    },
    
    changeContact: function(component, event, helper){
        //alert('hi');
        component.set("v.showSearch",true);
        component.set("v.hideBoxResult",true);
        component.set("v.selectedContactName",null);
        component.set("v.selectedContactId",null); 
        var event = $A.get( "e.c:ContactSearch" );
        event.setParams({
            "selectedContact": null,
            "contactType":component.get("v.fromParent")
        });
        event.fire();
    },
    
    hideResult: function(component, event, helper){
        //alert('hi');
        //component.set("v.hideBoxResult",false);
    }
})