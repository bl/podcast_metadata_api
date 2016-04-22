require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  def setup
    @user = FactoryGirl.create :user
  end
  
  test "account_activation" do

    # test deliver_later by retrieving the enqueued mail job
    perform_enqueued_jobs do
      UserMailer.account_activation(@user, @user.activation_token).deliver_later

      assert_not ActionMailer::Base.deliveries.empty?
      mail = ActionMailer::Base.deliveries.last

      assert_equal "Account activation", mail.subject
      assert_equal [@user.email], mail.to
      assert_equal ["noreply@example.com"], mail.from
      assert_match @user.name, mail.body.encoded
      assert_match @user.activation_token, mail.body.encoded
      assert_match CGI::escape(@user.email), mail.body.encoded
    end
  end

#  test "password_reset" do
#    mail = UserMailer.password_reset
#    assert_equal "Password reset", mail.subject
#    assert_equal ["to@example.org"], mail.to
#    assert_equal ["from@example.com"], mail.from
#    assert_match "Hi", mail.body.encoded
#  end

end
