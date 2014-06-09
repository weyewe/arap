class CreatePurchaseOrders < ActiveRecord::Migration
  def change
    create_table :purchase_orders do |t|
      t.integer :contact_id
      t.datetime :purchase_date 
      t.text :description 
      t.decimal :total, :default => 0, :precision => 12, :scale => 2  
      
      t.boolean :is_confirmed, :default => false 
      t.datetime :confirmed_at 
      
      t.boolean :is_deleted, :default => false 
      t.timestamps
    end
  end
end
