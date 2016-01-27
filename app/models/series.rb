class Series < ActiveRecord::Base
  belongs_to :user

  has_many :podcasts, dependent: :destroy

  validates :user,        presence: true
  validates :title,       presence: true,
                          length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }

end
