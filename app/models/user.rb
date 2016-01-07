class User < ActiveRecord::Base
  before_save :downcase_email

  # valid email regex
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :name, presence: true,
                   length: { maximum: 50 }
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX }
  has_secure_password
  validates :password, presence: true,
                       length: { minimum: 6 },
                       allow_nil: true

  private
    # downcase user email
    def downcase_email
      self.email.downcase!
    end
end
