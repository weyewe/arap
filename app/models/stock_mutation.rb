class StockMutation < ActiveRecord::Base
  belongs_to :item 
  
=begin
Utility
=end
  def self.get_by_source_document_detail( source_document_detail )
    self.where(
      :source_document_detail => source_document_detail.class.to_s,
      :source_document_detail_id => source_document_detail.id 
    ).first
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
