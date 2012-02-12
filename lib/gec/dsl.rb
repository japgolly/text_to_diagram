module TextToDiagram
  module Gec
    class Dsl
      attr_reader :clusters

      def initialize(style)
        @clusters= []
        @style= style
      end

      def add(options, key, normal, disabled, value)
        case options[key]
        when nil then normal
        when :disabled then disabled
        else raise "Unsupported value #{options[key].inspect} for #{key} option. Only :disabled is supported."
        end << value
      end

      def gec3(name,options={})
        entity= %|"#{name}"|
        type= %|"#{name} Type"|
        tree= %|"#{name}->#{name}"|

        lines= []
        disabled= []
        lines<< %|label = "#{name} (GEC3)"|
        lines<< entity
        add options, :type, lines, disabled, %|#{type} -> #{entity}|
        2.times.each{ add options, :tree, lines, disabled, %|#{entity} -> #{tree}| }

        unless disabled.empty?
          lines<< @style.scope(:disabled).to_gv
          lines.concat disabled
        end

        @clusters<< lines.map{|l| l.sub /;?\Z/,';'}.join("\n")
      end

      def disabled; :disabled end
    end
  end
end
