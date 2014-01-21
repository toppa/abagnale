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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140102221250) do

  create_table "transactions", :force => true do |t|
    t.string   "fullccnum",   :null => false
    t.string   "name"
    t.integer  "amount"
    t.string   "order"
    t.string   "auth_result"
    t.datetime "settled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "original_id"
    t.datetime "refunded_at"
  end

end
