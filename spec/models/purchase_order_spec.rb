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
    
    
  end
   
  it "should create valid item and contact" do
    @item.should be_valid
    @contact.should be_valid
  end
  


  it "should create valid stock adjustment" do
    @po = PurchaseOrder.create_object(
      :purchase_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :contact_id     => @contact.id 
    )
    
    @po.should be_valid 
  end
  
  it "should require purchase_date and contact" do
    @po = PurchaseOrder.create_object(
      :purchase_date  => nil, 
      :description    => "Awesome purchase order",
      :contact_id     => @contact.id
    )
    
    @po.should_not be_valid 
    
    @po = PurchaseOrder.create_object(
      :purchase_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :contact_id     => nil 
    )
    
    @po.should_not be_valid
  end
  
  context "created purchase_order => update" do
    before(:each) do
      @po = PurchaseOrder.create_object(
        :purchase_date  => DateTime.new(2012,2,2,0,0,0),
        :description    => "Awesome purchase order",
        :contact_id     => @contact.id 
      )
    end
    
    it "should  be updatable" do
      @po.update_object(
        :purchase_date  => DateTime.new(2012,2,2,0,0,0),
        :description    => "Awesome purchase order",
        :contact_id     => @contact.id
      )
      
      @po.errors.size.should == 0 
    end
    
    it "should be deletable" do
      @po.delete_object
      @po.persisted?.should be_false 
    end
    
    
  end
   
   
  
  
  
end
