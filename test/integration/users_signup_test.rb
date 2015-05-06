require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup info" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, user: { name: "", email: "user@invalid", password: "foo", password_confirmation: "bar" }
    end
    assert_template "users/new"
    assert_select "div#error_explanation"
  end

  test "valid signup info with acct activation" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, user: { name: "Asdf", email: "test@test.com", password: "asdfjkl;", password_confirmation: "asdfjkl;" }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    log_in_as(user)
    assert_not is_logged_in?

    get edit_account_activation_path("some invalid token blargh")
    assert_not is_logged_in?

    get edit_account_activation_path(user.activation_token, email: "some wrong email lol")
    assert_not is_logged_in?

    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template "users/show"
    assert is_logged_in?
  end
end
