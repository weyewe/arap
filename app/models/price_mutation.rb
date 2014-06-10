class PriceMutation < ActiveRecord::Base
  belongs_to :item
  
  def self.get_by_source_document_detail( source_document_detail )
    self.where(
      :source_document_detail => source_document_detail.class.to_s,
      :source_document_detail_id => source_document_detail.id ,
      :case => PRICE_MUTATION_CASE[:new]
    ).order("id DESC").first
  end
  
  
  def self.create_object( item, source_document_detail, amount   )
    new_object = self.new 
    new_object.source_document_detail = source_document_detail.class.to_s 
    new_object.source_document_detail_id = source_document_detail.id 
    
    new_object.item_id = item.id
     
    new_object.amount = amount
    
    new_object.mutation_date = source_document_detail.confirmed_at
    
    new_object.case = PRICE_MUTATION_CASE[:new]
    
    new_object.save 
    
    
    return new_object 
  end
  
  def delete_object
    new_object = self.class.new 
    new_object.source_document_detail = self.source_document_detail 
    new_object.source_document_detail_id = self.source_document_detail_id 
    
    new_object.item_id = item.id
     
    new_object.amount = amount * -1 
    
    new_object.mutation_date = DateTime.now 
    
    
    new_object.case = PRICE_MUTATION_CASE[:revert]
    if new_object.save 
      self.is_deleted = true 
      self.save 
    end
    
    return new_object 
    
    
    
  end
  
end
