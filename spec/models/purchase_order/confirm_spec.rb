require 'spec_helper'

describe PurchaseOrder do
  before(:each) do
    sku = "acedin3321"
    description = "awesome"
    standard_price = BigDecimal("80000")
    @item = Item.create_object(
    :sku            => sku,
    :description    => description, 
    :standard_price => standard_price
    )
    
    @contact = Contact.create_object(
      :name             => "Contact"           ,
      :description      => "Description"      ,
      :address          =>  "Address"        ,
      :shipping_address => "Shipping Address"
    )
    
    @po = PurchaseOrder.create_object(
      :purchase_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :contact_id     => @contact.id 
    )
    
    @quantity = 3
    @discount = 0
    @unit_price  = BigDecimal("1500")
    
    
    
  end
  
  it "should not be confirmable" do
    @po.confirm_object(
      :confirmed_at => DateTime.now 
    )
    
    @po.errors.size.should_not == 0 
  end
  
  context "adding po_detail" do
    before(:each) do
      @quantity = 3
      @unit_price = BigDecimal("1500")
      @discount = BigDecimal("5")
      @po_detail = PurchaseOrderDetail.create_object(
            :purchase_order_id  => @po.id       ,
            :item_id            => @item.id     ,
            :quantity           => @quantity    ,
            :discount           => @discount    ,
            :unit_price         => @unit_price
          )
    
    end
    
    it "should  be confirmable" do
      @po.confirm_object(
        :confirmed_at => DateTime.now 
      )
  
      @po.errors.size.should == 0 
      @po.should be_valid 
    end
    
    context "confirm po" do
      before(:each) do
        @initial_item_ready = @item.ready 
        @initial_item_pending_receival = @item.pending_receival
        @initial_stock_mutation_count = StockMutation.count 
        @po.confirm_object(
          :confirmed_at => DateTime.now 
        )
        
        @final_stock_mutation_count = StockMutation.count 
        @item.reload 
        @final_item_ready  = @item.ready
        
        
        @po_detail.reload 
      end
      
      it "should create stock_mutation"  do
        stock_mutation_count_diff = @final_stock_mutation_count - @initial_stock_mutation_count
        stock_mutation_count_diff.should == 1  
        
        stock_mutation = StockMutation.get_by_source_document_detail( @po_detail, STOCK_MUTATION_ITEM_CASE[:pending_receival] )
        stock_mutation.should be_valid
        stock_mutation.quantity.should == @po_detail.quantity.abs
        
        stock_mutation.case.should == STOCK_MUTATION_CASE[:addition]
        stock_mutation.item_case.should == STOCK_MUTATION_ITEM_CASE[:pending_receival]
      end
      
      
      
      it "should not allow update po_detail" do
        @po_detail.update_object(
          :purchase_order_id  => @po.id       ,
          :item_id            => @item.id     ,
          :quantity           => @quantity  + 1   ,
          :discount           => @discount    ,
          :unit_price         => @unit_price
        )
        
        @po_detail.errors.size.should_not == 0
      end
      
      it "should increase the item's pending receival" do
        
        @final_item_pending_receival = @item.pending_receival 
        
        diff = @final_item_pending_receival - @initial_item_pending_receival
        diff.should == @quantity 
      end
      
      it "should be confirmed" do
        @po_detail.is_confirmed.should be_true 
      end
      
      it "should not allow po_detail deletion" do
        @po_detail.delete_object
        
        @po_detail.errors.size.should_not == 0
      end
    end
  end
   
  
  
  
end
