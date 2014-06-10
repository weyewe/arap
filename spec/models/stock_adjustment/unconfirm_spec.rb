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
    
    @adjustment_quantity = 3 
    @stock_adjustment_detail = StockAdjustmentDetail.create_object(
      :item_id => @item.id , 
      :stock_adjustment_id => @stock_adjustment.id, 
      :quantity => @adjustment_quantity, 
      :unit_price => BigDecimal("1500")
    )
    
    @initial_item_ready = @item.ready 
    @initial_stock_mutation_count = StockMutation.count 
    @stock_adjustment.confirm_object(
      :confirmed_at => DateTime.now 
    )
    
    @item.reload 
    
    @stock_adjustment_detail.reload
    @stock_adjustment.reload
    @item.reload 
    @initial_item_ready = @item.ready
  end
  
  it "should have confirmed stock_adjustment_detail"  do
    @stock_adjustment_detail.is_confirmed.should be_true 
  end
  
  it "should have confirmed stock_adjustment" do
    @stock_adjustment.is_confirmed.should be_true 
  end
  
  it "should have unconfirmable stock_adjustment_detail" do
    
    puts "======>\n"*5
    puts "gomnna change"
    
    
    
    puts "ready item: #{@item.ready}"
    puts "quantity in stock_adjustment : #{@stock_adjustment_detail.quantity}"
    initial_amount = @item.ready * @item.avg_cost
    puts "initial_amount: #{initial_amount}"
    adjustment_amount = @stock_adjustment_detail.quantity * @stock_adjustment_detail.unit_price
    puts "adjustment amount: #{adjustment_amount}"
    
    final_amount = initial_amount + -1*adjustment_amount
    puts "final_amount :  #{final_amount.to_s}"
    
    
    @stock_adjustment_detail.unconfirmable?.should be_true
  end
  
  context "unconfirm" do
    before(:each) do
      @item.reload
      @item_ready = @item.ready 
      @stock_adjustment.unconfirm_object
      @stock_adjustment.reload
      @stock_adjustment_detail.reload 
      @item.reload 
    end
    
   
    
    it "should unconfirm both parent and details" do
      @stock_adjustment.is_confirmed.should be_false
      @stock_adjustment_detail.is_confirmed.should be_false
    end
    

    it "should restore the item#ready quantity" do
      item_ready_diff = @item.ready - @initial_item_ready

      item_ready_diff.should == -1*@adjustment_quantity
    end

    it "should delete the stock mutation" do
      StockMutation.get_by_source_document_detail(@stock_adjustment_detail, STOCK_MUTATION_ITEM_CASE[:ready]).should be_nil 
    end
    
    it "should update the average cost" do
      @item.avg_cost.should == BigDecimal("0")
    end
  end
  
  
  
  
end
