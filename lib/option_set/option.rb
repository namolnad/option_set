module OptionSet
  class Option
    attr_reader :name, :value

    alias inspect name

    def initialize(name, value)
      @name = name
      @value = value
    end
  end
end
