require 'spec_helper'

describe PurchaseOrderDetail do
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
   
  it "should allow purchase order detail creation" do
    @po_detail = PurchaseOrderDetail.create_object(
      :purchase_order_id  => @po.id       ,
      :item_id            => @item.id     ,
      :quantity           => @quantity    ,
      :discount           => @discount    ,
      :unit_price         => @unit_price
    )
    
    @po_detail.should be_valid 
  end
  
  context "created po_detail" do
    before(:each) do
      @po_detail = PurchaseOrderDetail.create_object(
        :purchase_order_id  => @po.id       ,
        :item_id            => @item.id     ,
        :quantity           => @quantity    ,
        :discount           => @discount    ,
        :unit_price         => @unit_price
      )
    end
    
    it "should be updatable" do
      @po_detail.update_object(
        :item_id => @item.id , 
        :quantity => 5, 
        :unit_price => BigDecimal("15000"),
        :discount => BigDecimal("5")
      )
      
      @po_detail.errors.messages.each {|x| puts "===========> #{x}"}
      @po_detail.errors.size.should == 0
      @po_detail.should be_valid 
    end
    
    
    it "should not be updatable if total quantity is negative" do
      @po_detail.update_object(
        :item_id => @item.id , 
        :quantity => -5, 
        :unit_price => BigDecimal("15000"),
        :discount => BigDecimal("5")
      )
      
      @po_detail.errors.size.should_not == 0
      @po_detail.should_not be_valid
    end
    
    it "should be deletable" do
      @po_detail.delete_object
      @po_detail.persisted?.should be_false
    end
    
    it "should not allow double item ordered" do
      @po_detail_2 = PurchaseOrderDetail.create_object(
        :purchase_order_id  => @po.id       ,
        :item_id            => @item.id     ,
        :quantity           => @quantity   +3  ,
        :discount           => 0  ,
        :unit_price         => @unit_price
      )
      
      @po_detail_2.errors.size.should_not ==0  
    end
    
    
    
    
  end
  
  
  
end
