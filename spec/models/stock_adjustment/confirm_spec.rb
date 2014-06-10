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
  
  it "should not be confirmable" do
    @stock_adjustment.confirm_object(
      :confirmed_at => DateTime.now 
    )
    
    @stock_adjustment.errors.size.should_not == 0 
  end
  
  context "adding stock_adjustment_detail" do
    before(:each) do
      @quantity = 3
      @price = BigDecimal("1500")
      @stock_adjustment_detail = StockAdjustmentDetail.create_object(
        :item_id => @item.id , 
        :stock_adjustment_id => @stock_adjustment.id, 
        :quantity => @quantity, 
        :unit_price => @price
      )
    
    end
    
    it "should  be confirmable" do
      @stock_adjustment.confirm_object(
        :confirmed_at => DateTime.now 
      )
  
      @stock_adjustment.errors.size.should == 0 
      @stock_adjustment.should be_valid 
    end
    
    context "confirm stock_adjustment" do
      before(:each) do
        @initial_item_ready = @item.ready 
        @initial_stock_mutation_count = StockMutation.count 
        @stock_adjustment.confirm_object(
          :confirmed_at => DateTime.now 
        )
        
        @final_stock_mutation_count = StockMutation.count 
        @item.reload 
        @final_item_ready  = @item.ready
        
        
        @stock_adjustment_detail.reload 
      end
      
      it "should create stock_mutation"  do
        stock_mutation_count_diff = @final_stock_mutation_count - @initial_stock_mutation_count
        stock_mutation_count_diff.should == 1  
        
        stock_mutation = StockMutation.get_by_source_document_detail( @stock_adjustment_detail )
        stock_mutation.should be_valid
        stock_mutation.quantity.should == @stock_adjustment_detail.quantity.abs
        
        stock_mutation.case.should == STOCK_MUTATION_CASE[:addition]
        stock_mutation.item_case.should == STOCK_MUTATION_ITEM_CASE[:ready]
      end
      
      it "should increase average cost" do
        @item.avg_cost.should_not == BigDecimal("0")
        avg_cost = @quantity*@price
        @item.avg_cost.should == (avg_cost/@quantity).round(2)
      end
       
      it "should increase ready item" do
        item_ready_diff = @final_item_ready - @initial_item_ready 
        item_ready_diff.should == @stock_adjustment_detail.quantity.abs 
      end
      
      it "should not allow update stock_adjustment_detail" do
        @stock_adjustment_detail.update_object(
          :item_id => @item.id , 
          :quantity => -3, 
          :unit_price => BigDecimal("1500")
        )

        @stock_adjustment_detail.errors.size.should_not == 0
      end
      
      it "should be confirmed" do
        @stock_adjustment_detail.is_confirmed.should be_true 
      end
      
      it "should not allow stock_adjustment_detail deletion" do
        @stock_adjustment_detail.delete_object
        
        @stock_adjustment_detail.errors.size.should_not == 0
      end
    end
  end
   
  
  
  
end
