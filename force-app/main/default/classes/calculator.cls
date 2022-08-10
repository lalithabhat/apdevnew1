public class calculator {
    
    public decimal number1 {get;set;}
    public decimal number2 {get;set;}
    public decimal result {get;set;}
    public void add(){
        result=number1+number2;
        System.debug(result);
    }
}