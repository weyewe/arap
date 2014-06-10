require 'spec_helper'

describe PurchaseReceival do
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
    @item.reload 
  end
  
  it "should have pending receival item" do
    @item.pending_receival.should == @quantity
  end
   
  


  it "should create valid purchase receival" do
    
     
    @pr = PurchaseReceival.create_object(
      :receival_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :purchase_order_id     => @po.id 
    )
    
    @pr.should be_valid 
  end
  
  it "should require receival date and purchase order" do
    @pr = PurchaseReceival.create_object(
      :receival_date  => nil,
      :description    => "Awesome purchase order",
      :purchase_order_id     => @po.id 
    )
    
    @pr.should_not be_valid 
    
    @pr = PurchaseReceival.create_object(
      :receival_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :purchase_order_id     =>  nil
    )
    
    @pr.should_not be_valid
  end
  
  context "created purchase_receival => update" do
    before(:each) do
      @pr = PurchaseReceival.create_object(
        :receival_date  => DateTime.new(2012,2,2,0,0,0),
        :description    => "Awesome purchase receival",
        :purchase_order_id     => @po.id
      )
    end
    
    it "should  be updatable" do
      @pr.update_object(
        :receival_date  => DateTime.new(2012,2,2,0,0,0),
        :description    => "Awesome purchase rec",
        :purchase_order_id     => @po.id
      )
      
      @pr.errors.size.should == 0 
    end
    
    it "should be deletable" do
      @pr.delete_object
      @pr.persisted?.should be_false 
    end
    
    
  end
  
end
