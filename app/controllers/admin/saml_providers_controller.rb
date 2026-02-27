# frozen_string_literal: true

module Admin
  class SamlProvidersController < ApplicationController
    before_action :require_login
    before_action :set_account
    before_action :require_account_admin
    before_action :set_saml_provider, only: [:show, :edit, :update, :destroy]

    def index
      @saml_providers = @account.saml_providers.order(:name)
    end

    def show
    end

    def new
      @saml_provider = @account.saml_providers.build
    end

    def create
      @saml_provider = @account.saml_providers.build(saml_provider_params)

      if @saml_provider.save
        redirect_to admin_account_saml_provider_path(@account, @saml_provider),
          notice: "SAML provider was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @saml_provider.update(saml_provider_params)
        redirect_to admin_account_saml_provider_path(@account, @saml_provider),
          notice: "SAML provider was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @saml_provider.destroy
      redirect_to admin_account_saml_providers_path(@account),
        notice: "SAML provider was removed."
    end

    private

    def set_account
      @account = Account.find(params[:account_id])
    end

    def set_saml_provider
      @saml_provider = @account.saml_providers.find(params[:id])
    end

    def require_account_admin
      membership = current_user.account_memberships.find_by(account: @account)
      return if membership&.role.in?(%w[owner admin])

      redirect_to root_path, alert: "You don't have permission to manage SSO for this account."
    end

    def saml_provider_params
      params.require(:saml_provider).permit(
        :name,
        :entity_id,
        :idp_metadata_url,
        :idp_cert,
        :sso_target_url,
        :name_identifier_format,
        :active
      )
    end
  end
end
