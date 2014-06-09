class CreateStockMutations < ActiveRecord::Migration
  def change
    create_table :stock_mutations do |t|

      t.timestamps
    end
  end
end
