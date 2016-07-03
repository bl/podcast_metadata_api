class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception

  include ActionController::Serialization

  def current_user
    @current_user ||= User.find_by auth_token: request.headers['Authorization']
  end

  def current_user?(user)
    user == current_user
  end

  # user is logged in if they exist and are activated
  def logged_in?
    !current_user.nil? && current_user.activated?
  end

  private

  # verify user is activated
  def activated_user
    render json: ErrorSerializer.serialize(user: "has not been activated"), status: 403 unless @user.activated?
  end

  def correct_podcast
    @podcast ||= current_user.podcasts.find_by id: params[:podcast_id]
    render json: ErrorSerializer.serialize(podcast: "is invalid"), status: 422 unless @podcast
  end

  def logged_in_user
    render json: ErrorSerializer.serialize(user: "not authenticated"),
           status: :unauthorized and return unless !current_user.nil?
    render json: ErrorSerializer.serialize(user: "has not been activated"), status: 403 unless current_user.activated?
  end
end
