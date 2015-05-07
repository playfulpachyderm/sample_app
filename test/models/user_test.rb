require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
  	@user = User.new(name: "Example User", email: "user@example.com",
  									 password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
  	assert @user.valid?
  end

  test "name should be present" do
  	@user.name = "     "
  	assert_not @user.valid?
  end

  test "email should be present" do
  	@user.email = "     "
  	assert_not @user.valid?
  end

  test "name should not be too long" do
  	@user.name = "a" * 51
  	assert_not @user.valid?
  end

  test "email should not be too long" do
  	@user.email = "#{'a' * 244} + @example.com"
  	assert_not @user.valid?
  end

  test "accept valid addresses" do
  	valid_addresses = ["user@example.com",
  					   				 "USER@asdf.com",
  					   				 "A_US-ER@jkl.semi.colon",
  					   				 "asdf.jkl@semi.colon",
  					   				 "morti+reniti@dumnezeu.com"]
  	valid_addresses.each do |addr|
  		@user.email = addr
  		assert @user.valid?, "#{addr.inspect} should be valid"
  	end
  end

  test "refuse invalid addresses" do
  	invalid_addresses = ["user@example,com",
  											 "user_at_foo.org",
  											 "user.name@example.",
  											 "foo@bar_baz.com",
  											 "foo@bar+baz.com"]
  	invalid_addresses.each do |addr|
  		@user.email = addr
  		assert_not @user.valid?, "#{addr.inspect} should be invalid"
  	end
  end

  test "emails should be unique" do
  	dupe = @user.dup
  	dupe.email = @user.email.upcase
  	@user.save
  	assert_not dupe.valid?
  end

  test "password minimum length" do
  	@user.password = @user.password_confirmation = 'a' * 5
  	assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, "")
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    alessio = users(:alessio)
    idiot = users(:dudio)
    assert_not alessio.following?(idiot)
    alessio.follow(idiot)
    assert alessio.following?(idiot)
    assert idiot.followers.include?(alessio)
    alessio.unfollow(idiot)
    assert_not alessio.following?(idiot)
  end

  test "feed should have the right posts" do
    alessio = users(:alessio)
    mozart = users(:mozart)
    dudio = users(:dudio)

    # I followed mozart, so I should see his
    mozart.microposts.each do |post|
      assert alessio.feed.include?(post)
    end

    # I should see mine
    alessio.microposts.each do |post|
      assert alessio.feed.include?(post)
    end

    # I shouldn't see dudio's (he's an idiot)
    dudio.microposts.each do |post|
      assert_not alessio.feed.include?(post)
    end

  end
end
