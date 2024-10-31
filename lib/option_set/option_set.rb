# frozen_string_literal: true

module OptionSet
  class Error < StandardError; end

  class OptionSet
    include Enumerable

    attr_reader :name, :value, :short_name

    alias inspect name

    def initialize(name, value)
      @short_name = name.to_s.gsub(/([a-z])([A-Z])/, '\1_\2').downcase!
      @name = "#{self.class.name}::#{name}"
      @value = value
    end

    class << self
      attr_reader :options

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
          @options = []
        end
      end
      # rubocop:enable Lint/MissingSuper

      def const_missing(name)
        return super if frozen?

        new(name)
      end

      def method_missing(name, ...)
        return super if frozen?
        return super unless name[0] =~ /[A-Z]/

        new(name, ...)
      end

      def respond_to_missing?(name, _)
        return super if frozen?

        name[0] =~ /[A-Z]/
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
        mask | const_from_val(option).value
      end

      # returns the mask after removing the option
      def remove(option, mask)
        mask & ~const_from_val(option).value
      end

      # Casts the included mask to the corresponding options
      def cast(mask)
        @options.select { |option| mask & option.value == option.value }.map(&:short_name).map(&:to_sym)
      end

      # Returns the mask for the included options
      def mask(options)
        options.map { |o| const_from_val(o) }.map { |option| @values[option.value].value }.reduce(0, :|)
      end

      # Does the mask include the provided option?
      def include?(option, mask)
        val = const_from_val(option).value
        mask & val == val
      end

      def all
        @options.map(&:short_name).map(&:to_sym)
      end

      def values
        @values.keys
      end

      def each(&)
        @options.each(&)
      end

      private

      def new(name, val = nil, &)
        value = val || (1 << @options.length)

        if self == OptionSet
          raise Error,
                "You can't add values to the abstract OptionSet class itself."
        end

        if const_defined?(name)
          raise Error,
                "Name conflict: '#{self.name}::#{name}' is already defined."
        end

        if @values[value]
          raise Error,
                "Value conflict: the value '#{value}' is defined for '#{cast(value).first.name}'."
        end

        option = super(name, value)
        option.instance_eval(&) if block_given?
        option.freeze

        const_set(name, option)
        @options << option
        @values[value] = option
      end

      def const_from_val(val)
        return val unless val.is_a?(Symbol) || val.is_a?(String)

        const_name = val.to_s.split("_").collect { |w| w.sub(/^./, w[0].upcase) }.join
        const_name = "#{name}::#{const_name}"
        Object.const_get(const_name)
      end
    end
  end
end
