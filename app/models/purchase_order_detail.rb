class PurchaseOrderDetail < ActiveRecord::Base
  belongs_to :purchase_order 
  belongs_to :item 
  has_many :purchase_receival_details
  
  validates_presence_of :quantity, :unit_price,:item_id,  :discount 
  
  validate :non_zero_quantity
  validate :non_negative_unit_price
  validate :discount_within_limit
  validate :unique_ordered_item 
  
  def non_zero_quantity
    return if not quantity.present? 
    
    if quantity <= 0 
      self.errors.add(:quantity, "Jumlah tidak boleh 0")
      return self 
    end
  end
  
  def non_negative_unit_price
    return if not unit_price.present? 
    
    if unit_price < BigDecimal("0")
      self.errors.add(:unit_price, "Harga tidak boleh negative")
      return self 
    end
  end
  
  def discount_within_limit
    return if not discount.present?
    lower_limit = BigDecimal("0")
    upper_limit = BigDecimal("100")
    
    if not ( discount >= lower_limit and discount <= upper_limit )
      self.errors.add(:discount, "Harus di antara 0 dan 100")
      return self 
    end
  end
  
  def unique_ordered_item
    return if not item_id.present? 
    
    ordered_item_count  = PurchaseOrderDetail.where(
      :item_id => item_id,
      :purchase_order_id => purchase_order_id
    ).count 
    
    ordered_item = PurchaseOrderDetail.where(
      :item_id => item_id,
      :purchase_order_id => purchase_order_id
    ).first
    
    if self.persisted? and ordered_item.id != self.id   and ordered_item_count == 1
      self.errors.add(:item_id, "Item harus uniq dalam 1 pemesanan")
      return self 
    end
    
    # there is item with such item_id in the database
    if not self.persisted? and ordered_item_count != 0 
      self.errors.add(:item_id, "Item harus uniq dalam 1 pemesanan")
      return self
    end
  end
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.purchase_order_id = params[:purchase_order_id ]
    new_object.item_id = params[:item_id]
    new_object.quantity = params[:quantity]
    new_object.discount = params[:discount]
    new_object.unit_price = params[:unit_price]
    if new_object.save 
      new_object.pending_receival = new_object.quantity
      new_object.save
    end
    
    return new_object
  end
  
  
  def update_object(params)
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Tidak bisa update")
      return self 
    end
     
    self.item_id = params[:item_id]
    self.quantity = params[:quantity]
    self.discount = params[:discount]
    self.unit_price = params[:unit_price]
    if self.save
      self.pending_receival = self.quantity
      self.save
    end
  end
   
  
  
  
  def delete_object
    if not self.is_confirmed?
      self.destroy 
    else
      self.errors.add(:generic_errors, "Sudah konfirmasi. Tidak bisa delete")
      return self 
    end
  end
  
  
  
  def confirmable? 
    return true
  end
  
  
  def post_confirm_update_stock_mutation
    item = self.item 
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      STOCK_MUTATION_CASE[:addition] , # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:pending_receival]   # stock_mutation_item_case
     
     ) 
    item.update_stock_mutation( stock_mutation )
  end
  
   
  
  def confirm_object(confirmation_datetime)
    return self if not self.confirmable?
    
    self.is_confirmed = true 
    self.confirmed_at = confirmation_datetime
    self.save 
    
    self.post_confirm_update_stock_mutation 
  end
  
  def unconfirmable?
    if pending_receival != quantity
      self.errors.add(:generic_errors, "Sudah ada penerimaan barang")
      return false 
    end
    
    return true 
  end
  
  def unconfirm_object
    return self if not self.unconfirmable?
    
    self.is_confirmed = false 
    self.confirmed_at = nil 
    self.save 
    
    stock_mutation = StockMutation.get_by_source_document_detail( self , STOCK_MUTATION_ITEM_CASE[:pending_receival] ) 
    item.reverse_stock_mutation( stock_mutation )
    stock_mutation.destroy 
    
  end
end
