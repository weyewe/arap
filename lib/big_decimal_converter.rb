public class BigDecimalConverter
  def self.roundNumber(final BigDecimal number,  isFloor){
       return number.setScale(2, isFloor ? RoundingMode.FLOOR 
                                         : RoundingMode.CEILING);
  }
end