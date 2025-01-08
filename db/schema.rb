# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_01_06_113152) do
  create_table "commissions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.float "percentage", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_commissions_on_user_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "telephone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.integer "salesperson_id"
    t.float "value"
    t.string "gateway_used"
    t.integer "customer_id", null: false
    t.float "commission_percentage_on_sale"
    t.float "commission_value"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_payments_on_customer_id"
    t.index ["salesperson_id"], name: "index_payments_on_salesperson_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "role", default: "salesperson"
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "shopowner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["shopowner_id"], name: "index_users_on_shopowner_id"
  end

  add_foreign_key "commissions", "users"
  add_foreign_key "payments", "customers"
  add_foreign_key "payments", "users", column: "salesperson_id"
  add_foreign_key "users", "users", column: "shopowner_id"
end
