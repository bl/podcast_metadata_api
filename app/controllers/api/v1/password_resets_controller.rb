class Api::V1::PasswordResetsController < ApplicationController
  before_action :get_user, only: [:show, :create, :update]
  before_action :valid_user, only: [:show, :create, :update]
  before_action :activated_user, only: [:show, :create, :update]
  before_action :check_reset_token, only: [:update]
  before_action :check_expired, only: [:update]

  # returns true if the provided reset_token/email combination is valid
  # NOTE: this action/route is to be used by the web api client to verify if
  # the password reset edit page should be displayed. Possibly look into making
  # this a private action/route as it serves no real purpose that this API's
  # update route does not
  def show
    head 200
  end

  # deliver an password reset email
  def create
    @user.update_reset_digest
    @user.send_password_reset_email
    head 201
  end

  def update
    if @user.update(user_params)
      render json: @user, status: 200
      # clear reset digest
      @user.clear_reset_digest
    else
      render json: ErrorSerializer.serialize(@user.errors), status: 422
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user ||= User.find_by email: params[:email]
  end

  # retrieve user via email
  def valid_user
    unless @user
      render json: ErrorSerializer.serialize(email: "is invalid"), status: 422
    end
  end

  def check_reset_token
    unless @user.authenticated?(:reset, params[:id])
      render json: ErrorSerializer.serialize(reset_token: "is invalid"), status: 422
    end
  end

  def check_expired
    if @user.password_reset_expired?
      render json: ErrorSerializer.serialize(reset_token: "has expired"), status: 422
    end
  end
end
