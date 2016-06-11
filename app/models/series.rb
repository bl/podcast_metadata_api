class Series < ActiveRecord::Base
  belongs_to :user

  has_many :podcasts, dependent: :destroy
  has_many :published_podcasts, -> { where published: true },
                          class_name: 'Podcast',
                          dependent: :destroy

  validates :user,        presence: true
  validates :title,       presence: true,
                          length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }

  # order series in descending published date order on default scope
  default_scope -> { order(published_at: :desc) }

  scope :greater_or_equal_to_published_at, lambda { |published_at|
    where("published_at >= ?", published_at)
  }

  scope :less_or_equal_to_published_at, lambda { |published_at|
    where("published_at <= ?", published_at)
  }

  def Series.search(params = {})
    series = PaginatedSearch.new(Series, Series.all).search(params)
    if params[:user_id].present?
      user = User.find_by id: params[:user_id]
      series = user.series if user
    end

    # perform publishable searches
    series = PublishedSearch.new(series).search(params)

    # perform search limiting
    series = LimitedSearch.new(series).search(params)
  end

end
