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

ActiveRecord::Schema[8.1].define(version: 2026_09_02_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "merchants", force: :cascade do |t|
    t.string "disbursement_frequency"
    t.string "email"
    t.uuid "external_id"
    t.date "live_on"
    t.integer "minimum_monthly_fee_cents"
    t.string "reference"
    t.index ["external_id"], name: "index_merchants_on_external_id", unique: true
    t.index ["reference"], name: "index_merchants_on_reference", unique: true
  end
end
