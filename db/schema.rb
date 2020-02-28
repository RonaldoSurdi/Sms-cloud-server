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

ActiveRecord::Schema.define(version: 20170412184831) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "administrators", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.boolean  "main_administrator",     default: false, null: false
  end

  add_index "administrators", ["email"], name: "index_administrators_on_email", unique: true, using: :btree
  add_index "administrators", ["reset_password_token"], name: "index_administrators_on_reset_password_token", unique: true, using: :btree

  create_table "administrators_roles", id: false, force: true do |t|
    t.integer "administrator_id", null: false
    t.integer "role_id",          null: false
  end

  create_table "configurations", force: true do |t|
    t.integer "customer_id"
    t.boolean "send_birthdays", default: false, null: false
    t.string  "text_birthdays"
  end

  add_index "configurations", ["customer_id"], name: "index_configurations_on_customer_id", using: :btree

  create_table "contact_groups", force: true do |t|
    t.string   "descricao"
    t.string   "observacao"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contact_groups", ["customer_id"], name: "index_contact_groups_on_customer_id", using: :btree

  create_table "contact_groups_contacts", force: true do |t|
    t.integer "contact_id"
    t.integer "contact_group_id"
  end

  add_index "contact_groups_contacts", ["contact_group_id"], name: "index_contact_groups_contacts_on_contact_group_id", using: :btree
  add_index "contact_groups_contacts", ["contact_id"], name: "index_contact_groups_contacts_on_contact_id", using: :btree

  create_table "contacts", force: true do |t|
    t.string   "nome"
    t.string   "celular"
    t.string   "email"
    t.string   "empresa"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "nascimento"
    t.integer  "sexo",        default: 0, null: false
  end

  add_index "contacts", ["customer_id"], name: "index_contacts_on_customer_id", using: :btree

  create_table "customers", force: true do |t|
    t.string   "nome"
    t.string   "telefone"
    t.string   "celular"
    t.integer  "tipo_pessoa"
    t.integer  "endereco_id"
    t.integer  "representative_id"
    t.string   "cpf_cnpj"
    t.string   "razao_social"
    t.integer  "status",                 default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "customers", ["email"], name: "index_customers_on_email", unique: true, using: :btree
  add_index "customers", ["endereco_id"], name: "index_customers_on_endereco_id", using: :btree
  add_index "customers", ["representative_id"], name: "index_customers_on_representative_id", using: :btree
  add_index "customers", ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true, using: :btree

  create_table "enderecos", force: true do |t|
    t.string   "logradouro"
    t.string   "bairro"
    t.string   "cidade"
    t.string   "uf"
    t.string   "cep"
    t.string   "complemento", default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "license_movements", force: true do |t|
    t.integer  "license_id"
    t.integer  "representative_id"
    t.datetime "confirmado_pagamento_em"
    t.string   "licenca_descricao"
    t.integer  "licenca_tipo"
    t.decimal  "licenca_valor_unitario",  precision: 12, scale: 2, default: 0.0, null: false
    t.decimal  "licenca_valor_sugerido",  precision: 12, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.date     "data_venda_cliente"
    t.integer  "plano_quantidade_sms"
    t.string   "plano_descricao"
    t.decimal  "plano_valor_total",       precision: 12, scale: 2
    t.date     "validade_inicio"
    t.date     "validade_fim"
    t.decimal  "valor_venda_cliente",     precision: 12, scale: 2
  end

  add_index "license_movements", ["customer_id"], name: "index_license_movements_on_customer_id", using: :btree
  add_index "license_movements", ["license_id"], name: "index_license_movements_on_license_id", using: :btree
  add_index "license_movements", ["representative_id"], name: "index_license_movements_on_representative_id", using: :btree

  create_table "licenses", force: true do |t|
    t.decimal  "valor_unitario", precision: 12, scale: 2
    t.decimal  "valor_sugerido", precision: 12, scale: 2
    t.integer  "tipo",                                    default: 0, null: false
    t.integer  "plan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "descricao"
  end

  add_index "licenses", ["plan_id"], name: "index_licenses_on_plan_id", using: :btree

  create_table "message_groups", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: true do |t|
    t.string   "message"
    t.string   "to"
    t.string   "from"
    t.integer  "status"
    t.datetime "schedule"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attempts"
    t.integer  "message_type"
    t.integer  "customer_id"
    t.datetime "date_time_sent"
    t.integer  "message_group_id"
    t.string   "contato_nome"
    t.string   "uuid"
  end

  add_index "messages", ["customer_id"], name: "index_messages_on_customer_id", using: :btree
  add_index "messages", ["message_group_id"], name: "index_messages_on_message_group_id", using: :btree
  add_index "messages", ["message_type"], name: "index_messages_on_message_type", using: :btree

  create_table "our_customers", force: true do |t|
    t.string   "descricao"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "permissions", force: true do |t|
    t.string   "subject"
    t.string   "actions"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "permissions", ["role_id"], name: "index_permissions_on_role_id", using: :btree

  create_table "plan_movements", force: true do |t|
    t.integer  "license_movement_id"
    t.integer  "quantidade_sms"
    t.decimal  "plano_valor_total",       precision: 12, scale: 2
    t.date     "validade_inicio"
    t.date     "validade_fim"
    t.integer  "customer_id"
    t.string   "plano_descricao"
    t.integer  "plano_tipo"
    t.date     "confirmado_pagamento_em"
    t.datetime "created_at"
  end

  add_index "plan_movements", ["license_movement_id"], name: "index_plan_movements_on_license_movement_id", using: :btree

  create_table "plans", force: true do |t|
    t.integer  "tipo"
    t.integer  "quantidade_sms",                          default: 0, null: false
    t.decimal  "valor_total",    precision: 12, scale: 2
    t.string   "descricao"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "representatives", force: true do |t|
    t.string   "razao_social"
    t.string   "nome_fantasia"
    t.string   "cnpj"
    t.string   "inscricao_estadual"
    t.string   "responsavel"
    t.string   "telefone"
    t.string   "celular"
    t.boolean  "cadastro_aprovado",       default: false, null: false
    t.integer  "endereco_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                   default: "",    null: false
    t.string   "encrypted_password",      default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "representante_principal", default: false, null: false
  end

  add_index "representatives", ["email"], name: "index_representatives_on_email", unique: true, using: :btree
  add_index "representatives", ["endereco_id"], name: "index_representatives_on_endereco_id", using: :btree
  add_index "representatives", ["reset_password_token"], name: "index_representatives_on_reset_password_token", unique: true, using: :btree

  create_table "roles", force: true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "full_control", default: false, null: false
  end

  add_foreign_key "configurations", "customers", name: "configurations_customer_id_fk"

  add_foreign_key "contact_groups", "customers", name: "contact_groups_customer_id_fk"

  add_foreign_key "contact_groups_contacts", "contact_groups", name: "contact_groups_contacts_contact_group_id_fk"
  add_foreign_key "contact_groups_contacts", "contacts", name: "contact_groups_contacts_contact_id_fk"

  add_foreign_key "contacts", "customers", name: "contacts_customer_id_fk"

  add_foreign_key "license_movements", "customers", name: "license_movements_customer_id_fk"

  add_foreign_key "messages", "customers", name: "messages_customer_id_fk"

  add_foreign_key "plan_movements", "customers", name: "plan_movements_customer_id_fk"

end
