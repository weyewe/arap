class CreateAwesomes < ActiveRecord::Migration
  def change
    create_table :awesomes do |t|

      t.timestamps
    end
  end
end
