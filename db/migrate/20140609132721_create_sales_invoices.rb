class CreateSalesInvoices < ActiveRecord::Migration
  def change
    create_table :sales_invoices do |t|

      t.timestamps
    end
  end
end
