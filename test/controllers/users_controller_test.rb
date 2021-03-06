require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:alessio)
    @idiot = users(:dudio)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "redirect update when not logged in" do
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "redirect edit when wrong user" do
    log_in_as(@idiot)
    get :edit, id: @user
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "redirect update when wrong user" do
    log_in_as(@idiot)
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect from index page if not logged in" do
    get :index
    assert_redirected_to login_url
  end

  test "should redirect from destroy if not logged in" do
    assert_no_difference "User.count" do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  test "should redirect from destroy if not admin" do
    log_in_as(@idiot)
    assert_no_difference "User.count" do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end

  test "should redirect 'following' when not logged in" do
    get :following, id: @user
    assert_redirected_to login_url
  end

  test "should redirect 'followers' when not logged in" do
    get :followers, id: @user
    assert_redirected_to login_url
  end
end
