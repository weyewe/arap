class CreateStockAdjustmentDetails < ActiveRecord::Migration
  def change
    create_table :stock_adjustment_details do |t|
      t.integer :stock_adjustment_id 
      
      t.integer :item_id
      t.integer :quantity 
      t.decimal :unit_price, :default => 0, :precision => 9, :scale => 2  
      t.boolean :is_deleted, :default => false 
      
      t.timestamps
    end
  end
end
