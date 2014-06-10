class StockAdjustmentDetail < ActiveRecord::Base
  belongs_to :stock_adjustment
  belongs_to :item 
  
  validates_presence_of :quantity, :unit_price,:item_id, :stock_adjustment_id 
  
  validate :non_zero_quantity
  validate :non_negative_unit_price
  validate :non_negative_final_average_cost
  validate :non_negative_final_quantity
  validate :both_quantity_and_inventory_amount_must_be_0_at_the_same_time
  
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
    initial_amount = item.avg_cost * item.ready
    final_amount = (additional_amount + initial_amount).round(2)
    
    if final_amount < BigDecimal("0")
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
    final_quantity = additional_quantity + initial_quantity
    
    if final_quantity  < 0 
      self.errors.add(:quantity, "Jumlah akhir tidak boleh negative")
      return self 
    end
     
  end
  
  def both_quantity_and_inventory_amount_must_be_0_at_the_same_time
    return if not item.present? 
    return if not unit_price.present? 
    return if not quantity.present?
    
    initial_quantity = item.ready
    additional_quantity = quantity
    final_quantity = additional_quantity + initial_quantity
    
    additional_amount = unit_price * quantity 
    initial_amount = item.avg_cost * item.ready
    final_amount = ( additional_amount + initial_amount ).round(2)
    
    if  (
          (
            final_quantity == 0 and 
            final_amount != BigDecimal("0")
          ) or 
          (
            final_quantity != 0 and 
            final_amount == BigDecimal("0")
          )
      ) 
      
      self.errors.add(:generic_errors, "Quantity dan nilai total inventory harus sama-sama 0")
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
    
    if self.is_confirmed?
      self.errors.add(:generic_errors, "Tidak bisa update")
      return self 
    end
     
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
  
  
  def post_confirm_update_stock_mutation
    item = self.item 
    stock_mutation_case = STOCK_MUTATION_CASE[:addition] 
    stock_mutation_case = STOCK_MUTATION_CASE[:deduction]  if self.quantity < 0 
    
    stock_mutation = StockMutation.create_object( 
      item, # the item 
      self, # source_document_detail 
      stock_mutation_case, # stock_mutation_case,
      STOCK_MUTATION_ITEM_CASE[:ready]   # stock_mutation_item_case
     
     ) 
    item.update_stock_mutation( stock_mutation )
  end
  
  def post_confirm_update_price_mutation
    item = self.item 
    amount = (unit_price  * quantity ).round(2)
    
    price_mutation = PriceMutation.create_object(
      item,
      self,
      amount 
    )
    
    item.update_average_cost(price_mutation , quantity  )
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
    final_quantity = item.ready + -1*self.quantity
    if final_quantity < 0 
      self.errors.add(:generic_errors, "Kuantitas akhir tidak boleh negative")
      return false 
    end
     
    final_inventory = item.ready*item.avg_cost  + -1 * self.quantity * self.unit_price 
    if final_inventory < BigDecimal("0")
      puts "avg_cost : #{item.avg_cost }"
      puts "Inside the amount limit"
      self.errors.add(:generic_errors, "Average price tidak boleh negative")
      return false 
    end
    
    if not (
        final_quantity == 0 and
        final_inventory == BigDecimal("0")
      )
      self.errors.add(:generic_errors, "Kuantitas dan jumlah inventory harus sama-sama 0")
      return false 
    end
    
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
    
    price_mutation = PriceMutation.get_by_source_document_detail( self ) 
    revert_price_mutation  = price_mutation.delete_object 
    item.update_average_cost( price_mutation, -1*self.quantity )
  end
  
   
end
