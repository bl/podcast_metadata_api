# PublishableSearch:
# provides general logic around searching publishable resources
class PublishableSearch
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

    @resources
  end
end
