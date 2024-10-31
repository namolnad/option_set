# frozen_string_literal: true

module OptionSet
  class Error < StandardError; end

  class OptionSet
    include Enumerable

    class << self
      # rubocop:disable Lint/MissingSuper
      def inherited(child)
        TracePoint.new(:end) do |tp|
          if tp.self == child
            tp.self.freeze
            tp.disable
          end
        end.enable

        child.instance_eval do
          @values = {}
          @options = {}
        end
      end
      # rubocop:enable Lint/MissingSuper

      # def method_missing(name, ...)
      def method_missing(name, value, ...)
        return super if frozen?

        add_option(name, value)
      end

      def respond_to_missing?(name, _)
        return super if frozen?

        true
      end

      # returns the union of the two masks
      def union(options, mask)
        self.mask(options) | mask
      end

      # returns the intersection of the two masks
      def intersection(options, mask)
        self.mask(options) & mask
      end

      # returns the difference of the two masks
      def difference(options, mask)
        self.mask(options) & ~mask
      end

      # returns the mask after adding the option
      def add(option, mask)
        mask | @options[option].value
      end

      # returns the mask after removing the option
      def remove(option, mask)
        mask & ~@options[option].value
      end

      # Casts the included mask to the corresponding options
      def cast(mask)
        options.select { |option| mask & option.value == option.value }.map(&:name).map(&:to_sym)
      end

      # Returns the mask for the included options
      def mask(options)
        options.map { |o| @options[o].value }.reduce(0, :|)
      end

      # Does the mask include the provided option?
      def include?(option, mask)
        val = @options[option].value
        mask & val == val
      end

      def all
        options.map(&:name).map(&:to_sym)
      end

      def values
        @values.keys
      end

      def each(&block)
        options.each(&block)
      end

      def options
        @options.values
      end

      private

      def add_option(name, val = nil)
        value = val || (1 << @options.length)

        if self == OptionSet
          raise Error,
                "You can't add values to the abstract OptionSet class itself."
        end

        if @options[name]
          raise Error,
                "Name conflict: '#{self.name}::#{name}' is already defined."
        end

        if @values[value]
          raise Error,
                "Value conflict: the value '#{value}' is defined for '#{cast(value).first.name}'."
        end

        option = Option.new(name, value)
        option.freeze
        @options[name] = option
        @values[value] = option
      end
    end
  end
end
