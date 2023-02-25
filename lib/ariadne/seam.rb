# frozen_string_literal: true

require "open3"

module Ariadne
  class Seam
    attr_reader :rank, :depth, :klass, :method_name, :prefix, :parameters, :return_value, :binding, :path

    Parameter = Struct.new(:type, :param, :arg)

    class << self
      # We cannot make public methods because accessing the TracePoint
      # after it has been disabled would raise a RunTimeError
      # with message "access from outside".
      # We need to set the values while the TracePoint is enabled.
      def build(tracepoint, rank:, depth:)
        raise "tracepoint is disabled" unless tracepoint.enabled?

        new(rank: rank, depth: depth).tap do |seam|
          seam.instance_variable_set(:@klass, klass(tracepoint))
          seam.instance_variable_set(:@prefix, prefix(tracepoint))
          seam.instance_variable_set(:@method_name, method_name(tracepoint))
          seam.instance_variable_set(:@parameters, parameters(tracepoint))
          seam.instance_variable_set(:@path, path(tracepoint))
        end
      end

      private

      def klass(tracepoint)
        if tracepoint.self.is_a?(Module)
          tracepoint.self
        else
          tracepoint.self.class
        end
      end

      def method_name(tracepoint)
        tracepoint.method_id
      end

      def prefix(tracepoint)
        tracepoint.self.is_a?(Module) ? "." : "#"
      end

      def parameters(tracepoint)
        method = tracepoint.self.method(tracepoint.method_id)
        if forwarded_parameters?(method)
          [Parameter.new(:rest, "...", ["<?>"])]
        else
          method.parameters.flat_map do |parameter|
            type = parameter.first
            param = parameter.last
            arg = %i[* ** &].include?(param) ? ["<?>"] : tracepoint.binding.local_variable_get(param)
            Parameter.new(type, param, arg)
          rescue NameError
            Parameter.new(type, param, type == :rest ? ["<?>"] : "<?>")
          end
        end
      end

      # return true if method's signature is like `def my_method(...)`
      def forwarded_parameters?(method)
        method.parameters == [%i[rest *], %i[block &]]
      end

      def path(tracepoint)
        tracepoint.path
      end
    end

    private

    def initialize(rank:, depth:)
      @rank = rank
      @depth = depth
    end
  end
end
