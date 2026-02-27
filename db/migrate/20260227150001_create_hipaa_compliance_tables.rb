# frozen_string_literal: true

# HIPAA Compliance Module
# Provides audit logging, encryption, and access controls for healthcare compliance
class CreateHipaaComplianceTables < ActiveRecord::Migration[8.0]
  def change
    # Audit Log for HIPAA compliance
    create_table :audit_logs do |t|
      t.references :user, null: true, foreign_key: true
      t.references :account, null: true, foreign_key: true
      t.string :action, null: false
      t.string :resource_type
      t.bigint :resource_id
      t.text :changes
      t.string :ip_address
      t.string :user_agent
      t.string :session_id
      t.string :phi_accessed # Protected Health Information accessed
      t.datetime :occurred_at, null: false
      t.timestamps
    end

    add_index :audit_logs, [:user_id, :occurred_at]
    add_index :audit_logs, [:account_id, :occurred_at]
    add_index :audit_logs, [:resource_type, :resource_id]
    add_index :audit_logs, :session_id

    # Data Access Log for PHI (Protected Health Information)
    create_table :data_access_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :data_type, null: false
      t.string :action, null: false # read, create, update, delete
      t.text :justification # Why was this data accessed?
      t.string :ip_address
      t.timestamps
    end

    add_index :data_access_logs, [:user_id, :created_at]
    add_index :data_access_logs, [:account_id, :created_at]

    # Add HIPAA fields to users
    add_column :users, :hipaa_trained_at, :datetime
    add_column :users, :hipaa_agreement_accepted_at, :datetime
    add_column :users, :last_password_change_at, :datetime
    add_column :users, :force_password_change, :boolean, default: false
    add_column :users, :session_timeout_minutes, :integer, default: 15

    # Add encryption flag to accounts
    add_column :accounts, :hipaa_enabled, :boolean, default: false
    add_column :accounts, :encryption_enabled, :boolean, default: false
    add_column :accounts, :auto_logout_enabled, :boolean, default: false
  end
end
