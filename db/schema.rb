# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140610034523) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awesomes", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cash_banks", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.decimal  "amount",      precision: 14, scale: 2, default: 0.0
    t.boolean  "is_bank",                              default: false
    t.boolean  "is_deleted",                           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "is_customer",      default: false
    t.boolean  "is_supplier",      default: false
    t.text     "address"
    t.text     "shipping_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_orders", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: true do |t|
    t.string   "sku"
    t.text     "description"
    t.integer  "pending_receival",                         default: 0
    t.integer  "ready",                                    default: 0
    t.integer  "pending_delivery",                         default: 0
    t.decimal  "standard_price",   precision: 9, scale: 2, default: 0.0
    t.decimal  "avg_cost",         precision: 9, scale: 2, default: 0.0
    t.boolean  "is_deleted",                               default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payables", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_voucher_details", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_vouchers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "price_mutations", force: true do |t|
    t.decimal  "amount",                    precision: 9, scale: 2, default: 0.0
    t.datetime "mutation_date"
    t.integer  "item_id"
    t.string   "source_document_detail"
    t.integer  "source_document_detail_id"
    t.integer  "case"
    t.boolean  "is_deleted",                                        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_invoice_details", force: true do |t|
    t.integer  "purchase_invoice_id"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_invoices", force: true do |t|
    t.integer  "purchase_receival_id"
    t.datetime "invoice_date"
    t.integer  "contact_id"
    t.text     "description"
    t.boolean  "is_deleted",                                   default: false
    t.boolean  "is_confirmed",                                 default: false
    t.datetime "confirmed_at"
    t.decimal  "total",                precision: 9, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_order_details", force: true do |t|
    t.integer  "purchase_order_id"
    t.integer  "item_id"
    t.decimal  "discount",          precision: 5, scale: 2, default: 0.0
    t.decimal  "unit_price",        precision: 9, scale: 2, default: 0.0
    t.integer  "quantity",                                  default: 0
    t.integer  "pending_receival",                          default: 0
    t.boolean  "is_confirmed",                              default: false
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_orders", force: true do |t|
    t.integer  "contact_id"
    t.datetime "purchase_date"
    t.text     "description"
    t.decimal  "total",         precision: 12, scale: 2, default: 0.0
    t.boolean  "is_confirmed",                           default: false
    t.datetime "confirmed_at"
    t.boolean  "is_deleted",                             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_receival_details", force: true do |t|
    t.integer  "purchase_receival_id"
    t.integer  "purchase_order_detail_id"
    t.integer  "quantity",                 default: 0
    t.integer  "invoiced_quantity",        default: 0
    t.boolean  "is_confirmed",             default: false
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_receivals", force: true do |t|
    t.integer  "purchase_order_id"
    t.text     "description"
    t.datetime "receival_date"
    t.boolean  "is_confirmed",      default: false
    t.datetime "confirmed_at"
    t.boolean  "is_deleted",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receipt_voucher_details", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receipt_vouchers", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receivables", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_invoices", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_orders", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_adjustment_details", force: true do |t|
    t.integer  "stock_adjustment_id"
    t.integer  "item_id"
    t.integer  "quantity"
    t.decimal  "unit_price",          precision: 9, scale: 2, default: 0.0
    t.boolean  "is_confirmed",                                default: false
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_adjustments", force: true do |t|
    t.datetime "adjustment_date"
    t.text     "description"
    t.boolean  "is_deleted",      default: false
    t.boolean  "is_confirmed",    default: false
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_mutations", force: true do |t|
    t.integer  "item_id"
    t.integer  "quantity"
    t.integer  "case"
    t.integer  "source_document_detail_id"
    t.string   "source_document_detail"
    t.integer  "item_case"
    t.datetime "mutation_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
