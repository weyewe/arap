class Contact < ActiveRecord::Base
  has_many :purchase_orders
  has_many :purchase_invoices
  has_many :sales_orders
  has_many :sales_invoices
  has_many :delivery_orders
  has_many :purchase_receivals 
end
