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
    @unit_price = BigDecimal("1500")
    @discount = BigDecimal("5")
    @po_detail = PurchaseOrderDetail.create_object(
          :purchase_order_id  => @po.id       ,
          :item_id            => @item.id     ,
          :quantity           => @quantity    ,
          :discount           => @discount    ,
          :unit_price         => @unit_price
        )
        
    @po.confirm_object(
      :confirmed_at => DateTime.now 
    )
    @po_detail.reload
    @po.reload
  end
  
  it "should set po_detail as confirmable" do
    @po_detail.confirmable?.should be_true 
  end
  
  it "should have confirmed po_detail"  do
    @po_detail.is_confirmed.should be_true 
  end
  
  it "should have confirmed po" do
    @po.is_confirmed.should be_true 
  end
  
  it "should have unconfirmable po_detail" do
    @po_detail.unconfirmable?.should be_true
  end
  
  it "should generate stock mutation to adjust pending_receival" do
    stock_mutation = StockMutation.get_by_source_document_detail(@po_detail, STOCK_MUTATION_ITEM_CASE[:pending_receival]) 
    stock_mutation.item_case.should == STOCK_MUTATION_ITEM_CASE[:pending_receival]
    stock_mutation.case.should == STOCK_MUTATION_CASE[:addition]
  end
  
  context "unconfirm" do
    before(:each) do
      @item.reload
      @item_pending_receival = @item.pending_receival 
      @po.unconfirm_object
      @po.reload
      @po_detail.reload 
      @item.reload 
    end
    
    it "should unconfirm both parent and details" do
      @po.is_confirmed.should be_false
      @po_detail.is_confirmed.should be_false
    end
    
    
    it "should restore the item#pending_receival quantity" do
      item_pending_receival_diff = @item.pending_receival - @item_pending_receival
      item_pending_receival_diff.should == -1*@quantity
    end
    
    it "should delete the stock mutation" do
      StockMutation.get_by_source_document_detail(@po_detail, STOCK_MUTATION_ITEM_CASE[:pending_receival]).should be_nil 
    end
     
  end
end
