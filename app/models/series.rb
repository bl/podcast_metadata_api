class Series < ActiveRecord::Base
  belongs_to :user

  has_many :podcasts, dependent: :destroy

  validates :user,        presence: true
  validates :title,       presence: true,
                          length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }

  def Series.search(params = {})
    series = Series.all
    if params[:user_id].present?
      user = User.find_by id: params[:user_id]
      series = user.series if user
    end

    series
  end

end
