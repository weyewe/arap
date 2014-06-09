class PurchaseReceival < ActiveRecord::Base
  belongs_to :purchase_order
  has_many :purchase_invoices
end
