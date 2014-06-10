class StockAdjustmentDetail < ActiveRecord::Base
  belongs_to :stock_adjustment
  belongs_to :item 
  
  validates_presence_of :quantity, :unit_price,:item_id, :stock_adjustment_id 
  
  validate :non_zero_quantity
  validate :non_negative_unit_price
  validate :non_negative_final_average_cost
  validate :non_negative_final_quantity
  
  def non_zero_quantity
    return if not quantity.present? 
    if quantity == 0 
      self.errors.add(:quantity, "Tidak boleh 0 ")
      return self 
    end
  end
  
  def non_negative_unit_price
    return if not unit_price.present? 
    
    
    if unit_price < BigDecimal("0")
      self.errors.add(:unit_price, "Tidak boleh negative")
      return self 
    end
  end
  
  def non_negative_final_average_cost
    return if not item.present? 
    return if not unit_price.present? 
    return if not quantity.present? 
    
    additional_amount = unit_price * quantity 
    initial_amount = item.avg_price * item.ready
    
    if additional_amount + initial_amount < BigDecimal("0")
      self.errors.add(:unit_price, "Average cost tidak boleh negative")
      return self 
    end
  end
  
  def non_negative_final_quantity
    return if not item.present? 
    return if not unit_price.present? 
    return if not quantity.present?
    
    initial_quantity = item.ready
    additional_quantity = quantity
    
    if additional_quantity + initial_quantity < 0 
      self.errors.add(:quantity, "Jumlah akhir tidak boleh negative")
      return self 
    end
  end
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.stock_adjustment_id = params[:stock_adjustment_id ]
    new_object.item_id = params[:item_id]
    new_object.quantity = params[:quantity]
    new_object.unit_price = params[:unit_price]
    new_object.save 
    
    return new_object
  end
  
  def update_object(params)
    
    self.stock_adjustment_id = params[:stock_adjustment_id ]
    self.item_id = params[:item_id]
    self.quantity = params[:quantity]
    self.unit_price = params[:unit_price]
    self.save
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
    self.non_negative_final_quantity
    return false if self.errors.size != 0  
    
    self.non_negative_final_average_cost
    return false if self.errors.size != 0
    
    return true
  end
  
  def confirm_object
    return self if not self.confirmable?
    
    self.is_confirmed = true 
    self.confirmed_at = self.stock_adjustment.confirmed_at
    self.save 
    
    stock_mutation_case = STOCK_MUTATION_CASE[:addition] 
    stock_mutation_case = STOCK_MUTATION_CASE[:deduction]  if self.quantity < 0 
    
    stock_mutation = StockMutation.create_object( 
      self.item, # the item 
      self, # source_document_detail 
      stock_mutation_case, # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:ready]   # stock_mutation_item_case
     ) 
    item.update_stock_mutation( stock_mutation )
  end
  
  def unconfirmable?
    return true if not self.is_confirmed?
    # if the deletion doesn't change the quantity to be negative
    self.quantity = -1 * self.quantity
    self.non_negative_final_quantity
    return false if self.errors.size != 0  
    
    self.non_negative_final_average_cost
    return false if self.errors.size != 0
    
    return true 
  end
  
  def unconfirm_object
    return self if not self.unconfirmable?
    
    self.is_confirmed = false 
    self.confirmed_at = nil 
    self.save 
    
    stock_mutation = StockMutation.get_by_source_document_detail( self ) 
    item.reverse_stock_mutation( stock_mutation )
    stock_mutation.destroy 
  end
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
end
