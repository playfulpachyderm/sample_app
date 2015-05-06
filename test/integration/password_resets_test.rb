require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:alessio)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template "password_resets/new"

    # --- testing send password reset ---

    # bad email
    post password_resets_path, password_reset: {email: ""}
    assert_not flash.empty?
    assert_template "password_resets/new"

    # good email
    post password_resets_path, password_reset: {email: @user.email}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    # --- email is "sent" ---

    user = assigns(:user)

    # email doesn't match current user's
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    # user isn't activated
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    # email is right but token isn't
    get edit_password_reset_path("blargh", email: user.email)
    assert_redirected_to root_url

    # email and token are now both correct
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template "password_resets/edit"
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # new password doesn't match confirmation
    patch password_reset_path(user.reset_token),
        email: user.email, user: { password: "asdfjkl;", password_confirmation: ";lkjfdsa" }
    assert_select "div#error_explanation"

    # new password is blank
    patch password_reset_path(user.reset_token),
        email: user.email, user: { password: "   ", password_confirmation: "blargh" }
    assert_not flash.empty?
    assert_template "password_resets/edit"

    # new password is all good
    patch password_reset_path(user.reset_token),
        email: user.email, user: { password: "asdfjkl;", password_confirmation: "asdfjkl;" }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user_url(user)
  end
end
