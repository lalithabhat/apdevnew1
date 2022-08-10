public with sharing class GetPickList {
    @AuraEnabled(cacheable=true)
        public static Map<String,String> getPicklistValues(String ObjectApi_name,String Field_name){ 
            system.debug('ObjectApi_name '+ObjectApi_name);
            system.debug('Field_name '+Field_name);
            Map<String,String> lstPickvals=new Map<String,String>();
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
            for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                lstPickvals.put(a.getValue(),a.getValue());//add the value  to our final list
                system.debug('a.getValue()'+ a.getValue());
            }
            
            return lstPickvals;
        } 
        @AuraEnabled(cacheable=true)
        Public static Map<string,string> getOneLevelUpProduct(string productId){
            system.debug('productId:: '+productId);
            List<Product2> originalProduct = [select id,name,Product_Class__c from Product2 where id=: productId];
            string classVal = originalProduct[0].Product_Class__c;
            List<Product_Class_Sequence__c > seqs = [select id,name,Sequence__c from Product_Class_Sequence__c order by Sequence__c ASC];
            Map<string, Product_Class_Sequence__c> classMap = new Map<string,Product_Class_Sequence__c>();
            Map<Decimal, Product_Class_Sequence__c> seqMap = new Map<Decimal,Product_Class_Sequence__c>();
            for(Product_Class_Sequence__c p :seqs){
                classMap.put(p.name,p);
                seqMap.put(p.Sequence__c,p);
            }
            string upperClass;
            if(classMap.containskey(classVal)){
                Decimal s = classMap.get(classVal).Sequence__c;
                s = s-1;
                if(seqMap.containskey(s)){
                    upperClass = seqMap.get(s).name;
                }
            }
            system.debug('upperClass:: '+upperClass);
            Map<string,string> finalMap = new Map<string,string>();
            if(string.isNotBlank(upperClass)){
                List<Product2> pdList = [select id,name from Product2 where Product_Class__c =: upperClass and 
                                        Top_3__c != null order by Top_3__c ASC];
                for(Product2 p : pdList){
                    finalMap.put(p.Id,p.Name);
                }                       
            }
            system.debug('finalMap::'+finalMap);
            return finalMap;

        }
    }