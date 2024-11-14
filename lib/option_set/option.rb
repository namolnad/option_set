# frozen_string_literal: true

module OptionSet
  # Option class to represent a single option
  class Option
    attr_reader :name, :value

    alias inspect name

    def initialize(name, value)
      @name = name
      @value = value
    end
  end
end
