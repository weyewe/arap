class CreatePurchaseReceivals < ActiveRecord::Migration
  def change
    create_table :purchase_receivals do |t|
      t.integer :purchase_order_id 
      t.text :description 
      t.datetime :receival_date  
      
      t.boolean :is_confirmed , :default => false
      t.datetime :confirmed_at 
      
      t.boolean :is_deleted , :default => false
      
      
      t.timestamps
    end
  end
end
