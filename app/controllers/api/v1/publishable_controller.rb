class Api::V1::PublishableController < ApplicationController
  include ActionView::Helpers::TextHelper # used for pluralize

  before_action :verify_unpublished_access, only: [:show]
  before_action :verify_unpublishable_search, only: [:index]

  # use derived class' resource when publishing
  def publish
    render json: ErrorSerializer.serialize(resource_name => "is already published"), status: 422 and return if resource.published

    if ResourcePublisher.new(resource).publish
      render json: resource, status: 200
    else
      render json: ErrorSerializer.serialize(resource.errors), status: 422
    end
  end

  # use derived class' resource when unpublishing
  def unpublish
    render json: ErrorSerializer.serialize(resource_name => "is already unpublished"), status: 422 and return unless resource.published

    ResourcePublisher.new(resource).unpublish
    render json: resource, status: 200
  end

  protected

  # display unpublished resource only if logged_in user is the owner
  def verify_unpublished_access
    unless resource.published || (!resource.published && logged_in? && current_user.send(pluralized_name).exists?(resource.id))
      render json: ErrorSerializer.serialize(resource_name => "is invalid"), status: 422 and return false
    end
    true
  end

  private

  # verify if the given current_user is eligible to perform an unpublished search
  # TODO: implement using author_id for articles
  def verify_unpublishable_search
    # only logged in users viewing their own resources can search unpublished
    unless logged_in? && params[:user_id].present? && current_user.id == params[:user_id].to_i
      params.merge! published: true
    end
  end

  # helper functions
  def resource_name
    @name ||= resource.class.name.downcase
  end

  def pluralized_name
    @pluralized_name ||= pluralize(2, resource_name).split.last
  end
end
