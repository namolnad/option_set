# frozen_string_literal: true

require "test_helper"

class TestOptionSet < Minitest::Test # rubocop:disable Metrics/ClassLength
  def setup
    User.delete_all
  end

  def test_that_it_has_a_version_number
    refute_nil ::OptionSet::VERSION
  end

  def test_default
    user = User.new
    assert_members_equal user.admin_permissions, []
  end

  def test_mask
    user = User.create!
    user.admin_permissions = %i[view edit]
    assert_equal 2, user.admin_permissions.count
    assert_equal user.admin_permissions_mask, 3
  end

  def test_has
    user = User.create!(admin_permissions: %i[view])
    assert user.admin_permission_view?
    assert user.has_admin_permission? :view
    refute user.admin_permission_delete?
    refute user.has_admin_permission? :delete
  end

  def test_add
    user = User.create!
    user.add_admin_permission :view
    assert user.admin_permission_view?
  end

  def test_eql?
    user = User.create!(admin_permissions: %i[view edit])
    assert user.admin_permissions_eql? %i[view edit]
    assert user.admin_permissions_eql? %i[edit view]
    refute user.admin_permissions_eql? %i[view]
  end

  def test_remove
    user = User.create!(admin_permissions: %i[view])
    assert user.admin_permission_view?
    user.remove_admin_permission :view
    refute user.admin_permission_view?
  end

  def test_intersection
    user = User.create!(admin_permissions: %i[view edit])
    assert_equal 2, user.admin_permissions.count
    assert_members_equal %i[view], user.admin_permissions_intersection(%i[view delete])
    assert_members_equal %i[edit view], user.admin_permissions_intersection(%i[view edit])
  end

  def test_union
    user = User.create!(admin_permissions: %i[view])
    assert_members_equal %i[view delete], user.admin_permissions_union(%i[delete])
  end

  def test_difference
    user = User.create!(admin_permissions: %i[view edit])
    assert_members_equal %i[delete], user.admin_permissions_difference(%i[view delete])

    user2 = User.create(admin_permissions: %i[view delete])
    assert_members_equal %i[edit], user2.admin_permissions_difference(%i[view edit])
  end

  def test_disjoint
    user = User.create!(admin_permissions: %i[view edit])
    assert user.admin_permissions_disjoint? %i[delete]
    refute user.admin_permissions_disjoint? %i[view]
  end

  def test_symmetric_difference
    user = User.create!(admin_permissions: %i[view edit])
    assert_members_equal %i[delete edit], user.admin_permissions_symmetric_difference(%i[view delete])
    user2 = User.create!(admin_permissions: %i[view delete])
    assert_members_equal %i[delete edit], user2.admin_permissions_symmetric_difference(%i[view edit])
  end

  def test_subset
    user = User.create!(admin_permissions: %i[view edit])
    assert user.admin_permissions_subset? %i[view edit delete]
    refute user.admin_permissions_subset? %i[view delete]
  end

  def test_superset
    user = User.create!(admin_permissions: %i[view edit])
    assert user.admin_permissions_superset? %i[view]
    refute user.admin_permissions_superset? %i[view delete]
  end

  def test_subtract
    user = User.create!(admin_permissions: %i[view edit delete])
    user.subtract_admin_permissions(%i[view edit])
    assert user.admin_permissions_eql? %i[delete]
  end

  def test_merge
    user = User.create!(admin_permissions: %i[view])
    user.merge_admin_permissions(%i[edit delete])
    assert user.admin_permissions_eql? %i[delete view edit]
  end

  def test_proper_subset
    user = User.create!(admin_permissions: %i[view edit])
    assert user.admin_permissions_proper_subset? %i[view edit delete]
    refute user.admin_permissions_proper_subset? %i[view edit]
  end

  def test_proper_superset
    user = User.create!(admin_permissions: %i[view edit])
    assert user.admin_permissions_proper_superset? %i[view]
    refute user.admin_permissions_proper_superset? %i[view edit]
  end

  def test_accessor_methods
    user = User.create!(admin_permissions: %i[view edit])
    assert user.admin_permission_edit?
    refute user.admin_permission_delete?
  end

  def test_state_change_methods
    user = User.create!(admin_permissions: %i[view])
    refute user.admin_permission_edit?
    user.admin_permission_edit!
    assert user.admin_permission_edit?
  end

  private

  def assert_members_equal(members, other_members)
    assert_equal members.to_set, other_members.to_set
  end
end
