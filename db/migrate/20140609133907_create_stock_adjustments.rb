class CreateStockAdjustments < ActiveRecord::Migration
  def change
    create_table :stock_adjustments do |t|
      t.datetime :adjustment_date 
      t.text :description 
      
      
      t.boolean :is_deleted, :default => false
      t.boolean :is_confirmed, :default => false 
      t.datetime :confirmed_at
      
    
      t.timestamps
    end
  end
end
