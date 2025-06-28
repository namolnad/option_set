# frozen_string_literal: true

require "active_support/concern"

module OptionSet
  # Attribute module to extend the ActiveRecord::Base class
  module Attribute
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/BlockLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    class_methods do
      def option_set(klass, as: nil, through: nil)
        short_name = as&.to_s&.singularize || klass.to_s.split("::").last.gsub(/([a-z])([A-Z])/, '\1_\2').downcase!
        table_name = through&.to_s || "#{short_name.pluralize}_mask"
        plural_name = short_name.pluralize

        define_method(plural_name) do
          klass.cast(send(table_name))
        end

        define_method("#{plural_name}=") do |options|
          options = [options] unless options.is_a? Array
          send("#{table_name}=", klass.mask(options))
        end

        define_method("has_#{short_name}?") do |option|
          klass.include?(option, send(table_name))
        end

        define_method("#{short_name}_options") do
          klass.all_options
        end

        %i[add remove].each do |operation|
          define_method("#{operation}_#{short_name}") do |option|
            send("#{table_name}=", klass.send(operation, option, send(table_name)))
          end
        end

        %i[subtract merge].each do |operation|
          define_method("#{operation}_#{plural_name}") do |option|
            send("#{table_name}=", klass.send(operation, option, send(table_name)))
          end
        end

        %i[intersection union difference symmetric_difference].each do |operation|
          define_method("#{plural_name}_#{operation}") do |options|
            mask = klass.send(operation, options, send(table_name))
            klass.cast(mask)
          end
        end

        %i[disjoint eql intersect proper_subset proper_superset subset superset].each do |operation|
          define_method("#{plural_name}_#{operation}?") do |options|
            klass.send("#{operation}?", options, send(table_name))
          end
        end

        klass.options.each do |member|
          define_method("#{short_name}_#{member.name}?") do
            send("has_#{short_name}?", member.name)
          end
          define_method("#{short_name}_#{member.name}!") do
            send("add_#{short_name}", member.name)
            send("save!")
          end
          define_singleton_method("#{short_name}_#{member.name}") do
            options_matching(plural_name.to_sym => member.name)
          end
        end

        define_singleton_method("#{plural_name}_matching") do |options|
          options_matching(plural_name.to_sym => options)
        end

        @_option_set_columns ||= []
        @_option_set_columns << { column: table_name, short: plural_name.to_sym, klass: klass }
      end

      def options_matching(**kwargs)
        rel = all
        @_option_set_columns.each do |info|
          requested = kwargs[info[:short]]
          next unless requested

          mask = info[:klass].mask(requested.is_a?(Array) ? requested : [requested])
          rel = rel.where("#{info[:column]} & ? = ?", mask, mask)
        end
        rel
      end
    end
    # rubocop:enable Metrics/MethodLength,Metrics/AbcSize,Metrics/BlockLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
  end
end
