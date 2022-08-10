@RestResource(urlMapping='/ServiceAbility/*')
global class REST_ServiceAbilityAPI {
    @HttpPost
    global static REST_Result getDetails(REST_Request req)
    {
        REST_Result r = new REST_Result();
        r.BHS_CES_flag=false;
        r.BHS_DA_flag=false;
        r.SPS_CA_flag=false;
        r.SPS_SA_flag=false;
        List<String>loblist=new List<String>();
        //ask for 6 digit length validation
        if(String.isBlank(req.pincode))
        {
            //s='error';
            
            r.message='Required parameters are missing';
            r.returnCode='400';
            r.List_lob=null;
            System.debug('pincode blank');
            
            
        }
        else
        {
            //pincode is in list
            try
            {
                //check whether pincode is present in system
                List<SA_Pincode_Mapping__c> pinCodeList = [SELECT Pincode__c, Role__c,Service__c,Skills__c FROM SA_Pincode_Mapping__c WHERE Pincode__c =:req.pincode AND SA__r.Active__c =: true];
                if(pinCodeList.isEmpty())
                {
                    //Ask about message to be printed
                    String s = 'No Records Retrieved. Please re-check your pincode and LOB and Check whether the user is active';
                    
                    r.message=s;
                    r.returnCode='400';
                    r.List_lob=null;
                    
                }
                else
                {
                    //List not empty
                    for(SA_Pincode_Mapping__c getList: pinCodeList)
                    {
                        if((getList.Service__c).equalsIgnoreCase('BHS'))
                        {
                            		if((getList.Role__c).equalsIgnoreCase('DA'))
                                    {
                                        r.BHS_DA_flag=true;
                                    }
                            		if((getList.Role__c).equalsIgnoreCase('CES'))
                                    {
                                        r.BHS_CES_flag=true; 
                                    }
                                   
                        }
                        if((getList.Service__c).equalsIgnoreCase('SPS'))
                        {
                            		if((getList.Role__c).equalsIgnoreCase('SA'))
                                    {
                                        r.SPS_SA_flag=true;
                                    }
                            		if((getList.Role__c).equalsIgnoreCase('CA'))
                                    {
                                        r.SPS_CA_flag=true;
                                    }
                                    
                        }
                        
                        
                        
                    }
                    if((r.SPS_SA_flag==true) || (r.SPS_CA_flag==true))
                    {          
                                 loblist.add('SPS');            
                    }
                    if((r.BHS_DA_flag==true) || (r.BHS_CES_flag==true))
                   	{
                                loblist.add('BHS');
                   	}
                    if((r.BHS_DA_flag==false) && (r.BHS_CES_flag==false) && (r.SPS_SA_flag==false) && (r.SPS_CA_flag==false))
                    {
                    		loblist.add('TCS'); 
                    }
                    r.message='Success';
                    r.returnCode='201';
                    r.List_lob=loblist.clone();
                    
                }
                
            }catch(Exception e)
            {
                
                r.message='Pincode not list-catch block';
                r.returnCode='400';
                r.List_lob=null;
                
            }
        }
        return r;
    }
    
    global class REST_lobList
    {
        webservice List<String> lob_list;
        global REST_lobList()
        {
            lob_list=new List<String>();
        }
    }
    global class REST_Result
    {
        webservice String returnCode;
        webservice String message;
        webservice List<String>List_lob;
        webservice Boolean SPS_CA_flag;
        webservice Boolean SPS_SA_flag;
        webservice Boolean BHS_CES_flag;
        webservice Boolean BHS_DA_flag;
    }
    global class REST_Request {
        webservice String pincode;
        
    }
}