require 'spec_helper'

describe PurchaseReceivalDetail do
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
    
    @pr = PurchaseReceival.create_object(
      :receival_date  => DateTime.new(2012,2,2,0,0,0),
      :description    => "Awesome purchase order",
      :purchase_order_id     => @po.id 
    )
  end
  
  
  it "should allow purchase receival detail creation" do

    @received_quantity = 1 
    @pr_detail = PurchaseReceivalDetail.create_object(
      :purchase_receival_id         => @pr.id       ,
      :purchase_order_detail_id     => @po_detail.id     ,
      :quantity                     => @received_quantity   
    )
    
    @pr_detail.should be_valid 
  end
  
  context "created pr_detail" do
    before(:each) do
      @received_quantity = 1 
      
      @pr_detail = PurchaseReceivalDetail.create_object(
        :purchase_receival_id         => @pr.id       ,
        :purchase_order_detail_id     => @po_detail.id     ,
        :quantity                     => @received_quantity
      )
    end
    
    it "should be updatable" do
      @pr_detail.update_object(
        :purchase_receival_id         => @pr.id       ,
        :purchase_order_detail_id     => @po_detail.id     ,
        :quantity                     => @received_quantity + 1 
      )
      
      @pr_detail.errors.size.should == 0
      @pr_detail.should be_valid 
    end
    
    
    it "should not be updatable if total quantity is negative" do
      @pr_detail.update_object(
        :purchase_receival_id         => @pr.id       ,
        :purchase_order_detail_id     => @po_detail.id     ,
        :quantity                     => -1
      )
      
      @pr_detail.errors.size.should_not == 0
      @pr_detail.should_not be_valid
    end
    
    it "should be deletable" do
      @pr_detail.delete_object
      @pr_detail.persisted?.should be_false
    end
    
    it "should not allow double item ordered" do
      @pr_detail_2 = PurchaseOrderDetail.create_object(
        :purchase_order_id  => @po.id       ,
        :item_id            => @item.id     ,
        :quantity           => @quantity   +3  ,
        :discount           => 0  ,
        :unit_price         => @unit_price
      )
      
      @pr_detail_2.errors.size.should_not == 0  
    end
    
    
  end
end
