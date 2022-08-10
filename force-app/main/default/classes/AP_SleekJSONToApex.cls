/*********************************************************************************************************
*Client - Asian Paint
*Company - Stetig Consulting Pvt. Ltd.
*---------------------------------------------------------------------------------------------------------
*Created On - 04-10-2021
*Created By - Sarjerao Deshmukh
*---------------------------------------------------------------------------------------------------------
*Description - Apex service class to provide json to apex service.
*********************************************************************************************************/
public class AP_SleekJSONToApex {
	public String SUCCESS;
	public String RESPONSE_MESSAGE;
	public String USER_DATA;

	public static AP_SleekJSONToApex parse(String json) {
		return (AP_SleekJSONToApex) System.JSON.deserialize(json, AP_SleekJSONToApex.class);
	}
}