public class CreateEventForUser {
   
@InvocableMethod(label='Create Event for unit' )
    
    public static List<string> invokeThisMethod(List<FlowInputs> request) {
       List<string> stringList = new List<String>();
        string result;
        try{
         result = createEvent( request[0].startTime1, request[0].endTime1, request[0].reason1, request[0].levelName,request[0].levelType);
        
        }
        catch(exception e) {result = e.getmessage()+ ' '+e.getlinenumber(); }
        stringList.add(+result);
        
        return stringList;
        
             
    }
    public static string  createEvent(Datetime startTime1, Datetime endTime1, string reason1, string levelName,string levelType){
    List<User> UserwithUnits= new List<User>();
       
  UserwithUnits = database.query('select id,Unit__c,User_Name__c,Service__c,ContactId,Division1__c,Region__c,IsActive from User where IsActive = true and '   +levelType +' =' + '\'' + levelName +  '\'' ) ;
            list<Id> UserwithUnitIDs = new list<Id>();
            if(UserwithUnits != null && !UserwithUnits.isEmpty()){
                
            
                list<event> Insertevents = new list<event>();
                Events__c events = new Events__c();
                        events.name = reason1 + ' Events created';
                        events.End_Date_Time__c = endTime1;
                        events.Start_Date_Time__c = startTime1;
                        events.Reason__c  = reason1;
                        events.Description__c = reason1 + ' events created and started on ' + startTime1.date().format() + 
                                                '. Total no of users assign: ' + UserwithUnits.size() ;  
                 insert events;
               
        for(User U : UserwithUnits){
                                   
                Event e = new Event();
                       e.OwnerId= U.id;
                       e.Subject= reason1;
                       e.StartDateTime= startTime1;
                	   e.EndDateTime= endTime1;
                	   e.WhoId = U.ContactId;
                        Insertevents.add(e);
            			
        }
                
        insert Insertevents;
       
                     return 'Event Created ';      
            } else{
         Return 'No User found For level Type '+levelType+ ' level Name '+levelName;
            }
    }
            
     //input details that comes to apex from flow
    public class FlowInputs{
    
       
        @InvocableVariable
        public DateTime startTime1;
        @InvocableVariable
        public DateTime endTime1;
        @InvocableVariable
        public string reason1;
		@InvocableVariable
        public string levelName;
        @InvocableVariable
        public string levelType;
    }
  
    
}