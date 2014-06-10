class CreateStockMutations < ActiveRecord::Migration
  def change
    create_table :stock_mutations do |t|
      t.integer :item_id 
      t.integer :quantity 
      t.integer :case  # STOCK_MUTATION_CASE
      t.integer :source_document_detail_id 
      t.string :source_document_detail 
      
      t.integer :item_case  # STOCK_MUTATION_ITEM_CASE 
      
      t.datetime :mutation_date 
      
      t.timestamps
    end
  end
end
