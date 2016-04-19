class Api::V1::PublishableController < ApplicationController
  before_action :verify_unpublishable_search, only: [:index]

  # use derived class' resource when publishing
  def publish
    name = resource.class.name.downcase
    render json: ErrorSerializer.serialize(name => "is already published"), status: 422 and return if resource.published

    if ResourcePublisher.new(resource).publish
      render json: resource, status: 200
    else
      render json: ErrorSerializer.serialize(resource.errors), status: 422
    end
  end

  # use derived class' resource when unpublishing
  def unpublish
    name = resource.class.name.downcase
    render json: ErrorSerializer.serialize(name => "is already unpublished"), status: 422 and return unless resource.published

    ResourcePublisher.new(resource).unpublish
    render json: resource, status: 200
  end

  private

  # verify if the given current_user is eligible to perform an unpublished search
  def verify_unpublishable_search
    # only logged in users viewing their own articles can search unpublished
    unless logged_in? && params[:user_id].present? && current_user.id == params[:user_id].to_i
      params.merge! published: true
    end
  end
end
