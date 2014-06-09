class CreateDeliveryOrders < ActiveRecord::Migration
  def change
    create_table :delivery_orders do |t|
      

      t.timestamps
    end
  end
end
