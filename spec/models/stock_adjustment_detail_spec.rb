require 'spec_helper'

describe StockAdjustmentDetail do
  before(:each) do
    sku = "acedin3321"
    description = "awesome"
    standard_price = BigDecimal("80000")
    @item = Item.create_object(
    :sku            => sku,
    :description    => description, 
    :standard_price => standard_price
    )
    
    @stock_adjustment = StockAdjustment.create_object(
      :adjustment_date => DateTime.new( 2013,5,5,0,0,0), 
      :description => "Awesome stock adjustment"
    )
    
  end
   
  it "should allow stock adjustment detail creation" do
    @stock_adjustment_detail = StockAdjustmentDetail.create_object(
      :item_id => @item.id , 
      :stock_adjustment_id => @stock_adjustment.id, 
      :quantity => 3, 
      :unit_price => BigDecimal("1500")
    )
    
    @stock_adjustment_detail.should be_valid 
  end
  
  context "created stock_adjustment_detail" do
    before(:each) do
      @stock_adjustment_detail = StockAdjustmentDetail.create_object(
        :item_id => @item.id , 
        :stock_adjustment_id => @stock_adjustment.id, 
        :quantity => 3, 
        :unit_price => BigDecimal("1500")
      )

    end
    
    it "should be updatable" do
      @stock_adjustment_detail.update_object(
        :item_id => @item.id , 
        :quantity => 2, 
        :unit_price => BigDecimal("1500")
      )
      
      @stock_adjustment_detail.errors.size.should == 0
      @stock_adjustment_detail.should be_valid 
    end
    
    
    it "should not be updatable if total quantity is negative" do
      
      @stock_adjustment_detail.update_object(
        :item_id => @item.id , 
        :quantity => -3, 
        :unit_price => BigDecimal("1500")
      )
      
      @stock_adjustment_detail.errors.size.should_not == 0
      @stock_adjustment_detail.should_not be_valid
    end
    
    it "should be deletable" do
      @stock_adjustment_detail.delete_object
      
      @stock_adjustment_detail.persisted?.should be_false
    end
    
    
  end
  
  
  
end
