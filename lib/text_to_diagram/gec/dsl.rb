require 'active_support/core_ext'
require 'active_support/inflector'

module TextToDiagram
  module Gec
    class Dsl
      attr_reader :clusters, :externals
      attr_accessor :style

      def initialize(style)
        @clusters= []
        @externals= []
        @style= style
      end

      def gec3(name,options={})
        gec name, options.merge(label: "#{name} (GEC3)", types: single, roles: single)
      end

      def gec6(name,options={})
        gec name, options.merge(label: "#{name} (GEC6)", types: multiple, roles: multiple)
      end

      def gec(name,options={})
        options.assert_valid_keys :label, :type, :types, :role, :roles
        entity= normalise_node_name(name)
        type= normalise_node_name "#{name} Type"
        role= normalise_node_name "#{name} Role"

        lines= []
        disabled= []
        lines<< %|label = "#{options[:label] || name.to_s.pluralize}"|
        lines<< @style.scope(:entity, :node).stylise(entity)

        case options[:types]
        when nil
        when :single
          add options[:type], lines, disabled, %|#{type} -> #{entity}|
        when :multiple
          entity_type= %|"#{name}:Type mappings"|
          add options[:type], lines, disabled, %|#{entity} -> #{entity_type}|
          add options[:type], lines, disabled, %|#{type} -> #{entity_type}|
        end # TODO else

        case options[:roles]
        when nil
        when :single
          tree= %|"#{name}-->#{name}"|
          add options[:role], lines, disabled, %|#{entity} -> #{tree}|, 2
        when :multiple
          entity_role_entity= %|"#{name} --(Role)--> #{name}"|
          type_role_type= %|"#{type.gsub '"',''} --(Role)--> #{type.gsub '"',''}"|
          add options[:role], lines, disabled, %|#{entity} -> #{entity_role_entity}|, 2
          add options[:type], lines, disabled, %|#{type} -> #{type_role_type}|, 2 if options[:types]
          add options[:role], lines, disabled, %|#{role} -> #{type_role_type}|
          add options[:role], lines, disabled, %|#{role} -> #{entity_role_entity}|
        end # TODO else


        unless disabled.empty?
          lines<< @style.scope(:disabled).to_gv
          lines.concat disabled
        end

        @clusters<< lines.map{|l| l.sub /;?\Z/,';'}.join("\n")
      end

      def extn(entity_a, entity_b, options={})
        options.assert_valid_keys :name
        name= options[:name] || "#{entity_a} #{entity_b.to_s.pluralize}"
        name= normalise_node_name(name)
        entity_a= normalise_node_name(entity_a)
        entity_b= normalise_node_name(entity_b)

        @externals<< %|#{entity_a} -> #{name}|
        @externals<< %|#{entity_b} -> #{name}|
      end

      def map(mappings)
        mappings.each do |from,to|
          if from.is_a?(Array)
            from.each {|src| map src => to}
          elsif to.is_a?(Array)
            to.each {|dest| map from => dest}
          else
            @externals<< %|#{normalise_node_name from} -> #{normalise_node_name to}|
          end
        end
        self
      end

      %w[disabled single multiple].each do |s|
        class_eval "def #{s}; :#{s} end"
      end

      private
        def add(option, normal, disabled, value, times=1)
          case option
          when nil then normal
          when :disabled then disabled
          else raise "Unsupported value #{option.inspect}. Only :disabled is supported."
          end.concat([value] * times)
        end

        def normalise_node_name(name)
          name= name.to_s
            .gsub("\n",'\n')
            .gsub('"','')
          %|"#{name}"|
        end

    end # class
  end
end
