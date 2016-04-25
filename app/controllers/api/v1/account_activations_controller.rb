class Api::V1::AccountActivationsController < ApplicationController
  before_action :activatable_user, only: [:edit]
  before_action :inactivated_user, only: [:create]

  # create new activation digest/token pair, send a new activation email
  def create
    @user.update_activation_digest
    @user.send_activation_email
    head 201
  end

  # activate user
  def edit
    @user.activate
    render json: @user
  end

  private

  # verify user exists and is not activated
  def inactivated_user
    @user ||= User.find_by email: params[:email]
    unless @user && !@user.activated?
      render json: ErrorSerializer.serialize(email: "is invalid"), status: 422
    end
  end

  # verify user exists, is not activated, and provided correct activation token
  def activatable_user
    @user ||= User.find_by email: params[:email]
    unless @user && !@user.activated? && @user.authenticated?(:activation, params[:id])
      render json: ErrorSerializer.serialize(activation_link: "is invalid"), status: 422
    end
  end
end
