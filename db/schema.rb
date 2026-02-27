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

ActiveRecord::Schema[8.1].define(version: 2026_02_27_150003) do
  create_table "access_control_logs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "granted", null: false
    t.string "permission"
    t.string "reason"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["resource_type", "resource_id"], name: "index_access_control_logs_on_resource_type_and_resource_id"
    t.index ["user_id", "created_at"], name: "index_access_control_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_access_control_logs_on_user_id"
  end

  create_table "account_memberships", force: :cascade do |t|
    t.integer "account_id", null: false
    t.datetime "created_at", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["account_id", "user_id"], name: "index_account_memberships_on_account_id_and_user_id", unique: true
    t.index ["account_id"], name: "index_account_memberships_on_account_id"
    t.index ["user_id"], name: "index_account_memberships_on_user_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.boolean "auto_logout_enabled", default: false
    t.datetime "created_at", null: false
    t.boolean "encryption_enabled", default: false
    t.boolean "hipaa_enabled", default: false
    t.string "name", null: false
    t.boolean "pci_compliant", default: false
    t.boolean "requires_mfa_for_transactions", default: false
    t.boolean "requires_transaction_approval", default: false
    t.boolean "soc2_compliant", default: false
    t.decimal "transaction_limit_daily", precision: 15, scale: 2
    t.datetime "updated_at", null: false
  end

  create_table "audit_logs", force: :cascade do |t|
    t.integer "account_id"
    t.string "action", null: false
    t.text "changes"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "occurred_at", null: false
    t.string "phi_accessed"
    t.integer "resource_id"
    t.string "resource_type"
    t.string "session_id"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id"
    t.index ["account_id", "occurred_at"], name: "index_audit_logs_on_account_id_and_occurred_at"
    t.index ["account_id"], name: "index_audit_logs_on_account_id"
    t.index ["resource_type", "resource_id"], name: "index_audit_logs_on_resource_type_and_resource_id"
    t.index ["session_id"], name: "index_audit_logs_on_session_id"
    t.index ["user_id", "occurred_at"], name: "index_audit_logs_on_user_id_and_occurred_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "data_access_logs", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.string "data_type", null: false
    t.string "ip_address"
    t.text "justification"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["account_id", "created_at"], name: "index_data_access_logs_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_data_access_logs_on_account_id"
    t.index ["user_id", "created_at"], name: "index_data_access_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_data_access_logs_on_user_id"
  end

  create_table "lti_grades", force: :cascade do |t|
    t.string "activity_progress"
    t.text "comment"
    t.datetime "created_at", null: false
    t.string "grading_progress"
    t.integer "lti_resource_link_id", null: false
    t.decimal "score", precision: 5, scale: 2
    t.decimal "score_maximum", precision: 5, scale: 2
    t.datetime "submitted_at"
    t.boolean "synced_to_lms", default: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["lti_resource_link_id"], name: "index_lti_grades_on_lti_resource_link_id"
    t.index ["user_id", "lti_resource_link_id"], name: "index_lti_grades_on_user_id_and_lti_resource_link_id"
    t.index ["user_id"], name: "index_lti_grades_on_user_id"
  end

  create_table "lti_launches", force: :cascade do |t|
    t.string "context_id"
    t.datetime "created_at", null: false
    t.text "custom_params"
    t.datetime "launched_at"
    t.integer "lti_platform_id", null: false
    t.integer "lti_resource_link_id"
    t.string "lti_user_id"
    t.string "role"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["lti_platform_id"], name: "index_lti_launches_on_lti_platform_id"
    t.index ["lti_resource_link_id"], name: "index_lti_launches_on_lti_resource_link_id"
    t.index ["lti_user_id"], name: "index_lti_launches_on_lti_user_id"
    t.index ["user_id", "created_at"], name: "index_lti_launches_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_lti_launches_on_user_id"
  end

  create_table "lti_platforms", force: :cascade do |t|
    t.integer "account_id", null: false
    t.boolean "active", default: true
    t.string "auth_endpoint", null: false
    t.string "client_id", null: false
    t.datetime "created_at", null: false
    t.string "deployment_id"
    t.string "issuer", null: false
    t.string "jwks_endpoint", null: false
    t.string "platform_name"
    t.text "public_key"
    t.string "token_endpoint", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_lti_platforms_on_account_id"
    t.index ["issuer", "client_id"], name: "index_lti_platforms_on_issuer_and_client_id", unique: true
  end

  create_table "lti_registrations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "launch_url", null: false
    t.integer "lti_platform_id", null: false
    t.text "private_key"
    t.text "public_jwk"
    t.string "registration_id", null: false
    t.string "tool_url", null: false
    t.datetime "updated_at", null: false
    t.index ["lti_platform_id"], name: "index_lti_registrations_on_lti_platform_id"
    t.index ["registration_id"], name: "index_lti_registrations_on_registration_id", unique: true
  end

  create_table "lti_resource_links", force: :cascade do |t|
    t.string "context_id"
    t.string "context_title"
    t.datetime "created_at", null: false
    t.text "custom_parameters"
    t.integer "lti_platform_id", null: false
    t.string "resource_link_id", null: false
    t.string "resource_title"
    t.datetime "updated_at", null: false
    t.index ["lti_platform_id", "resource_link_id"], name: "index_lti_links_on_platform_and_resource", unique: true
    t.index ["lti_platform_id"], name: "index_lti_resource_links_on_lti_platform_id"
  end

  create_table "oauth_accounts", force: :cascade do |t|
    t.text "access_token"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["provider", "uid"], name: "index_oauth_accounts_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_oauth_accounts_on_user_id"
  end

  create_table "saml_providers", force: :cascade do |t|
    t.integer "account_id", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.string "entity_id", null: false
    t.text "idp_cert"
    t.text "idp_metadata_url"
    t.string "name", null: false
    t.string "name_identifier_format"
    t.text "sso_target_url"
    t.datetime "updated_at", null: false
    t.index ["account_id", "entity_id"], name: "index_saml_providers_on_account_id_and_entity_id", unique: true
    t.index ["account_id"], name: "index_saml_providers_on_account_id"
  end

  create_table "security_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "details"
    t.string "event_type", null: false
    t.string "ip_address"
    t.boolean "resolved", default: false
    t.datetime "resolved_at"
    t.integer "resolved_by_id"
    t.string "severity"
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["event_type", "created_at"], name: "index_security_events_on_event_type_and_created_at"
    t.index ["resolved"], name: "index_security_events_on_resolved"
    t.index ["resolved_by_id"], name: "index_security_events_on_resolved_by_id"
    t.index ["severity"], name: "index_security_events_on_severity"
    t.index ["user_id"], name: "index_security_events_on_user_id"
  end

  create_table "transaction_logs", force: :cascade do |t|
    t.integer "account_id", null: false
    t.decimal "amount", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.string "currency", default: "USD"
    t.string "device_fingerprint"
    t.string "ip_address"
    t.text "metadata"
    t.text "risk_score"
    t.string "status"
    t.boolean "suspicious", default: false
    t.string "transaction_id"
    t.string "transaction_type", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["account_id", "created_at"], name: "index_transaction_logs_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_transaction_logs_on_account_id"
    t.index ["suspicious"], name: "index_transaction_logs_on_suspicious"
    t.index ["transaction_id"], name: "index_transaction_logs_on_transaction_id", unique: true
    t.index ["user_id", "created_at"], name: "index_transaction_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_transaction_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "aml_check_passed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "email_verification_token"
    t.datetime "email_verified_at"
    t.boolean "force_password_change", default: false
    t.datetime "hipaa_agreement_accepted_at"
    t.datetime "hipaa_trained_at"
    t.string "kyc_document_id"
    t.datetime "kyc_verified_at"
    t.datetime "last_password_change_at"
    t.boolean "lti_enabled", default: false
    t.text "lti_roles"
    t.string "lti_user_id"
    t.text "otp_backup_codes"
    t.boolean "otp_required_for_login", default: false
    t.string "otp_secret"
    t.string "password_digest", null: false
    t.string "remember_token"
    t.string "risk_level", default: "low"
    t.string "saml_uid"
    t.integer "session_timeout_minutes", default: 15
    t.decimal "transaction_limit", precision: 15, scale: 2
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_verification_token"], name: "index_users_on_email_verification_token"
    t.index ["remember_token"], name: "index_users_on_remember_token"
    t.index ["saml_uid"], name: "index_users_on_saml_uid", unique: true
  end

  add_foreign_key "access_control_logs", "users"
  add_foreign_key "account_memberships", "accounts"
  add_foreign_key "account_memberships", "users"
  add_foreign_key "audit_logs", "accounts"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "data_access_logs", "accounts"
  add_foreign_key "data_access_logs", "users"
  add_foreign_key "lti_grades", "lti_resource_links"
  add_foreign_key "lti_grades", "users"
  add_foreign_key "lti_launches", "lti_platforms"
  add_foreign_key "lti_launches", "lti_resource_links"
  add_foreign_key "lti_launches", "users"
  add_foreign_key "lti_platforms", "accounts"
  add_foreign_key "lti_registrations", "lti_platforms"
  add_foreign_key "lti_resource_links", "lti_platforms"
  add_foreign_key "oauth_accounts", "users"
  add_foreign_key "saml_providers", "accounts"
  add_foreign_key "security_events", "users"
  add_foreign_key "security_events", "users", column: "resolved_by_id"
  add_foreign_key "transaction_logs", "accounts"
  add_foreign_key "transaction_logs", "users"
end
