# frozen_string_literal: true

class CreateOauthAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :oauth_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :email
      t.string :name
      t.text :access_token

      t.timestamps
    end

    add_index :oauth_accounts, [:provider, :uid], unique: true
  end
end
