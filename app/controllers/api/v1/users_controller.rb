class Api::V1::UsersController < ApplicationController
  before_action :logged_in_user,  only: [:update, :destroy]
  before_action :correct_user,    only: [:update, :destroy]

  def show
    @user = User.find_by id: params[:id] 
    render json: ErrorSerializer.serialize(user: "is invalid"), status: 422 and return unless @user

    render json: @user
  end

  def index
    @users = User.where(activated: true)
    render json: @users
  end

  def create
    @user = User.new(user_params)
    # create user, but keep activated? false
    if @user.save
      #render json: @user, status: 201
      #TODO: send email
      head 201
    else
      render json: ErrorSerializer.serialize(@user.errors), status: 422
    end
  end

  def update
    @user = current_user
    if @user.update(user_params)
      render json: @user, status: 200
    else
      render json: ErrorSerializer.serialize(@user.errors), status: 422
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
      user = User.find_by id: params[:id]
      render json: ErrorSerializer.serialize( user: "is invalid"),
             status: 422 unless current_user?(user)
    end
end
