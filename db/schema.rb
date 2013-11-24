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

ActiveRecord::Schema.define(version: 20131123153353) do

  create_table "access_tokens", force: true do |t|
    t.string   "token_digest",                    null: false
    t.integer  "email_address_id",                null: false
    t.boolean  "active",           default: true, null: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_tokens", ["email_address_id"], name: "index_access_tokens_on_email_address_id"
  add_index "access_tokens", ["token_digest"], name: "index_access_tokens_on_token_digest", unique: true

  create_table "domains", force: true do |t|
    t.string  "name"
    t.integer "organization_id"
  end

  add_index "domains", ["name"], name: "index_domains_on_name", unique: true

  create_table "email_addresses", force: true do |t|
    t.integer  "user_id",                    null: false
    t.string   "value",                      null: false
    t.boolean  "verified",   default: false
    t.boolean  "primary",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_addresses", ["user_id"], name: "index_email_addresses_on_user_id"
  add_index "email_addresses", ["value"], name: "index_email_addresses_on_value", unique: true

  create_table "email_verification_tokens", force: true do |t|
    t.string   "token_digest",     null: false
    t.integer  "email_address_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_verification_tokens", ["email_address_id"], name: "index_email_verification_tokens_on_email_address_id"
  add_index "email_verification_tokens", ["token_digest"], name: "index_email_verification_tokens_on_token_digest", unique: true

  create_table "group_memberships", force: true do |t|
    t.integer  "group_id"
    t.integer  "user_id"
    t.boolean  "default",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_memberships", ["group_id", "user_id"], name: "index_group_memberships_on_group_id_and_user_id", unique: true
  add_index "group_memberships", ["user_id", "group_id"], name: "index_group_memberships_on_user_id_and_group_id", unique: true

  create_table "groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["name"], name: "index_groups_on_name", unique: true

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.string   "external_id"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true

  create_table "password_reset_tokens", force: true do |t|
    t.string   "token_digest",     null: false
    t.integer  "email_address_id", null: false
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "password_reset_tokens", ["email_address_id"], name: "index_password_reset_tokens_on_email_address_id"
  add_index "password_reset_tokens", ["token_digest"], name: "index_password_reset_tokens_on_token_digest", unique: true

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "role",                default: "end_user"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sign_in_count",       default: 0
    t.datetime "previous_sign_in_at"
    t.datetime "latest_sign_in_at"
    t.boolean  "active",              default: true
    t.integer  "organization_id"
    t.string   "notes"
  end

  add_index "users", ["organization_id"], name: "index_users_on_organization_id"

end
