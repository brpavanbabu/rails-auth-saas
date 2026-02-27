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
  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_token"
    t.string "otp_secret"
    t.boolean "otp_required_for_login", default: false
    t.text "otp_backup_codes"
    t.datetime "email_verified_at"
    t.string "email_verification_token"
    t.string "saml_uid"
    t.datetime "hipaa_trained_at"
    t.datetime "hipaa_agreement_accepted_at"
    t.datetime "last_password_change_at"
    t.boolean "force_password_change", default: false
    t.integer "session_timeout_minutes", default: 15
    t.datetime "kyc_verified_at"
    t.string "kyc_document_id"
    t.datetime "aml_check_passed_at"
    t.string "risk_level", default: "low"
    t.decimal "transaction_limit", precision: 15, scale: 2
    t.boolean "lti_enabled", default: false
    t.string "lti_user_id"
    t.text "lti_roles"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_verification_token"], name: "index_users_on_email_verification_token"
    t.index ["remember_token"], name: "index_users_on_remember_token"
    t.index ["saml_uid"], name: "index_users_on_saml_uid", unique: true
  end

  create_table "oauth_accounts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "email"
    t.string "name"
    t.text "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_oauth_accounts_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_oauth_accounts_on_user_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hipaa_enabled", default: false
    t.boolean "encryption_enabled", default: false
    t.boolean "auto_logout_enabled", default: false
    t.boolean "pci_compliant", default: false
    t.boolean "soc2_compliant", default: false
    t.boolean "requires_mfa_for_transactions", default: false
    t.decimal "transaction_limit_daily", precision: 15, scale: 2
    t.boolean "requires_transaction_approval", default: false
  end

  create_table "account_memberships", force: :cascade do |t|
    t.integer "account_id", null: false
    t.integer "user_id", null: false
    t.string "role", null: false, default: "member"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "user_id"], name: "index_account_memberships_on_account_id_and_user_id", unique: true
    t.index ["account_id"], name: "index_account_memberships_on_account_id"
    t.index ["user_id"], name: "index_account_memberships_on_user_id"
  end

  create_table "saml_providers", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "name", null: false
    t.string "entity_id", null: false
    t.text "idp_metadata_url"
    t.text "idp_cert"
    t.text "sso_target_url"
    t.string "name_identifier_format"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "entity_id"], name: "index_saml_providers_on_account_id_and_entity_id", unique: true
    t.index ["account_id"], name: "index_saml_providers_on_account_id"
  end

  create_table "audit_logs", force: :cascade do |t|
    t.integer "user_id"
    t.integer "account_id"
    t.string "action", null: false
    t.string "resource_type"
    t.integer "resource_id"
    t.text "changes"
    t.string "ip_address"
    t.string "user_agent"
    t.string "session_id"
    t.string "phi_accessed"
    t.datetime "occurred_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "occurred_at"], name: "index_audit_logs_on_account_id_and_occurred_at"
    t.index ["account_id"], name: "index_audit_logs_on_account_id"
    t.index ["resource_type", "resource_id"], name: "index_audit_logs_on_resource_type_and_resource_id"
    t.index ["session_id"], name: "index_audit_logs_on_session_id"
    t.index ["user_id", "occurred_at"], name: "index_audit_logs_on_user_id_and_occurred_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "data_access_logs", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "account_id", null: false
    t.string "data_type", null: false
    t.string "action", null: false
    t.text "justification"
    t.string "ip_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_data_access_logs_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_data_access_logs_on_account_id"
    t.index ["user_id", "created_at"], name: "index_data_access_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_data_access_logs_on_user_id"
  end

  create_table "transaction_logs", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "account_id", null: false
    t.string "transaction_type", null: false
    t.string "transaction_id"
    t.decimal "amount", precision: 15, scale: 2
    t.string "currency", default: "USD"
    t.string "status"
    t.text "metadata"
    t.string "ip_address"
    t.string "device_fingerprint"
    t.boolean "suspicious", default: false
    t.text "risk_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "created_at"], name: "index_transaction_logs_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_transaction_logs_on_account_id"
    t.index ["suspicious"], name: "index_transaction_logs_on_suspicious"
    t.index ["transaction_id"], name: "index_transaction_logs_on_transaction_id", unique: true
    t.index ["user_id", "created_at"], name: "index_transaction_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_transaction_logs_on_user_id"
  end

  create_table "security_events", force: :cascade do |t|
    t.integer "user_id"
    t.string "event_type", null: false
    t.string "severity"
    t.string "ip_address"
    t.text "details"
    t.boolean "resolved", default: false
    t.datetime "resolved_at"
    t.integer "resolved_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type", "created_at"], name: "index_security_events_on_event_type_and_created_at"
    t.index ["resolved"], name: "index_security_events_on_resolved"
    t.index ["resolved_by_id"], name: "index_security_events_on_resolved_by_id"
    t.index ["severity"], name: "index_security_events_on_severity"
    t.index ["user_id"], name: "index_security_events_on_user_id"
  end

  create_table "access_control_logs", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "resource_type"
    t.integer "resource_id"
    t.string "permission"
    t.boolean "granted", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_type", "resource_id"], name: "index_access_control_logs_on_resource_type_and_resource_id"
    t.index ["user_id", "created_at"], name: "index_access_control_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_access_control_logs_on_user_id"
  end

  create_table "lti_platforms", force: :cascade do |t|
    t.integer "account_id", null: false
    t.string "issuer", null: false
    t.string "client_id", null: false
    t.string "auth_endpoint", null: false
    t.string "token_endpoint", null: false
    t.string "jwks_endpoint", null: false
    t.text "public_key"
    t.string "deployment_id"
    t.string "platform_name"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_lti_platforms_on_account_id"
    t.index ["issuer", "client_id"], name: "index_lti_platforms_on_issuer_and_client_id", unique: true
  end

  create_table "lti_registrations", force: :cascade do |t|
    t.integer "lti_platform_id", null: false
    t.string "registration_id", null: false
    t.string "tool_url", null: false
    t.string "launch_url", null: false
    t.text "public_jwk"
    t.text "private_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lti_platform_id"], name: "index_lti_registrations_on_lti_platform_id"
    t.index ["registration_id"], name: "index_lti_registrations_on_registration_id", unique: true
  end

  create_table "lti_resource_links", force: :cascade do |t|
    t.integer "lti_platform_id", null: false
    t.string "resource_link_id", null: false
    t.string "context_id"
    t.string "context_title"
    t.string "resource_title"
    t.text "custom_parameters"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lti_platform_id", "resource_link_id"], name: "index_lti_links_on_platform_and_resource", unique: true
    t.index ["lti_platform_id"], name: "index_lti_resource_links_on_lti_platform_id"
  end

  create_table "lti_launches", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "lti_platform_id", null: false
    t.integer "lti_resource_link_id"
    t.string "lti_user_id"
    t.string "context_id"
    t.string "role"
    t.text "custom_params"
    t.datetime "launched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lti_platform_id"], name: "index_lti_launches_on_lti_platform_id"
    t.index ["lti_resource_link_id"], name: "index_lti_launches_on_lti_resource_link_id"
    t.index ["lti_user_id"], name: "index_lti_launches_on_lti_user_id"
    t.index ["user_id", "created_at"], name: "index_lti_launches_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_lti_launches_on_user_id"
  end

  create_table "lti_grades", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "lti_resource_link_id", null: false
    t.decimal "score", precision: 5, scale: 2
    t.decimal "score_maximum", precision: 5, scale: 2
    t.string "activity_progress"
    t.string "grading_progress"
    t.text "comment"
    t.datetime "submitted_at"
    t.boolean "synced_to_lms", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lti_resource_link_id"], name: "index_lti_grades_on_lti_resource_link_id"
    t.index ["user_id", "lti_resource_link_id"], name: "index_lti_grades_on_user_id_and_lti_resource_link_id"
    t.index ["user_id"], name: "index_lti_grades_on_user_id"
  end

  add_foreign_key "oauth_accounts", "users"
  add_foreign_key "account_memberships", "accounts"
  add_foreign_key "account_memberships", "users"
  add_foreign_key "saml_providers", "accounts"
  add_foreign_key "audit_logs", "accounts"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "data_access_logs", "accounts"
  add_foreign_key "data_access_logs", "users"
  add_foreign_key "transaction_logs", "accounts"
  add_foreign_key "transaction_logs", "users"
  add_foreign_key "security_events", "users"
  add_foreign_key "security_events", "users", column: "resolved_by_id"
  add_foreign_key "access_control_logs", "users"
  add_foreign_key "lti_platforms", "accounts"
  add_foreign_key "lti_registrations", "lti_platforms"
  add_foreign_key "lti_resource_links", "lti_platforms"
  add_foreign_key "lti_launches", "lti_platforms"
  add_foreign_key "lti_launches", "lti_resource_links"
  add_foreign_key "lti_launches", "users"
  add_foreign_key "lti_grades", "lti_resource_links"
  add_foreign_key "lti_grades", "users"
end
