# frozen_string_literal: true

require "active_support/concern"

module OptionSet
  module Attribute
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/BlockLength
    class_methods do
      def option_set(klass, as: nil, through: nil)
        short_name = as&.to_s&.singularize || klass.to_s.split("::").last.gsub(/([a-z])([A-Z])/, '\1_\2').downcase!
        table_name = through&.to_s || "#{short_name.pluralize}_mask"

        define_method(short_name.pluralize) do
          klass.cast(send(table_name))
        end

        define_method("#{short_name.pluralize}=") do |options|
          options = [options] unless options.is_a? Array
          send("#{table_name}=", klass.mask(options))
        end

        define_method("has_#{short_name}?") do |option|
          klass.include?(option, send(table_name))
        end

        define_method("add_#{short_name}") do |option|
          send("#{table_name}=", klass.add(option, send(table_name)))
        end

        define_method("remove_#{short_name}") do |option|
          send("#{table_name}=", klass.remove(option, send(table_name)))
        end

        define_method("#{short_name}_intersection") do |options|
          mask = klass.intersection(options, send(table_name))
          klass.cast(mask)
        end

        define_method("#{short_name}_union") do |options|
          mask = klass.union(options, send(table_name))
          klass.cast(mask)
        end

        define_method("#{short_name}_difference") do |options|
          mask = klass.difference(options, send(table_name))
          klass.cast(mask)
        end

        klass.options.each do |member|
          define_method("#{short_name}_#{member.short_name}?") do
            send("has_#{short_name}?", member)
          end
          define_method("#{short_name}_#{member.short_name}!") do
            send("add_#{short_name}", member)
            send("save!")
          end
        end
      end
    end
    # rubocop:enable Metrics/MethodLength,Metrics/AbcSize,Metrics/BlockLength
  end
end
