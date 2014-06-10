class CreatePriceMutations < ActiveRecord::Migration
  def change
    create_table :price_mutations do |t|
      t.decimal :amount , :default => 0, :precision => 9, :scale => 2 
      t.datetime :mutation_date 
      t.integer :item_id
      t.string :source_document_detail
      t.integer :source_document_detail_id 
      t.integer :case
      t.boolean :is_deleted, :default => false 
      t.timestamps
    end
  end
end
