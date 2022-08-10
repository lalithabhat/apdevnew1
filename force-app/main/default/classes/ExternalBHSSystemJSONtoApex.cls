public class ExternalBHSSystemJSONtoApex {
	public String access_token;
	public String token_type;
	public Integer expires_in;
	public String scope;

	public static ExternalBHSSystemJSONtoApex parse(String json) {
		return (ExternalBHSSystemJSONtoApex) System.JSON.deserialize(json, ExternalBHSSystemJSONtoApex.class);
	}
}