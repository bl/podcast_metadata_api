# PublishedSearch:
# provides general logic around searching publishable resources
class PublishedSearch
  def initialize(resource)
    @resources = resource
  end

  # returns resources filtered by published param
  # valid patterns include:
  #   published: {true/false} : only published/unpublished
  def search(params = {})
    if params[:published].present?
      # TODO: verify if safe enough
      published_type = (params[:published]) ? true : false
      @resources = @resources.where(published: published_type)
    end

    if params[:published_before].present?
      # TODO: remove conversion below once using StrictParameters
      published_before = to_datetime(params[:published_before])
      @resources = @resources.greater_or_equal_to_published_at(published_before)
    end

    if params[:published_after].present?
      # TODO: remove conversion below once using StrictParameters
      published_after = to_datetime(params[:published_after])
      @resources = @resources.less_or_equal_to_published_at(published_after)
    end

    @resources
  end

  private

  def to_datetime(object)
    return object if object.is_a?(DateTime)

    object.respond_to?(:to_datetime) ? object.to_datetime : Time.zone.parse(object)
  end
end
