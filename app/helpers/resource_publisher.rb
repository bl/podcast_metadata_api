# abstraction class around publishing publishable ActiveModel resources
# TODO: look into safely implementing using possibly Java-like interfaces
class ResourcePublisher
  def initialize(res)
    @res = res
  end

  # publish resource if valid. executes validators
  def publish
    @res.update(published: true, published_at: Time.zone.now)
  end

  # unpublish resource
  def unpublish
    @res.update_columns(published: false, published_at: nil)
  end
end
