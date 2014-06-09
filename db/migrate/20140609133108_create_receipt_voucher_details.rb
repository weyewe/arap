class CreateReceiptVoucherDetails < ActiveRecord::Migration
  def change
    create_table :receipt_voucher_details do |t|

      t.timestamps
    end
  end
end
