({
	doInit : function(component, event, helper) {
        helper.getRecordDetails(component);
        helper.fetchColumnsHelper(component);
    },
    onServiceChange : function(cmp, event, helper) {
        console.log(cmp.find('service').get('v.value'));
        var st = cmp.find('service').get('v.value');
        cmp.set("v.selectedService",st);
        //alert('st::'+st);
        helper.getcollateralList(cmp);
    },
    onSubServiceChange : function(cmp, event, helper) {
        console.log(cmp.find('subservice').get('v.value'));
        var st = cmp.find('subservice').get('v.value');
        cmp.set("v.selectedSubService",st);
        helper.getcollateralList(cmp);
    },
    onCategoryChange : function(cmp, event, helper) {
        console.log(cmp.find('category').get('v.value'));
        var st = cmp.find('category').get('v.value');
        cmp.set("v.selectedCategory",st);
        helper.getcollateralList(cmp);
    },
    
    onRowSelection : function(cmp, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        //alert('selectedRows:: '+selectedRows.length);
        cmp.set('v.selectedRowsCount', selectedRows.length);
        cmp.set('v.selectedCollateralList', selectedRows);
        
    },
    
    sendCollateral : function(cmp, event, helper) {
        if(cmp.get('v.selectedCollateralList').length == 0){
            alert('Please select record to send');
        }/*else if(cmp.get('v.showError')){
            alert('Enter valid cc email');
        }*/else{
            helper.sendEmail(cmp);
        }
        //alert('length::'+cmp.get('v.selectedCollateralList').length);
        
    },
    
    closeMethodInAuraController : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    validateEmail : function(component,event){
        var dynamicVal = component.find("CCEmail2");
        //alert('dynamicval::'+dynamicVal);
        var eml = dynamicVal.get("v.value") ;
        var emails = eml.split(';');
        //alert(emails.length);
        var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        for(var i=0;i<emails.length;i++){
            if (!re.test(emails[i])) {
                var msg = component.find("errMsg");
                component.set("v.showError",true);
                //alert(msg.get("v.value"));
                //msg.set("v.value","Not a valid e-mail address") ;
                //document.getElementById("errMsg").innerHTML = 'Not a valid e-mail address';
                //document.getElementById("errMsg").style="color:red";
                
                
            }else{
                component.set("v.showError",false);
            }
            
            /*else{
                document.getElementById("errMsg").innerHTML = 'valid e-mail address';
                document.getElementById("errMsg").style="color:green";
                
            }*/
        }
        
        
    }
})