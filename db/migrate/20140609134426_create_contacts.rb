class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.text :description 
      
      t.boolean :is_customer, :default => false 
      t.boolean :is_supplier, :default => false  

      t.text :address
      t.text :shipping_address

      t.timestamps
    end
  end
end
