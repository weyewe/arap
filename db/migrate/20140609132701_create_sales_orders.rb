class CreateSalesOrders < ActiveRecord::Migration
  def change
    create_table :sales_orders do |t|

      t.timestamps
    end
  end
end
