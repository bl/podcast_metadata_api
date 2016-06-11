class PaginatedSearch
  def initialize(resource_type, resources)
    @resource_type = resource_type
    @resources = resources
  end

  # TODO: implement more efficiently using SQL queries
  def search(params)
    @resources = @resources.offset(params[:offset]) if params[:offset].present?

    @resources
  end
end
