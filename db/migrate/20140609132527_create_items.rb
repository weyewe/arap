class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :sku 
      t.text :description 
      
      t.integer :pending_receival, :default => 0 
      t.integer :ready, :default => 0 
      t.integer :pending_delivery , :default => 0 
      t.decimal :standard_price, :default => 0, :precision => 9, :scale => 2  
      
      t.decimal :avg_price , :default => 0, :precision => 9, :scale => 2 
      
      t.boolean :is_deleted, :default => false 
      
      t.timestamps
    end
  end
end
