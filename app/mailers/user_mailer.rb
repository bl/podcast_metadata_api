class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_acivation.subject
  #
  # NOTE: passing actiavtion_token as separate argument because ActiveMailer
  # serialization does not serialize the objects themselves but rather the
  # arguments to the account_activation method, thus losing the instance
  # variable activation_token (think de-serializing not the object, but
  # pulling @user by user_id from the db, losing instance variables)
  def account_activation(user, activation_token)
    @user = user
    @activation_token = activation_token
    mail to: user.email, subject: "Account activation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user

    mail to: user.email, subject: "Password reset"
  end
end
