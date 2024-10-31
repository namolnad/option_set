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

  def test_has_permission
    user = User.create!(admin_permissions_mask: 3)
    assert user.admin_permission_view?
    assert user.has_admin_permission? :view
    refute user.admin_permission_delete?
    refute user.has_admin_permission? :delete
  end

  def test_add_permission
    user = User.create!
    user.add_admin_permission :view
    assert user.admin_permission_view?
  end

  def test_remove_permission
    user = User.create!(admin_permissions_mask: 3)
    assert user.admin_permission_view?
    user.remove_admin_permission :view
    refute user.admin_permission_view?
  end

  def test_intersection
    user = User.create!(admin_permissions_mask: 3)
    assert_equal 2, user.admin_permissions.count
    assert_equal %i[view], user.admin_permission_intersection(%i[view delete])
    assert_equal %i[view edit], user.admin_permission_intersection(%i[view edit])
  end

  def test_union
    user = User.create!(admin_permissions_mask: 1)
    assert_equal 1, user.admin_permissions.count
    assert_equal 2, user.admin_permission_union(%i[view delete]).count
  end
end
