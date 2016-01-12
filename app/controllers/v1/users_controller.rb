class V1::UsersController < ApplicationController
  before_action :logged_in_user,  only: [:update, :destroy]
  before_action :correct_user,    only: [:update, :destroy]

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
      render json: @user, status: 201
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  def update
    @user = current_user
    if @user.update(user_params)
      render json: @user, status: 200
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  def destroy
    current_user.destroy if logged_in?
    head 204
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    def correct_user
      user ||= User.find_by id: params[:id]
      render json: { errors: "Invalid user" },
             status: 403 unless current_user?(user)
    end
end
