public class OTP_Generator {
    
    public class OTP{
        @InvocableVariable
        public string code;
        
    }
    @InvocableMethod(label='Generate OTP'  category='Other')
    public static List<OTP> getOTP(){
        OTP o = new OTP();
        List<OTP> oList = new List<OTP>();
        o.code = String.valueOf(Math.Round(Math.Random() * 1000000)).leftPad(6,'0');
        oList.add(o);
        return oList;
        
        
    }
   /* @InvocableMethod(description='This method will be generating the OTP for users to Login' 
                     label='Generate OTP' 
                     category='OTP')
    public static List<String> generateOtp(){   
       	List<String> responseList = new List<String>();
        String randomIntegerString = string.valueof(Math.abs(Crypto.getRandomInteger()));
        String otp = randomIntegerString.substring(0,6);
        responseList.add(otp);
        return responseList;
    }*/
}