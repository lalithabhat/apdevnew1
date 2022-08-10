public class QuoteLineItemParse {

    public String label;
    public List<Quotation.quoteLineItemWrapper> value;

    
    public static List<QuoteLineItemParse> parse(String json) {
        return (List<QuoteLineItemParse>) System.JSON.deserialize(json, List<QuoteLineItemParse>.class);
    }
}