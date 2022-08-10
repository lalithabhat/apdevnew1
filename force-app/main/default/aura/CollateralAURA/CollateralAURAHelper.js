({
	getRecordDetails : function(component) {
        var action = component.get("c.getRecordDetails");
        action.setParams({
            "id" : component.get('v.recordId') 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.email", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        
        var serviceAction = component.get("c.getServiceValues");
        serviceAction.setCallback(this, function(response) {
            var serviceState = response.getState();
            if (serviceState === "SUCCESS") {
                component.set("v.services", response.getReturnValue());
            }
            else {
                console.log("Failed with serviceState: " + serviceState);
            }
        });
        $A.enqueueAction(serviceAction);
        
        var subServiceAction = component.get("c.getSubServiceValues");
        subServiceAction.setCallback(this, function(response) {
            var subServiceState = response.getState();
            if (subServiceState === "SUCCESS") {
                component.set("v.subServices", response.getReturnValue());
            }
            else {
                console.log("Failed with subServiceState: " + subServiceState);
            }
        });
        $A.enqueueAction(subServiceAction);
        
        var categoryAction = component.get("c.getCategoryValues");
        categoryAction.setCallback(this, function(response) {
            var categoryState = response.getState();
            if (categoryState === "SUCCESS") {
                component.set("v.categories", response.getReturnValue());
            }
            else {
                console.log("Failed with categoryState: " + categoryState);
            }
        });
        $A.enqueueAction(categoryAction);
    } ,
    
    getcollateralList : function(component) {
        //alert('hi');
        var action = component.get("c.getCollateralsList");
        action.setParams({ "selectedService" : component.get('v.selectedService'),
                         "selectedSubService" : component.get('v.selectedSubService'),
                         "selectedCategory" : component.get('v.selectedCategory')});        

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.collateralList", response.getReturnValue());
            }
            else {
                console.log("Failed with collateral list: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchColumnsHelper : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
                {label: 'Service', fieldName: 'Service__c', type: 'text'},
                {label: 'Sub-Service', fieldName: 'Sub_Service__c', type: 'text'},
                {label: 'Category', fieldName: 'Category__c', type: 'text'},
            	{label: 'URL', fieldName: 'URL__c', type: 'url'}
            ]);
    },
    
    sendEmail : function(component) {
        //alert('hi'+component.get('v.selectedCollateralList').length);
        //var obj = component.get('v.selectedCollateralList');
        var action = component.get("c.sendMail");
        action.setParams({ "selectedList" : component.get('v.selectedCollateralList'),
                          "email" : component.get('v.email'),
                          "ccMail" : component.get('v.otherMails')
                         });        

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'Success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Mail send successfully!!",
                        "type": "success"
                    });
                    toastEvent.fire();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Mail send Failed",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
               // component.set("v.collateralList", response.getReturnValue());
            }
            else {
                console.log("Failed with send mail: " + state);
            }
        });
        $A.enqueueAction(action);
    }
    
})