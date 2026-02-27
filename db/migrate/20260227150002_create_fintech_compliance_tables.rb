# frozen_string_literal: true

# Fintech Compliance Tables - PCI DSS, SOC2, Audit Requirements
class CreateFintechComplianceTables < ActiveRecord::Migration[8.0]
  def change
    # Transaction Audit Log (PCI DSS Requirement 10)
    create_table :transaction_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.string :transaction_type, null: false
      t.string :transaction_id
      t.decimal :amount, precision: 15, scale: 2
      t.string :currency, default: 'USD'
      t.string :status
      t.text :metadata
      t.string :ip_address
      t.string :device_fingerprint
      t.boolean :suspicious, default: false
      t.text :risk_score
      t.timestamps
    end

    add_index :transaction_logs, [:account_id, :created_at]
    add_index :transaction_logs, [:user_id, :created_at]
    add_index :transaction_logs, :transaction_id, unique: true
    add_index :transaction_logs, :suspicious

    # Security Events (SOC2 Requirement)
    create_table :security_events do |t|
      t.references :user, null: true, foreign_key: true
      t.string :event_type, null: false # login_attempt, password_change, permission_change, etc
      t.string :severity # low, medium, high, critical
      t.string :ip_address
      t.text :details
      t.boolean :resolved, default: false
      t.datetime :resolved_at
      t.references :resolved_by, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :security_events, [:event_type, :created_at]
    add_index :security_events, :severity
    add_index :security_events, :resolved

    # Access Control Log (SOC2 Control)
    create_table :access_control_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :resource_type
      t.bigint :resource_id
      t.string :permission
      t.boolean :granted, null: false
      t.string :reason
      t.timestamps
    end

    add_index :access_control_logs, [:user_id, :created_at]
    add_index :access_control_logs, [:resource_type, :resource_id]

    # Add fintech compliance fields to accounts
    add_column :accounts, :pci_compliant, :boolean, default: false
    add_column :accounts, :soc2_compliant, :boolean, default: false
    add_column :accounts, :requires_mfa_for_transactions, :boolean, default: false
    add_column :accounts, :transaction_limit_daily, :decimal, precision: 15, scale: 2
    add_column :accounts, :requires_transaction_approval, :boolean, default: false

    # Add compliance fields to users
    add_column :users, :kyc_verified_at, :datetime
    add_column :users, :kyc_document_id, :string
    add_column :users, :aml_check_passed_at, :datetime
    add_column :users, :risk_level, :string, default: 'low' # low, medium, high
    add_column :users, :transaction_limit, :decimal, precision: 15, scale: 2
  end
end
