require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:alessio)
    @idiot = users(:dudio)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  test "follow a user with regular http request" do
    assert_difference "@user.following.count", 1 do
      post relationships_path, followed_id: @idiot.id
    end
  end

  test "follow a user with ajax request" do
    assert_difference "@user.following.count", 1 do
      xhr :post, relationships_path, followed_id: @idiot.id
    end
  end

  test "unfollow a user with regular http request" do
    @user.follow(@idiot)
    relationship = @user.active_relationships.find_by(:followed_id => @idiot.id)
    assert_difference "@user.following.count", -1 do
      delete relationship_path(relationship)
    end
  end

  test "unfollow a user with ajax request" do
    @user.follow(@idiot)
    relationship = @user.active_relationships.find_by(:followed_id => @idiot.id)
    assert_difference "@user.following.count", -1 do
      xhr :delete, relationship_path(relationship)
    end
  end
end
