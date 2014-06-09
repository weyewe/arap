class Item < ActiveRecord::Base
  
  validate :uniq_sku_in_active_objects
  validate :standard_price_is_not_less_than_zero
  has_many :stock_mutations
  
  def uniq_sku_in_active_objects
    total_duplicate_count = Item.where(:sku => self.sku, :is_deleted => false).count
    
    if not self.persisted? and total_duplicate_count.count != 0 
      self.errors.add(:sku, "Harus unik")
      return self 
    end
    
    if self.persisted? and total_duplicate_count.count > 1 
      self.errors.add(:sku, "Harus unik")
      return self 
    end
  end
  
  def standard_price_is_not_less_than_zero
    return if not standard_price.present? 
    
    if standard_price <= BigDecimal("0")
      self.errors.add(:standard_price, "Tidak boleh lebih kecil dari 0")
      return self
    end
  end
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.sku = params[:sku]
    new_object.description = params[:description]
    new_object.standard_price = params[:standard_price]
    new_object.save
    
    return new_object 
  end
  
  def update_object
    self.sku = params[:sku]
    self.description = params[:description]
    self.standard_price = params[:standard_price]
    self.save
    
    return self 
  end
  
  def delete_object
    if self.stock_mutations.count != 0 
      self.errors.add(:generic_errors, "Sudah ada stock mutasi")
      return self
    end
    
    self.is_deleted = false
    self.save 
  end
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
  
  
=begin
StockMutation related
=end

  def reverse_stock_mutation(stock_mutation)
    multiplier = 1
    if stock_mutation.case == STOCK_MUTATION_CASE[:addition]
      multiplier = -1 
    end
    
    if stock_mutation.item_case == STOCK_MUTATION_ITEM_CASE[:pending_receival]
      self.pending_receival += multiplier * stock_mutation.quantity 
    elsif  stock_mutation.item_case == STOCK_MUTATION_ITEM_CASE[:ready]
      self.ready += multiplier * stock_mutation.quantity 
    elsif  stock_mutation.item_case == STOCK_MUTATION_ITEM_CASE[:pending_delivery]
      self.pending_delivery += multiplier * stock_mutation.quantity 
    end
    
    self.save 
  end
  
  def update_stock_mutation( stock_mutation ) 
    multiplier = 1
    if stock_mutation.case == STOCK_MUTATION_CASE[:deduction]
      multiplier = -1 
    end
    
    if stock_mutation.item_case == STOCK_MUTATION_ITEM_CASE[:pending_receival]
      self.pending_receival += multiplier * stock_mutation.quantity 
    elsif  stock_mutation.item_case == STOCK_MUTATION_ITEM_CASE[:ready]
      self.ready += multiplier * stock_mutation.quantity 
    elsif  stock_mutation.item_case == STOCK_MUTATION_ITEM_CASE[:pending_delivery]
      self.pending_delivery += multiplier * stock_mutation.quantity 
    end
    
    self.save
  end
end
