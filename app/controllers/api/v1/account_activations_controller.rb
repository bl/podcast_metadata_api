class Api::V1::AccountActivationsController < ApplicationController
  before_action :activatable_user, only: [:edit]
  before_action :inactivated_user, only: [:create]

  def create
    @user.update_activation_digest
    @user.send_activation_email
    head 201
  end

  def edit
    @user.activate
    render json: @user
  end

  private

    def inactivated_user
      @user ||= User.find_by email: params[:email]
      unless @user && !@user.activated?
        render json: ErrorSerializer.serialize(email: "is invalid"), status: 422
      end
    end

    def activatable_user
      @user ||= User.find_by email: params[:email]
      unless @user && !@user.activated? && @user.authenticated?(:activation, params[:id])
        render json: ErrorSerializer.serialize(activation_link: "is invalid"), status: 422
      end
    end
end
