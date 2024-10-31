# frozen_string_literal: true

require "test_helper"

class TestOptionSet < Minitest::Test
  def setup
    User.delete_all
  end

  def test_that_it_has_a_version_number
    refute_nil ::OptionSet::VERSION
  end

  def test_default
    user = User.new
    assert_equal user.admin_permissions, []
  end

  def test_permissions
    user = User.create!
    user.admin_permissions = %i[view edit]
    assert_equal 2, user.admin_permissions.count
    assert_equal user.admin_permissions_mask, 3
  end
end
