class CreatePaymentVoucherDetails < ActiveRecord::Migration
  def change
    create_table :payment_voucher_details do |t|

      t.timestamps
    end
  end
end
