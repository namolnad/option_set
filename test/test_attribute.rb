# frozen_string_literal: true

require "test_helper"

class AttributeTest < ActiveSupport::TestCase
  setup do
    User.delete_all
    @user1 = User.create!(admin_permissions: %i[view edit], roles: [:manager])
    @user2 = User.create!(admin_permissions: [:delete], roles: [:staff])
    @user3 = User.create!(admin_permissions: %i[edit delete], roles: %i[manager staff])
  end

  test "finds records with dynamic *_matching helper" do
    assert_equal [@user1, @user3].sort, User.admin_permissions_matching([:edit]).to_a.sort
    assert_equal [@user2, @user3].sort, User.admin_permissions_matching([:delete]).to_a.sort
    assert_equal [@user1], User.roles_matching([:manager]).where(admin_permissions_mask: @user1.admin_permissions_mask)
  end

  test "finds records with generic options_matching" do
    users = User.options_matching(admin_permissions: [:edit], roles: [:manager])
    assert_includes users, @user1
    assert_includes users, @user3
    refute_includes users, @user2
  end

  test "finds records with scopes" do
    assert_equal [@user1, @user3].sort, User.admin_permission_edit.to_a.sort
    assert_equal [@user2, @user3].sort, User.admin_permission_delete.to_a.sort
    assert_equal [@user1, @user3], User.role_manager.to_a
    assert_equal [@user2, @user3], User.role_staff.to_a
  end

  test "dynamic helper delegates to generic" do
    rel1 = User.admin_permissions_matching([:edit])
    rel2 = User.options_matching(admin_permissions: [:edit])
    assert_equal rel1.to_sql, rel2.to_sql
  end

  test "no results if nothing matches" do
    assert_raises(NoMethodError) { User.options_matching(admin_permissions: [:nonexistent]) }
  end
end
