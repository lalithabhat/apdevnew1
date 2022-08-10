public without sharing class SamplePostChatPageController {
    public String inputText1{get;set;} // id from vfpage
    public String chatKey{get;set;}
    public Boolean isLike{get;set;}
    public Boolean isDislike{get;set;}
    public String Comment{get;set;}
    public Boolean isRendered{get;set;}
    
    public String Feedback{get;set;}
    public Boolean flag1 {set;get;}
    public Boolean flag2 {set;get;}
    
    public LiveChatTranscript lct{get;set;}
    public SamplePostChatPageController(){
        isRendered = True;
        System.debug('ApexPages.currentPage().getParameters()'+ApexPages.currentPage().getParameters().get('chatKey'));
        if(ApexPages.currentPage().getParameters().get('chatKey') != null){
            chatKey = ApexPages.currentPage().getParameters().get('chatKey');
        }
    }
    
    public PageReference save() {
        Feedback=ApexPages.currentPage().getParameters().get('Feedback');

        System.debug('-----chatKey----'+chatKey);
        System.debug('-----isLike----'+isLike);
        System.debug('-----Comment----'+Comment);
        System.debug('-----Feedback----'+Feedback);
        System.debug('-----flag1----'+flag1);
        System.debug('-----flag2----'+flag2);
        
        List<LiveChatTranscript> lct = [select id, Name, ChatKey, LeadId, Survey_Liked__c,Survey_Disliked__c, Survey_Comment__c 
                                        from LiveChatTranscript where ChatKey =: chatKey
                                        Order By LastModifiedDate Desc];        
        System.debug('-----lct2.size()----'+lct.size());
        System.debug('-----lct2[0]----'+lct[0]);
        System.debug('-----lct2[0]----'+lct[0]);
        if(Feedback == '1'){
            lct[0].Survey_Liked__c = True;
        }
        else if(Feedback == '2'){
            lct[0].Survey_Disliked__c = True;
        }
        if(lct[0].LeadId != null){
            List<Lead> l= [select id, Name, Chat_Survey_Liked__c, Chat_Survey_Comment__c 
                           from Lead where id =: lct[0].LeadId];
            System.debug('-----l[0]----'+l[0]);
            if(Feedback == '1'){
                l[0].Chat_Survey_Liked__c = True;
            }
            else if(Feedback == '2'){
                l[0].Chat_Survey_Disliked__c = True;
            }
            l[0].Chat_Survey_Comment__c = Comment;
            update l;
        }
        lct[0].Survey_Comment__c = Comment;
        
        update lct;
        isRendered = False;
        
        //lead l = [select id, House__c  from lead where id =: '00Q72000001dYPREA2'];
        //update l;
        return null;
        
    }
    
    
}