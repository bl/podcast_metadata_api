class User < ActiveRecord::Base
  before_save   :downcase_email
  # create auth_token on user create
  #   allows for making API calls right after creation without needing to log-in
  before_create :create_auth_token

  has_many :podcasts, dependent: :destroy
  has_many :articles, foreign_key: 'author_id', 
                      dependent: :destroy

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
  validates :auth_token,  uniqueness: true

  def create_auth_token
    begin
      self.auth_token = User.new_token
    end while self.class.exists?(auth_token: self.auth_token)
  end

  def clear_auth_token
    self.auth_token = nil
  end

  # verify authenticated user attribute
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # generate base64 url-safe string
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # generate bcrypt digest from input string
  def User.digest(input)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine::cost
    BCrypt::Password.create(input, cost: cost)
  end

  private

    # downcase user email
    def downcase_email
      self.email.downcase!
    end
end
