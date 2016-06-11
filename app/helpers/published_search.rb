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
      @resources = @resources.greater_or_equal_to_published_at(params[:published_before])
    end

    if params[:published_after].present?
      @resources = @resources.less_or_equal_to_published_at(params[:published_after])
    end

    @resources
  end
end
