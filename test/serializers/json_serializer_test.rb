require 'test_helper'

class JsonSerializerTest < Minitest::Test
  def setup
    @user = FactoryGirl.build :user
  end

  def json_error(res)
    JSON.parse res, symbolize_names: true
  end

  # ErrorSerializer

  def test_contains_record_errors
    @user.name = " "
    @user.valid?
    error_response = json_error ErrorSerializer.serialize(@user.errors, status: 422)
    refute_nil error_response[:errors]
    errors = error_response[:errors]
    assert_equal 1, errors.count
    errors.each do |err|
      assert err.values.include? 'name'
    end
    errors.each do |err|
      assert err.has_key? :status
    end
  end

  def test_contains_multiple_errors
    @user.name = " "
    @user.email = "james.com"
    @user.valid?
    error_response = json_error ErrorSerializer.serialize(@user.errors, status: 422)
    refute_nil error_response[:errors]
    errors = error_response[:errors]
    assert_equal 2, errors.count
    errors.each do |err|
      assert err.has_key? :status
    end
    #TODO: also verify contents of errors
  end

  def test_valid_on_generic_hashes
    invalid_login_error = {login: "is invalid" }
    error_response = json_error ErrorSerializer.serialize(invalid_login_error, status: 401)
    refute_nil error_response[:errors]
    errors = error_response[:errors]
    assert_equal 1, errors.count
    assert errors.first.values.include? 'is invalid'
    errors.each do |err|
      assert err.has_key? :status
    end
  end
end
