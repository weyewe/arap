class CreatePurchaseInvoiceDetails < ActiveRecord::Migration
  def change
    create_table :purchase_invoice_details do |t|
      t.integer :purchase_invoice_id 
      t.integer :quantity 
      
      
      t.timestamps
    end
  end
end
