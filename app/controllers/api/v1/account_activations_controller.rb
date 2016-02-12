class Api::V1::AccountActivationsController < ApplicationController
  before_action :activated_user, only: [:edit]

  def edit
    @user.activate
    render json: @user
  end

  private
    def activated_user
      @user ||= User.find_by email: params[:email]
      unless @user && !@user.activated? && @user.authenticated?(:activation, params[:id])
        render json: ErrorSerializer.serialize(activation_link: "is invalid"), status: 422
      end
    end
end
