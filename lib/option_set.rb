# frozen_string_literal: true

require "active_support"

require_relative "option_set/version"
require_relative "option_set/option_set"
require_relative "option_set/attribute"

ActiveSupport.on_load(:active_record) do
  include OptionSet::Attribute
end
