class V1::SessionsController < ApplicationController

  def create
    @user = User.find_by email: params[:session][:email]
    if @user && @user.authenticated?(:password, params[:session][:password])
      # generate new auth_token on valid log-in
      @user.create_auth_token
      @user.save
      render json: @user, status: 200
    else
      render json: { errors: "Invalid email or password" }, status: 422
    end
  end

  def destroy
    @user = User.find_by auth_token: params[:id]   
    #TODO:  disabled rendering failure on destroy to possibly prevent continuous
    #       calls to destroy until a valid response
    #       render json: { errors: "Invalid user" }, status: 403 and return unless @user
    if @user
      @user.clear_auth_token
      @user.save
      head 204
    end
  end
end
