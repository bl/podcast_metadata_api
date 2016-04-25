class Api::V1::SessionsController < ApplicationController
  before_action :authenticated_user, only: [:create]
  before_action :activated_user,     only: [:create]

  def create
    @user.create_auth_token
    @user.save
    render json: @user, serializer: UserAuthSerializer, status: 200
  end

  def destroy
    @user = User.find_by auth_token: params[:id]   
    #TODO:  disabled rendering failure on destroy to possibly prevent continuous
    #       calls to destroy until a valid response
    #       render json: { errors: "Invalid user" }, status: 422 and return unless @user
    if @user
      @user.clear_auth_token
      @user.save
      head 204
    end
  end

  private
    def authenticated_user
      @user ||= User.find_by email: params[:session][:email]
      unless @user && @user.authenticated?(:password, params[:session][:password])
        render json: ErrorSerializer.serialize(email_password: "is invalid"), status: 422
      end
    end
end
