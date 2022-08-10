public class ServiceabilityInvocable {
	//This invokable method is being used in flow. Each class can have only one invokable method (as of API ver 53) 
	//so creating a new class.
	 @InvocableMethod(label='checkService'  category='Other')
    public static List<boolean> checkService(List<EnquiryToLead.ioWrapper> enq){
        List<boolean> result = new List<boolean>();
      	result.add(ServiceabilityManagement.getLeadServiceableFromBot(enq[0].pincode,enq[0].service));
        return result;
    }
}