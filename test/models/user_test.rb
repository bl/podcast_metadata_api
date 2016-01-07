require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name:  "Chris Evans",
                     email: "chris@evans.com",
                     password:              "password",
                     password_confirmation: "password")
  end

  test "user is valid" do
    assert @user.valid?
  end

  # name
  
  test "name should be present" do
    @user.name = " "
    assert_not @user.valid?
  end

  test "name should not be longer than 50 characters" do
    @user.name = "a" * 50
    assert @user.valid?
    @user.name += "a"
    assert_not @user.valid?
  end

  # email

  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  test "email should be case insensitive" do
    @user.email = "ExAMPle@User.com"
    @user.save
    duplicate_user = @user.dup
    duplicate_user.email.downcase!
    assert_equal duplicate_user.email, @user.reload.email
    assert_not duplicate_user.valid?
  end

  test "user with invalid email should be invalid" do
    @user.email = "test.com"
    assert_not @user.valid?
    @user.email = "user.com"
    assert_not @user.valid?
    @user.email = "user.@example"
    assert_not @user.valid?
  end

  test "user with valid email should be valid" do
    @user.email = "test.email@example.com"
    assert @user.valid?
    @user.email = "test.@example.com"
    assert @user.valid?
    @user.email = "test.@example.co.uk"
    assert @user.valid?
  end

  test "user email should be unique" do
    @user.save
    duplicate_user = @user.dup
    assert_not duplicate_user.valid?
    assert_match /has already been taken/, duplicate_user.errors[:email].to_s
  end

  test "user email should not be longer than 255 characters" do
    @user.email = ("a" *244) + "@example.co"
    assert @user.valid?
    @user.email += "m"
    assert_not @user.valid?
  end

  # password

  test "user password digest should be present" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password must be at least 6 characters" do
    @user.password = @user.password_confirmation = "12345"
    assert_not @user.valid?
    @user.password = @user.password_confirmation = "123456"
    assert @user.valid?
  end

  #test "valid password should be authenticated" do
  #end
end
