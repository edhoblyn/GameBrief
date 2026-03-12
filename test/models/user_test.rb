require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "admin? is true for admin users" do
    user = User.new(email: "admin@test.com", password: "123456", role: "admin")

    assert_predicate user, :admin?
  end

  test "admin? is false for non-admin users" do
    user = User.new(email: "user@test.com", password: "123456", role: "user")

    assert_not user.admin?
  end

  test "role must be supported" do
    user = User.new(email: "invalid-role@test.com", password: "123456", role: "owner")

    assert_not user.valid?
    assert_includes user.errors[:role], "is not included in the list"
  end
end
