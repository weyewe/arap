class StockMutation < ActiveRecord::Base
  belongs_to :item 
  
=begin
Utility
=end
  def self.get_by_source_document_detail( source_document_detail , item_mutation_case)
    self.where(
      :source_document_detail => source_document_detail.class.to_s,
      :source_document_detail_id => source_document_detail.id ,
      :item_case => item_mutation_case
    ).first
  end
  
  
  def self.create_object( item, source_document_detail, stock_mutation_case, stock_mutation_item_case )
    new_object = self.new 
    new_object.source_document_detail = source_document_detail.class.to_s
    new_object.source_document_detail_id = source_document_detail.id 
    new_object.quantity = source_document_detail.quantity.abs 
    new_object.case  = stock_mutation_case
    new_object.item_case = stock_mutation_item_case
    new_object.item_id = item.id
    
    new_object.mutation_date = source_document_detail.confirmed_at
    new_object.save 
    
    return new_object 
  end
  
=begin
  PurchaseOrder
=end

=begin
  PurchaseReceival
=end

=begin
  StockAdjustment 
=end

=begin
  SalesOrder
=end

=begin
  SalesDelivery
=end
end
