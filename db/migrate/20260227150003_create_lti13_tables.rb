# frozen_string_literal: true

# LTI 1.3 (Learning Tools Interoperability) Tables
# Integrates with Canvas, Moodle, Blackboard, etc.
class CreateLti13Tables < ActiveRecord::Migration[8.0]
  def change
    # LTI Platforms (LMS systems like Canvas, Moodle)
    create_table :lti_platforms do |t|
      t.references :account, null: false, foreign_key: true
      t.string :issuer, null: false
      t.string :client_id, null: false
      t.string :auth_endpoint, null: false
      t.string :token_endpoint, null: false
      t.string :jwks_endpoint, null: false
      t.text :public_key
      t.string :deployment_id
      t.string :platform_name
      t.boolean :active, default: true
      t.timestamps
    end

    add_index :lti_platforms, [:issuer, :client_id], unique: true

    # LTI Registrations (Tool installations)
    create_table :lti_registrations do |t|
      t.references :lti_platform, null: false, foreign_key: true
      t.string :registration_id, null: false
      t.string :tool_url, null: false
      t.string :launch_url, null: false
      t.text :public_jwk
      t.text :private_key
      t.timestamps
    end

    add_index :lti_registrations, :registration_id, unique: true

    # LTI Resource Links (Course links, assignments)
    create_table :lti_resource_links do |t|
      t.references :lti_platform, null: false, foreign_key: true
      t.string :resource_link_id, null: false
      t.string :context_id
      t.string :context_title
      t.string :resource_title
      t.text :custom_parameters
      t.timestamps
    end

    add_index :lti_resource_links, [:lti_platform_id, :resource_link_id], unique: true, name: 'index_lti_links_on_platform_and_resource'

    # LTI Launches (User sessions from LMS)
    create_table :lti_launches do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lti_platform, null: false, foreign_key: true
      t.references :lti_resource_link, null: true, foreign_key: true
      t.string :lti_user_id
      t.string :context_id
      t.string :role
      t.text :custom_params
      t.datetime :launched_at
      t.timestamps
    end

    add_index :lti_launches, [:user_id, :created_at]
    add_index :lti_launches, :lti_user_id

    # LTI Grades (Assignment Grade Passback)
    create_table :lti_grades do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lti_resource_link, null: false, foreign_key: true
      t.decimal :score, precision: 5, scale: 2
      t.decimal :score_maximum, precision: 5, scale: 2
      t.string :activity_progress
      t.string :grading_progress
      t.text :comment
      t.datetime :submitted_at
      t.boolean :synced_to_lms, default: false
      t.timestamps
    end

    add_index :lti_grades, [:user_id, :lti_resource_link_id]

    # Add LTI fields to users
    add_column :users, :lti_enabled, :boolean, default: false
    add_column :users, :lti_user_id, :string
    add_column :users, :lti_roles, :text # JSON array of LTI roles
  end
end
