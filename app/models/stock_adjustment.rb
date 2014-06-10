class StockAdjustment < ActiveRecord::Base
  has_many :stock_adjustment_details 
  validates_presence_of :adjustment_date 
  
  def self.create_object( params ) 
    new_object = self.new
    new_object.adjustment_date = params[:adjustment_date]
    new_object.description = params[:description]
    new_object.save 
    
    return new_object 
  end
  
  def update_object(params )
    self.adjustment_date = params[:adjustment_date]
    self.description = params[:description]
    self.save 
    
    return self
  end
  
  def all_stock_adjustment_details_deletable?
    self.stock_adjustment_details.each do |x|
      return x.deletable? if not x.deletable?
    end
    
    return true
  end
  
  
  def delete_object
    if self.is_confirmed?
      self.errors.add(:generic_errors, "sudah di konfirmasi")
      return self
    else
      self.stock_adjustment_details.each {|x| x.delete_object}
      self.destroy 
    end
  end
  
  def all_stock_adjustment_details_confirmable?
    self.stock_adjustment_details.each do |x|
      return x.confirmable? if not x.confirmable?
    end
    
    return true 
  end
  
  
  
  def confirm_object( params )
    return if self.is_deleted? 
    
    if self.stock_adjustment_details.count == 0 
      self.errors.add(:generic_errors, "Belum ada detail")
      return self
    end
    
    if self.is_confirmed? 
      self.errors.add(:generic_errors, "Sudah konfirmasi")
      return self 
    end
    
    if self.all_stock_adjustment_details_confirmable?
      if not params[:confirmed_at].present?
        self.errors.add(:confirmed_at, "Harus ada tanggal konfirmasi")
        return self
      end
      
      self.is_confirmed = true 
      self.confirmed_at = params[:confirmed_at]
      self.save 
      self.stock_adjustment_details.each {|x| x.confirm_object( params[:confirmed_at]) }
    else
      self.errors.add(:generic_errors, "Ada stock adjustment detail yang tidak bisa di konfirmasi")
      return self 
    end
  end
  
  def all_stock_adjustment_details_unconfirmable?
    self.stock_adjustment_details.each do |x|
      return  x.unconfirmable? if not x.unconfirmable?
    end
    
    return true 
  end
  
  
  def unconfirm_object 
    return if self.is_deleted?
    
    if not self.is_confirmed? 
      self.errors.add(:generic_errors, "Belum konfirmasi")
      return self 
    end
    
    if self.all_stock_adjustment_details_unconfirmable?
      
      self.is_confirmed = false 
      self.confirmed_at = nil 
      self.save 
      self.stock_adjustment_details.each {|x| x.unconfirm_object }
    else
      self.errors.add(:generic_errors, "Ada stock adjustment detail yang tidak bisa di batalkan ")
      return self 
    end
  end
  
  def self.active_objects
    self.where(:is_deleted => false )
  end
end
