class PurchaseReceivalDetail < ActiveRecord::Base
  belongs_to :purchase_order_detail
  belongs_to :purchase_receival
  
  validates_presence_of :purchase_order_detail_id, :quantity, :purchase_receival_id 
  
  validate :quantity_does_not_exceed_ordered_quantity 
  validate :quantity_non_negative
  validate :unique_purchase_order_detail
  validate :purchase_order_detail_come_from_the_same_purchase_order
  
  
  
  def quantity_does_not_exceed_ordered_quantity
    return if not quantity.present?
    return if not purchase_order_detail_id.present? 
    
    pending_receival_quantity = purchase_order_detail.pending_receival
    if quantity > pending_receival_quantity
      self.errors.add(:quantity, "Tidak boleh lebih dari #{pending_receival_quantity}")
      return self
    end
  end
  
  def quantity_non_negative
    return if not quantity.present?
    
    if quantity <= 0 
      self.errors.add(:quantity, "Tidak boleh lebih kecil dari 0")
      return self 
    end
  end
  
  def unique_purchase_order_detail
    return if not purchase_order_detail_id.present? 
    
    current_pr_id = self.purchase_receival_id
    current_po_detail_id = self.purchase_order_detail_id
    
    pr_detail_count = PurchaseReceivalDetail.where(
      :purchase_receival_id => current_pr_id,
      :purchase_order_detail_id => current_po_detail_id
    ).count 
    
    if self.persisted? and pr_detail_count > 1 
      self.errors.add(:purchase_order_detail_id , "Penerimaan item harus unique")
      return self 
    end
    
    if not self.persisted? and pr_detail_count > 0 
      self.errors.add(:purchase_order_detail_id , "Penerimaan item harus unique")
      return self
    end
  end
  
  def purchase_order_detail_come_from_the_same_purchase_order
    return if not purchase_order_detail_id.present?
    
    parent_purchase_order_id = self.purchase_receival.purchase_order_id
    
    if parent_purchase_order_id != self.purchase_order_detail.purchase_order_id
      self.errors.add(:purchase_order_detail_id, "Harus berasal dari purchase order yang sama dengan penerimaan")
      return self 
    end
  end
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.purchase_receival_id = params[:purchase_receival_id ]
    new_object.purchase_order_detail_id = params[:purchase_order_detail_id]
    new_object.quantity = params[:quantity]
    
    if new_object.save 
      new_object.invoiced_quantity = new_object.invoiced_quantity
      new_object.save
    end
    
    return new_object
  end
  
  
  def update_object(params)
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Tidak bisa update")
      return self 
    end
     
    self.purchase_order_detail_id = params[:purchase_order_detail_id]
    self.quantity = params[:quantity]
    
    if self.save
      self.invoiced_quantity = self.invoiced_quantity
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
    if purchase_order_detail.pending_receival - quantity < 0 
      return false 
    end
      
    return true
  end
  
  
  def post_confirm_update_stock_mutation
    item = self.purchase_order_detail.item  
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      STOCK_MUTATION_CASE[:addition] , # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:ready]   # stock_mutation_item_case
     ) 
    item.update_stock_mutation( stock_mutation )
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      STOCK_MUTATION_CASE[:deduction] , # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:pending_receival]   # stock_mutation_item_case
     )
    item.update_stock_mutation( stock_mutation )
  end
  
  
  def post_confirm_update_price_mutation
    puts "haven't implemented post confirm price mutation @purchase_receival"
  end
   
  
  def confirm_object(confirmation_datetime)
    return self if not self.confirmable?
    
    self.is_confirmed = true 
    self.confirmed_at = confirmation_datetime
    self.save 
    
    self.post_confirm_update_stock_mutation
    self.post_confirm_update_price_mutation 
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
    
    stock_mutation = StockMutation.get_by_source_document_detail( self, STOCK_MUTATION_ITEM_CASE[:ready] ) 
    item.reverse_stock_mutation( stock_mutation )
    stock_mutation.destroy 
    
    item.reload 
    
    stock_mutation = StockMutation.get_by_source_document_detail( self, STOCK_MUTATION_ITEM_CASE[:pending_receival] ) 
    item.reverse_stock_mutation( stock_mutation )
    stock_mutation.destroy
    
  end
end
