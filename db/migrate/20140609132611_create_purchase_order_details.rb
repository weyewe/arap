class CreatePurchaseOrderDetails < ActiveRecord::Migration
  def change
    create_table :purchase_order_details do |t|
      t.integer :purchase_order_id
      t.integer :item_id 
      # in percent 
      t.decimal :discount, :default => 0, :precision => 5, :scale => 2  
      t.decimal :unit_price, :default => 0, :precision => 9, :scale => 2  
      t.integer :quantity , :default => 0 
       
      t.integer :pending_receival, :default => 0  
      
      t.boolean :is_confirmed, :default => false 
      t.datetime :confirmed_at 
      
      t.timestamps
    end
  end
end
