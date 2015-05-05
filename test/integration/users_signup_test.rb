require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "invalid signup info" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, user: { name: "", email: "user@invalid", password: "foo", password_confirmation: "bar" }
    end
    assert_template "users/new"
  end

  test "valid signup info" do
    get signup_path
    assert_difference "User.count", 1 do
      post_via_redirect users_path, user: { name: "Asdf", email: "test@test.com", password: "asdfjkl;", password_confirmation: "asdfjkl;" }
    end
    assert_template "users/show"
    assert is_logged_in?
  end
end
