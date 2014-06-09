class CreateReceiptVouchers < ActiveRecord::Migration
  def change
    create_table :receipt_vouchers do |t|

      t.timestamps
    end
  end
end
