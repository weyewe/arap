class CreateReceivables < ActiveRecord::Migration
  def change
    create_table :receivables do |t|

      t.timestamps
    end
  end
end
