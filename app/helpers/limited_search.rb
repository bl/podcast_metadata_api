class LimitedSearch
  def initialize(resources)
    @resources = resources
  end

  def search(params)
    # limit parameter exists and is a valid number
    if params[:limit].present? && params[:limit].to_i != 0
      range = params[:limit].to_i
      range = 100 if range > 100

      @resources = @resources.limit(range)
    end

    @resources
  end
end
