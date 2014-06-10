require 'spec_helper'

describe StockAdjustment do
  before(:each) do
    sku = "acedin3321"
    description = "awesome"
    standard_price = BigDecimal("80000")
    @item = Item.create_object(
    :sku            => sku,
    :description    => description, 
    :standard_price => standard_price
    )
  end
   

  it "should create valid stock adjustment" do
    @stock_adjustment = StockAdjustment.create_object(
      :adjustment_date => DateTime.new( 2013,5,5,0,0,0), 
      :description => "Awesome stock adjustment"
    )
    
    @stock_adjustment.should be_valid 
  end
  
  it "should require adjustment_date" do
    @stock_adjustment = StockAdjustment.create_object(
      :adjustment_date => nil, 
      :description => "Awesome stock adjustment"
    )
    
    @stock_adjustment.should_not be_valid 
  end
  
  context "created stock_adjustment => update" do
    before(:each) do
      @stock_adjustment = StockAdjustment.create_object(
        :adjustment_date => nil, 
        :description => "Awesome stock adjustment"
      )
    end
    
    it "should  be updatable" do
      @stock_adjustment.update_object(
        :adjustment_date => DateTime.now, 
        :description => "Awesome stock adjustment"
      )
      
      @stock_adjustment.errors.size.should == 0 
    end
    
    it "should be deletable" do
      @stock_adjustment.delete_object
      @stock_adjustment.persisted?.should be_false 
    end
    
    
  end
   
   
  
  
  
end
