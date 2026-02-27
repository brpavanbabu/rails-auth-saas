# frozen_string_literal: true

class CreateSamlProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :saml_providers do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.string :entity_id, null: false
      t.text :idp_metadata_url
      t.text :idp_cert
      t.text :sso_target_url
      t.string :name_identifier_format
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :saml_providers, [:account_id, :entity_id], unique: true
  end
end
