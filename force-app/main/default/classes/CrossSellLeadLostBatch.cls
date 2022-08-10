global class CrossSellLeadLostBatch implements Database.Batchable<Sobject>,Database.AllowsCallouts {
 global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String query= 'SELECT Id,Cross_Sold_On__c,Status,Recordtype.DeveloperName  from Lead WHERE Cross_Sold_On__c = YESTERDAY';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> leads)
    {
        Set<Id> idset=new Set<Id>();
        Set<Id> successId = new Set<Id>();
        
        for(Lead l: leads)
        {
            if(l.id!=null){
                idset.add(l.id);
            }
            if((l.Status=='New' || l.Status=='Working' )&& l.Recordtype.DeveloperName!='TCS' && l.Recordtype.DeveloperName!='General_Enquiry'){
               l.Status ='Lost';
                l.Drop_Lead_Reason__c='Cross Sell - Lead';
                 system.debug(l);
            }
            else if(l.Status=='New' && l.Recordtype.DeveloperName=='TCS'||l.Recordtype.DeveloperName=='General_Enquiry'){
               l.Status ='Closed';
                l.Drop_Lead_Reason__c='Cross Sell - Lead';
                 system.debug(l);
            }
        }
        AP_CTIManagementService.blockLeadfromCallingQueueNonFuture(idset);
         Database.SaveResult[] srList = Database.update(leads , false);
        
         String str ='';
        
        for (Integer i=0;i<srList.size();i++){
            if(srList.get(i).isSuccess()){
                successId.add(srList.get(i).getId());
            }
            else{
                for(Database.Error objErr : srList.get(i).getErrors()){
                    str += objErr.getStatusCode() + ': ' + objErr.getMessage() +' Lead Id :'+  leads[i].Id +' | ';     
                }
            }
        }
 
        if(Test.isRunningTest()) str ='Error';
        if(str !=''){
            System_Log__c SL = new System_Log__c();
            SL.API_Name__c  = 'CrossSellLeadLostBatch';
            SL.Request__c =  str;
            insert sl;
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
}