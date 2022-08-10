public class CollateralController {
	
    @AuraEnabled(cacheable=true)
    public static string getRecordDetails(Id id){
        try {
            String sObjName = id.getSObjectType().getDescribe().getName();
            if(sObjName == 'Lead'){
                List<Lead> leadList = new List<Lead>();
                DescribeSObjectResult describeResultLead = Lead.getSObjectType().getDescribe();  
                List<String> fieldNamesLead = new List<String>( describeResultLead.fields.getMap().keySet() );
                String query1 = ' SELECT ' + String.join( fieldNamesLead, ',' ) + 
                    ' FROM ' + describeResultLead.getName() + ' where Id =:id';
                leadList = Database.query(query1);
                return leadList[0].Email;
            }else if(sObjName == 'Account'){
                List<Account> accList = new List<Account>();
                DescribeSObjectResult describeResultAcc = Account.getSObjectType().getDescribe();  
                List<String> fieldNamesAcc = new List<String>( describeResultAcc.fields.getMap().keySet() );
                String query1 = ' SELECT ' + String.join( fieldNamesAcc, ',' ) + 
                    ' FROM ' + describeResultAcc.getName() + ' where Id =:id';
                accList = Database.query(query1);
                return accList[0].PersonEmail;
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<string> getServiceValues(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Collateral__c.Service__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        pickListValuesList.add('');
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getValue());
		}     
        system.debug('service Values::'+pickListValuesList);
		return pickListValuesList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<string> getSubServiceValues(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Collateral__c.Sub_Service__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        pickListValuesList.add('');
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getValue());
		}     
        system.debug('sub service Values::'+pickListValuesList);
		return pickListValuesList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<string> getCategoryValues(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Collateral__c.Category__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        pickListValuesList.add('');
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getValue());
		}     
        system.debug('Category Values::'+pickListValuesList);
		return pickListValuesList;
    }
    
	@AuraEnabled(cacheable=true)
    public static List<Collateral__c> getCollateralsList(string selectedService, string selectedSubService, string selectedCategory){
        system.debug('selectedService::'+selectedService);
        system.debug('selectedSubService::'+selectedSubService);
        system.debug('selectedCategory::'+selectedCategory);
        if(string.isNotBlank(selectedService) && string.isNotBlank(selectedSubService) && string.isNotBlank(selectedCategory)){
            List<Collateral__c> cList = [select id,name,Category__c ,Service__c, Sub_Service__c, URL__c from Collateral__c
                                    where Service__c =: selectedService and Sub_Service__c =: selectedSubService
                                    and Category__c =: selectedCategory];
            system.debug('cList::'+cList);
            return cList;
        } 
        return null; 
    }
    
    @AuraEnabled
    public static string sendMail(List<Collateral__c> selectedList, string email, string ccMail){
        system.debug('selectedList::'+selectedList.size());
        
        try{
            
            if(string.isNotBlank(ccMail)){
                
            }
            List<Email_Log__c> logsToInsert = new List<Email_Log__c>();
            for(Collateral__c c : selectedList){
                Email_Log__c log = new Email_Log__c();
                log.What_Id__c = c.Id;
                log.Email_Template__c = 'Send_Collaterals';
                log.email__c = email;
                logsToInsert.add(log);
            }
            insert logsToInsert;
            return 'Success';
        }catch(exception ex){
            system.debug('error:: '+ex.getMessage());
            return 'failed';
        }
        //return null;
    }
        
        
}