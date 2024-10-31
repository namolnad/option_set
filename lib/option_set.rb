# frozen_string_literal: true

require "active_support"

require_relative "option_set/attribute"
require_relative "option_set/option"
require_relative "option_set/option_set"
require_relative "option_set/version"

ActiveSupport.on_load(:active_record) do
  include OptionSet::Attribute
end
