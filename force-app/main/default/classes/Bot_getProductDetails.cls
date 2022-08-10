public class Bot_getProductDetails {
    
    public class io{
        @InvocableVariable public String type;
        @InvocableVariable public String feature;
        @InvocableVariable public List<String> options;
        @InvocableVariable public String urls;
    }
    @InvocableMethod(label = 'Bot_getproductDetails')
    public static List<io> getProductDetails(List<io> input){
        system.debug(input);
        List<String> result = new List<String>();
        List<io> output = new List<io>();
        io i = new io();
        String query = '';
        
        if(input[0].type == null)
            query = 'Select Type__c Option  from Bot_Product_List__c where Type__c!=null AND Feature__c !=null AND Products__c!=null AND Page_URL__c!=null Group by Type__c';
        else if(input[0].feature == null)
            query = 'Select Feature__c Option  from Bot_Product_List__c where Type__c = \''+input[0].type +'\' AND Type__c!=null AND Feature__c !=null AND Products__c!=null AND Page_URL__c!=null Group by Feature__c';
        else{
            query = 'Select Products__c, Page_URL__c   from Bot_Product_List__c where Type__c = \''+input[0].type +'\' AND Feature__c = \''+ input[0].feature+'\' AND  Type__c!=null AND Feature__c !=null AND Products__c!=null AND Page_URL__c!=null';
            String url = '';
            for(Bot_Product_List__c b : Database.query(query)){
                url +=b.Products__c +'-'+ b.Page_URL__c +'\n';
            }
            i.urls = url;
            output.add(i);
            return output;
            
        }
        system.debug(query);
        
        for(Aggregateresult ag : Database.query(query)){
            result.add((String)ag.get('Option'));
        }
        result.add('Talk to an Agent');
       
        i.options = result;
        output.add(i);
        return output;
        
    }
}