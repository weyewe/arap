class CreatePurchaseInvoices < ActiveRecord::Migration
  def change
    create_table :purchase_invoices do |t|
      t.integer :purchase_receival_id 
      t.datetime :invoice_date 
      
      t.integer :contact_id 
      
      t.text :description 
      
      t.boolean :is_deleted, :default => false 
      t.boolean :is_confirmed, :default => false 
      t.datetime :confirmed_at 
      
      t.decimal :total, :default => 0, :precision => 9, :scale => 2  

      t.timestamps
    end
  end
end
