public class UpdateFileTagClass {

    @InvocableMethod(label='Update File Tag flow' Description='use in flow for the Updating the file tag')
    public static List<string> updateFileTag(List<FlowRequest> req){
        system.debug('req::'+req);
        
        List<string> result = new List<string>();
        try{
            ContentVersion cv = new ContentVersion();
            cv.Id = req[0].contentId[0];
            cv.TagCsv = req[0].tag;
            cv.Description = req[0].tag;
            update cv;
            result.add('File uploaded successfully');
            return result;
        }catch(Exception ex){
            result.add(ex.getMessage());
            return result;
        }
        //return null;
    }
    public class FlowRequest{
        @InvocableVariable
        public List<string> contentId;
        @InvocableVariable
        public string tag;
    }
}