class CreatePurchaseReceivalDetails < ActiveRecord::Migration
  def change
    create_table :purchase_receival_details do |t|
      t.integer :purchase_receival_id 
      t.integer :purchase_order_detail_id  
      t.integer :quantity, :default => 0 
      
      t.integer :invoiced_quantity , :default => 0 
      
      t.boolean :is_confirmed, :default => false
      t.datetime :confirmed_at
      
      t.timestamps
    end
  end
end
