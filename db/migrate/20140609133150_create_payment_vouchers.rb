class CreatePaymentVouchers < ActiveRecord::Migration
  def change
    create_table :payment_vouchers do |t|

      t.timestamps
    end
  end
end
