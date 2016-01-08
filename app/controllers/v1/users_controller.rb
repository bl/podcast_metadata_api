class V1::UsersController < ApplicationController
  #before_action :logged_in_user,  only: [:update]

  def show
    @user = User.find_by id: params[:id] 
    render json: @user
  end

  def index
    @users = User.all
    render json: @users
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: 200
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  def update
    @user = User.find_by id: params[:id]
    render json: { errors: "Invalid user" }, status: 403 and return if @user.nil?

    if @user.update(user_params)
      render json: @user, status: 200
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  def destroy
    @user = User.find_by id: params[:id]
    render json: { errors: "Invalid user" }, status: 403 and return if @user.nil?

    @user.destroy
    head 204
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
