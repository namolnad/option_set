# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "option_set"

require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "active_record"

ActiveRecord::Base.logger = Logger.new(ENV["VERBOSE"] ? STDOUT : nil) # rubocop:disable Style/GlobalStdStream
ActiveRecord::Migration.verbose = ENV["VERBOSE"]

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.integer :admin_permissions_mask
    t.integer :roles_mask
  end
end

class AdminPermission < OptionSet::Base
  view 1 << 0
  edit 1 << 1
  delete 1 << 2
end

class Role < OptionSet::Base
  manager 1 << 0
  staff 1 << 1
end

class User < ActiveRecord::Base
  option_set AdminPermission
  option_set Role
end
