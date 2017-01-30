# abstraction class around publishing publishable ActiveModel resources
# TODO: look into safely implementing using possibly Java-like interfaces
class ResourcePublisher
  def initialize(res, options = {})
    @res = res
    @options = options.slice(:published_at)
  end

  # publish resource if valid. executes validators
  def publish
    default_options = {
      published: true,
      published_at: Time.zone.now
    }
    @res.update(default_options.merge(@options))
  end

  # unpublish resource
  def unpublish
    @res.update_columns(published: false, published_at: nil)
  end
end
