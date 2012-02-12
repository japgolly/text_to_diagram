require 'active_support/core_ext'
require 'active_support/inflector'

module TextToDiagram
  module Gec
    class Dsl
      attr_reader :clusters, :externals

      def initialize(style)
        @clusters= []
        @externals= []
        @style= style
      end

      def gec3(name,options={})
        options.assert_valid_keys :type, :tree
        entity= %|"#{name}"|
        type= %|"#{name} Type"|
        tree= %|"#{name}->#{name}"|

        lines= []
        disabled= []
        lines<< %|label = "#{name} (GEC3)"|
        lines<< entity
        add options[:type], lines, disabled, %|#{type} -> #{entity}|
        add options[:tree], lines, disabled, %|#{entity} -> #{tree}|, 2

        unless disabled.empty?
          lines<< @style.scope(:disabled).to_gv
          lines.concat disabled
        end

        @clusters<< lines.map{|l| l.sub /;?\Z/,';'}.join("\n")
      end

      def gec6(name,options={})
        options.assert_valid_keys :type, :role
        entity= %|"#{name}"|
        type= %|"#{name} Type"|
        role= %|"#{name} Role"|
        type_role_type= %|"#{type.gsub '"',''} --(Role)--> #{type.gsub '"',''}"|
        entity_role_entity= %|"#{name} --(Role)--> #{name}"|
        entity_type= %|"#{name}:Type mappings"|

        lines= []
        disabled= []
        lines<< %|label = "#{name} (GEC6)"|
        lines<< entity
        add options[:type], lines, disabled, %|#{type} -> #{type_role_type}|, 2
        add options[:type], lines, disabled, %|#{type} -> #{entity_type}|
        add options[:type], lines, disabled, %|#{entity} -> #{entity_type}|
        add options[:role], lines, disabled, %|#{entity} -> #{entity_role_entity}|, 2
        add options[:role], lines, disabled, %|#{role} -> #{entity_role_entity}|
        add options[:role], lines, disabled, %|#{role} -> #{type_role_type}|

        unless disabled.empty?
          lines<< @style.scope(:disabled).to_gv
          lines.concat disabled
        end

        @clusters<< lines.map{|l| l.sub /;?\Z/,';'}.join("\n")
      end

      def extn(entity_a, entity_b, options={})
        options.assert_valid_keys :name
        name= options[:name] || "#{entity_a} #{entity_b.to_s.pluralize}"
        name= %|"#{name}"|
        entity_a= %|"#{entity_a}"|
        entity_b= %|"#{entity_b}"|

        @externals<< %|#{entity_a} -> #{name}|
        @externals<< %|#{entity_b} -> #{name}|
      end

      def disabled; :disabled end

      private
        def add(option, normal, disabled, value, times=1)
          case option
          when nil then normal
          when :disabled then disabled
          else raise "Unsupported value #{option.inspect}. Only :disabled is supported."
          end.concat([value] * times)
        end

    end # class
  end
end
