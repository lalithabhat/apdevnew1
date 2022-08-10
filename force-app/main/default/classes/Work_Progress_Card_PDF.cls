public class Work_Progress_Card_PDF {

    public List<Milestone1_Milestone__c> workRecord{get;set;}
    public string wId{get;set;}
    public string Today_Date{get;set;}
    public string customerName{get;set;}
    public string customerMobile{get;set;}
    public string contractorName{get;set;}
    public string contractorMobile{get;set;}
    public string visitedBy{get;set;}
    public string visitedMobile{get;set;}
    public string dealerName{get;set;}
    public string dealerAddress{get;set;}
    public string dealerMobile{get;set;}
    public string siteName{get;set;}
    public List<Milestone1_Milestone__c> otherWorkFromQuote{get;set;}
    Public list<string> activityList_ONE {get;set;}
    Public list<string> activityList_TWO {get;set;}
    public map<Id,areaSpecs> areaSpecifications {get;set;}
    public map<Id,Map<string,Map<string,TableWrapper>>> TABLE_ONE_MAP_D {get;set;}
    public map<Id,Map<string,Map<string,TableWrapper>>> TABLE_TWO_MAP_D {get;set;}
    public map<Id,set<string>> areaNameMap {get;set;}
    public map<Id,Map<string,Site_Completion_Card_PDF.ImageWrapper>> imageMap {get;set;}
    public boolean isdata{get;set;}
    public string tier{get;set;}
    public string services{get;set;}
    public map<Id,boolean> imageUploaded {get;set;}
    
    Public Work_Progress_Card_PDF(){
        wId = ApexPages.currentPage().getParameters().get('id');
       // wId = 'a0C7200000FcKptEAF';
        workRecord = new List<Milestone1_Milestone__c>();
        Today_Date = system.today().format();
        activityList_ONE = new list<string>{'Masking Covering','Sanding & Scrapping','Crack/Gaps Filling',
            								'Other Prelimenary works','Waterproofing','Plastering'};
        activityList_TWO = new list<string>{'Base coat / Primer Application','Base coat / Putty Application',
            								'1st Top Coat Application','2nd Top Coat Application',
            								'Post Painting cleaning'};  
        areaSpecifications = new map<Id,areaSpecs>();         
        areaNameMap = new map<Id,set<string>>();
        imageMap = new map<Id,Map<string,Site_Completion_Card_PDF.ImageWrapper>>();
        isdata = false;
        tier = '';
        services = '';
        imageUploaded = new map<Id,boolean>();
        
        DescribeSObjectResult describeResultWork = Milestone1_Milestone__c.getSObjectType().getDescribe();  
        List<String> fieldNamesWork = new List<String>( describeResultWork.fields.getMap().keySet() );
        String query = ' SELECT ' + String.join( fieldNamesWork, ',' ) + ',Opportunity__r.Account.Name,' +
            'Project__r.Contractor__r.Name, Project__r.Dealer__r.Name,Opportunity__r.Account.PersonMobilePhone, ' +
            'Project__r.Contractor__r.Phone, Project__r.Dealer__r.Phone,Project__r.Dealer__r.BillingStreet,Project__r.Dealer__r.BillingCity,' +
            'Project__r.Dealer__r.BillingState,Project__r.Dealer__r.BillingCountry,Project__r.Dealer__r.BillingPostalCode,' + 
            'Project__r.Kickoff__c,Project__r.Deadline__c,Quote__r.lastmodifiedDate,Quote__r.Site_Health_Card__r.createdDate, ' +
            'Quote__r.Public_URL__c,Quote__r.Site_Health_Card__r.Public_URL__c,Quote__r.Tier__c,Quote__r.New_Services__c,Project__r.owner.Name, Project__r.ownerId, Project__r.Name ' +
            ' FROM ' + describeResultWork.getName() + ' where Id =' + '\'' + wId + '\'';
        
        workRecord = Database.query(query);
        
    
        customerName = workRecord[0].Opportunity__r.Account.Name;
        customerMobile = workRecord[0].Opportunity__r.Account.PersonMobilePhone;
        visitedBy = workRecord[0].Project__r.owner.Name;
        List<User> u = [Select Contact.MobilePhone from user where id =: workRecord[0].Project__r.OwnerId];
        if(!u.isEmpty() && u[0].COntact.MobilePhone !=null) visitedMobile = u[0].Contact.MobilePhone;
        else visitedMobile = '';
        siteName = workRecord[0].Project__r.Name;
        contractorName = workRecord[0].Project__r.Contractor__r.Name;
        contractorMobile = workRecord[0].Project__r.Contractor__r.Phone;
        dealerName = workRecord[0].Project__r.Dealer__r.name;
        dealerMobile = workRecord[0].Project__r.Dealer__r.Phone;
        dealerAddress ='';
        if(workRecord[0].Project__r.Dealer__r.BillingStreet != null){
            dealerAddress = workRecord[0].Project__r.Dealer__r.BillingStreet + ',';
        }
        if(workRecord[0].Project__r.Dealer__r.BillingCity != null){
            dealerAddress = dealerAddress + workRecord[0].Project__r.Dealer__r.BillingCity + ', ';
        }
        if(workRecord[0].Project__r.Dealer__r.BillingState != null){
            dealerAddress = dealerAddress + workRecord[0].Project__r.Dealer__r.BillingState + ', ';
        }
        if(workRecord[0].Project__r.Dealer__r.BillingCountry != null){
            dealerAddress = dealerAddress + workRecord[0].Project__r.Dealer__r.BillingCountry + ', ';
        }
        if(workRecord[0].Project__r.Dealer__r.BillingPostalCode != null){
            dealerAddress = dealerAddress + workRecord[0].Project__r.Dealer__r.BillingPostalCode;
        }
        tier = workRecord[0].Quote__r.Tier__c;
        services = workRecord[0].Quote__r.New_Services__c;
        
        DescribeSObjectResult describeResultWork2 = Milestone1_Milestone__c.getSObjectType().getDescribe();  
        List<String> fieldNamesWork2 = new List<String>( describeResultWork2.fields.getMap().keySet() );
        String query2 = ' SELECT ' + String.join( fieldNamesWork2, ',' ) +
            ',Quote__r.Public_URL__c,Quote__r.Site_Health_Card__r.Public_URL__c, Contractor__r.Phone, Contractor__r.Name ' +
            ' FROM ' + describeResultWork2.getName() + ' where Quote__c =' + '\'' + workRecord[0].Quote__c + '\'';
        otherWorkFromQuote = new List<Milestone1_Milestone__c>();
        otherWorkFromQuote = Database.query(query2);
            Map<Id,Milestone1_Milestone__c > workMap = new Map<Id,Milestone1_Milestone__c>(otherWorkFromQuote);
        if(!otherWorkFromQuote.isEmpty()){
            set<Id> workIds = new set<Id>();
            for(Milestone1_Milestone__c m : otherWorkFromQuote){
                workIds.add(m.Id);
            }
            
            List<Milestone1_Task__c > taskList = new List<Milestone1_Task__c >();
            DescribeSObjectResult describeResultTask = Milestone1_Task__c.getSObjectType().getDescribe();  
            List<String> fieldNamesTask = new List<String>( describeResultTask.fields.getMap().keySet() );
            String query3 = ' SELECT ' + String.join( fieldNamesTask, ',' ) + 
                ' FROM ' + describeResultTask.getName() + ' where Project_Milestone__c IN:workIds';
            
            taskList = Database.query(query3);
            Map<Id, List<Milestone1_Task__c>> work_taskMap = new Map<Id, List<Milestone1_Task__c>>();             
            if(!taskList.isEmpty()){
                for( Milestone1_Task__c mt : taskList){
                    if(work_taskMap.containsKey(mt.Project_Milestone__c)){
                        List<Milestone1_Task__c> mtList = new List<Milestone1_Task__c>();
                        mtList = work_taskMap.get(mt.Project_Milestone__c);
                        mtList.add(mt);
                        work_taskMap.put(mt.Project_Milestone__c,mtList);
                    }else{
                        List<Milestone1_Task__c> mtList = new List<Milestone1_Task__c>();
                        mtList.add(mt);
                        work_taskMap.put(mt.Project_Milestone__c,mtList);
                    }
                    
                }
            }
            
            Map<string,Map<string,List<Milestone1_Task__c>>> taskMap_by_ActivityD = new Map<string, map<string,List<Milestone1_Task__c>>>();
            if(!work_taskMap.isEmpty()){
                for(Id key : work_taskMap.keyset()){
                    string str = '';
                    set<string> dummyList = new set<string>();
                    for(Milestone1_Task__c m : work_taskMap.get(key)){
                        //str = str + m.Name + ',';
                        dummyList.add(m.Description_of_Area__c);
                    }
                    for(string strg : dummyList){
                        str = str + strg + ',';
                    }
                    str = str.removeEnd(',');
                    areaSpecs a = new areaSpecs();
                    a.areaSpecsName = str;
                    a.workId = workMap.get(key).Work_Id__c;
                    a.contractorName = workMap.get(key).Contractor__r.Name;
                    a.contractorMobile = workMap.get(key).Contractor__r.Phone;
                    a.percentComplete = workMap.get(key).Completion_Percent__c ;
                    a.observation = workMap.get(key).Description__c;
                    areaSpecifications.put(key,a);
                    areaNameMap.put(key,dummyList);
                    
                    Map<string,Site_Completion_Card_PDF.ImageWrapper> dummyImageMap = Site_Completion_Card_PDF.getImageMap(key);
                    if(dummyImageMap != null && !dummyImageMap.isEmpty()){
                        imageMap.put(key,dummyImageMap);
                    }
                    map<string,List<Milestone1_Task__c>> d1Map = new map<string,List<Milestone1_Task__c>>();
                    for(Milestone1_Task__c mt : work_taskMap.get(key)){
                        if(d1Map.containsKey(mt.Description_of_Area__c)){
                            list<Milestone1_Task__c> d1List = new List<Milestone1_Task__c>();
                            d1List = d1Map.get(mt.Description_of_Area__c);
                            d1List.add(mt);
                            d1Map.put(mt.Description_of_Area__c,d1List);
                        }else{
                            list<Milestone1_Task__c> d1List = new List<Milestone1_Task__c>();
                            d1List.add(mt);
                            d1Map.put(mt.Description_of_Area__c,d1List);
                        }
                    }
                    taskMap_by_ActivityD.put(key,d1Map);
                }
            }
            
            TABLE_ONE_MAP_D = new map<Id,Map<string,Map<string,TableWrapper>>>();
            TABLE_TWO_MAP_D = new map<Id,Map<string,Map<string,TableWrapper>>>();
            if(!work_taskMap.isEmpty()){
                for(Id key : work_taskMap.keyset()){
                    Map<string,Map<string, TableWrapper>> D22 = new Map<string,Map<string, TableWrapper>>();
                    for(string st1 : areaNameMap.get(key)){
                        Map<string, TableWrapper> D11 = new Map<string, TableWrapper>();
                        if(taskMap_by_ActivityD.containskey(key)){
                            if(taskMap_by_ActivityD.get(key).containskey(st1)){
                                for(string st2 : activityList_ONE){
                                    TableWrapper tp = new TableWrapper();
                                    tp.status = 'NA';
                                	tp.comment = '';
                                    for(Milestone1_Task__c m : taskMap_by_ActivityD.get(key).get(st1)){
                                        if(st2.equalsIgnoreCase(m.Activity_Details__c)){
                                            if(m.Complete__c){
                                                tp.status = 'Yes';
                                            }else{
                                                tp.status = 'No';
                                            }
                                            tp.comment = m.Delay_if_any_reason__c;
                                        }
                                    }
                                    D11.put(st2,tp);
                                }
                            }
                        }
                        D22.put(st1,D11);
                    }
                    TABLE_ONE_MAP_D.put(key, D22);
                    
                    
                    Map<string,Map<string, TableWrapper>> D33 = new Map<string,Map<string, TableWrapper>>();
                    for(string st1 : areaNameMap.get(key)){
                        Map<string, TableWrapper> D11 = new Map<string, TableWrapper>();
                        if(taskMap_by_ActivityD.containskey(key)){
                            if(taskMap_by_ActivityD.get(key).containskey(st1)){
                                for(string st2 : activityList_TWO){
                                    TableWrapper tp = new TableWrapper();
                                    tp.status = 'NA';
                                	tp.comment = '';
                                    for(Milestone1_Task__c m : taskMap_by_ActivityD.get(key).get(st1)){
                                        if(st2.equalsIgnoreCase(m.Activity_Details__c)){
                                            if(m.Complete__c){
                                                tp.status = 'Yes';
                                            }else{
                                                tp.status = 'No';
                                            }
                                            tp.comment = m.Delay_if_any_reason__c;
                                        }
                                    }
                                    D11.put(st2,tp);
                                }
                            }
                        }
                        D33.put(st1,D11);
                    }
                    TABLE_TWO_MAP_D.put(key, D33);
                }
                                
            }
            system.debug('imageMap::'+imageMap);
            if(imageMap != null && !imageMap.isEmpty()){
            	isData = true;
                for(Id st : areaSpecifications.keySet()){
                    if(imageMap.containskey(st)){
                        imageUploaded.put(st,true);
                    }else{
                    	imageUploaded.put(st,false);
                	}
                }
        	}
        }
        
    }
    
    public class areaSpecs{
        public string areaSpecsName {get;set;}
        public string workId {get;set;}
        public string contractorName {get;set;}
        public string contractorMobile {get;set;}
        public decimal percentComplete {get;set;} 
        public string observation {get;set;}
    }
    Public class TableWrapper{
        public string area{get;set;}
        public string status{get;set;}
        public string comment{get;set;}
        
        public TableWrapper(){
            
        }
    }
}