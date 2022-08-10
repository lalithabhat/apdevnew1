public class QuoteParser{

    public String label;
    public String value;

    
    public static List<QuoteParser> parse(String json) {
        return (List<QuoteParser>) System.JSON.deserialize(json, List<QuoteParser>.class);
    }
}