# frozen_string_literal: true

class AddSamlUidToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :saml_uid, :string
    add_index :users, :saml_uid, unique: true
  end
end
