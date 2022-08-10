global class LeadAutoDrop_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts {
    
    //Auto Drop Leads that are in new stage and have an unsuccessful disposition
    public static List<String> dispositions = new List<String>{'BH Store - Lead - Successful','BH Store - Call Back',
        'BH Store - NCT','BH Store - Others', 'General Enquiry - Service Enquiry','General Enquiry - Call Back',
        'General Enquiry - NCT','General Enquiry - Warranty','General Enquiry - Test','General Enquiry - General painting query',
        'General Enquiry - Other Query','General Enquiry - Service Complaints','SPS - Unsuccesful / Lead drop reasons',
        'BHS - Unsuccesful / Lead drop reasons','SLEEK - Unsuccesful / Lead drop reasons','TCS - Unsuccesful / Lead drop reasons'};
            
            public static Set<String> GeneralQrySubDespositions = new Set<String>{'APPS Enquiry','BHS Enquiry','PTPR Enquiry',
                'SAN Assure Enquiry','Warranty related','Test_call','APPS lead','Advance budget calculator','Dealer Locator',
                'Contractor Locator','Colour info','Product & cost info','Enquiry for signature store','Ecom_Related_Queries',
                'Architects_Related_Queries','Product & cost info-Contractor','Product & cost info-Pinter','Product & cost info-Customer',
                'Hired Local painter','Not interested in our service','Job Enquiry','Dealer related','Prank_Calls','Toll free',
                'Junk Calls','Email id shared','Masterstroke Enquiry','Industrial Query','Call complete','Others'};
                    
                    public static Set<String> BHStoreSubDespositions = new Set<String>{'Postponed Painting Plan','Wrong Number',
                        'Not Interested','Non Serviceable Area', 'General Query'};                
                            
                            global Database.QueryLocator start(Database.BatchableContext BC) {
                                String query = 'select whoId, toLabel(Sub_Disposition__c), TYPEOF Who WHEN Lead THEN Status, recordtype.developerName end from task where Disposition__c IN : ';
                                query += 'dispositions';
                                query += ' AND createddate = LAST_N_DAYS:10';
                                query += ' AND Who.Type=\'Lead\'';
                                return Database.getQueryLocator(query);
                            }
    
    global void execute(Database.BatchableContext BC, List<Task> tasks) {
        Map<Id,Lead> leadMap = new Map<Id,Lead>();
        Set<Id> successId = new Set<Id>();
        system.debug('Outer');
        for(Task t : tasks){
            Lead l = t.who;
            system.debug('In For Block' + l);
            if(l.status =='New' && (l.recordtype.developerName != 'General_Enquiry' && l.recordtype.developerName != 'BH_Store')){
                String status = 'Lost';
                system.debug('In Main IF Block');
                if(l.RecordType.DeveloperName =='TCS') status ='Closed';
                Lead ln = new Lead(Id= t.WhoId, status =status ,Drop_Lead_Reason__c = t.Sub_Disposition__c, Auto_Drop_Reason__c = 'Unsuccessful Disposition' );
                leadMap.put(t.WhoId, ln );
            }
            
            else if(l.status =='New' && l.recordtype.developerName == 'General_Enquiry'){
                system.debug('In General_Enquiry IF Block');
                if(GeneralQrySubDespositions.contains(t.Sub_Disposition__c )){
                    system.debug('In General Enq. Block');
                    Lead ln = new Lead(Id= t.WhoId, status ='Closed' ,Drop_Lead_Reason__c = t.Sub_Disposition__c, Auto_Drop_Reason__c = 'Unsuccessful Disposition' );
                    leadMap.put(t.WhoId, ln );
                }
            }
            else if(l.status =='New' && l.recordtype.developerName == 'BH_Store'){
                system.debug('In BH_Store IF Block');
                if(BHStoreSubDespositions.contains(t.Sub_Disposition__c )){
                    system.debug('In BH_Store Block');
                    Lead ln = new Lead(Id= t.WhoId, status ='Lost' ,Drop_Lead_Reason__c = t.Sub_Disposition__c, Auto_Drop_Reason__c = 'Unsuccessful Disposition' );
                    leadMap.put(t.WhoId, ln );
                }
            }
        }
        
        AP_CTIManagementService.blockLeadfromCallingQueueNonFuture(leadMap.keySet()); // Calling CTI to block leads
        Database.SaveResult[] srList = Database.update(leadmap.values() , false);
        String str ='';
        
        for (Integer i=0;i<srList.size();i++){
            if(srList.get(i).isSuccess()){
                successId.add(srList.get(i).getId());
            }
            else{
                for(Database.Error objErr : srList.get(i).getErrors()){
                    str += objErr.getStatusCode() + ': ' + objErr.getMessage() +' Lead Id :'+  leadMap.values()[i].Id +' | ';     
                }
            }
        }
        
        
        
        if(Test.isRunningTest()) str ='Error';
        if(str !=''){
            System_Log__c SL = new System_Log__c();
            SL.API_Name__c  = 'Lead Auto Drop Basis Disposition';
            SL.Request__c =  str;
            insert sl;
        }
        
        
        /* for(Lead l : leads){
leadIds.add(l.Id);
}
for(Task t : [Select whoId, toLabel(Sub_Disposition__c), TYPEOF Who WHEN Lead THEN recordtype.developerName END from Task Where WHoId IN : leadIds AND Disposition__c IN: dispositions]){
// String status = 'Lost';
// if(t.who.recordtype.developerName == 'General_Enquiry' || t.who.recordtype.developerName == 'TCS' || t.who.recordtype.developerName=='BH_Store')
//   status ='Closed';

Lead l = new Lead(Id= t.WhoId, status ='Lost' ,Drop_Lead_Reason__c = t.Sub_Disposition__c, Auto_Drop_Reason__c = 'Unsuccessful Disposition' );
leadMap.put(t.WhoId,l);
}
Database.SaveResult[] srList = Database.update(leadMap.values() , false);
String str ='';
for (Integer i=0;i<srList.size();i++) 
{
if (!srList.get(i).isSuccess())
{
for(Database.Error objErr : srList.get(i).getErrors()) 
{
str += objErr.getStatusCode() + ': ' + objErr.getMessage() +' Lead Id :'+  leadmap.values()[i].Id +' | ';     
}
}
}
if(Test.isRunningTest()) str ='Error';
if(str !=''){
System_Log__c SL = new System_Log__c();
SL.API_Name__c  = 'Lead Auto Drop Basis Disposition';
SL.Request__c =  str;
insert sl;
}  */
    }
    
    global void finish(Database.BatchableContext BC) {}
}