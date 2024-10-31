# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "option_set"

require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "active_record"

ActiveRecord::Base.logger = Logger.new(ENV["VERBOSE"] ? STDOUT : nil)
ActiveRecord::Migration.verbose = ENV["VERBOSE"]

# migrations
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

ActiveRecord::Schema.define do
  create_table :users do |t|
    t.integer :admin_permissions_mask
  end
end

class AdminPermission < OptionSet::OptionSet
  View(1 << 0)
  Edit(1 << 1)
  Delete(1 << 2)
end

class User < ActiveRecord::Base
  option_set AdminPermission
end