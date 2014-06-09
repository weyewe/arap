class CreatePayables < ActiveRecord::Migration
  def change
    create_table :payables do |t|

      t.timestamps
    end
  end
end
