require 'yaml'
require 'active_support/core_ext'

module TextToDiagram
  class Style

    attr_accessor :style

    def initialize(style={})
      @style= style
    end

    def self.default
      Style.new.load_defaults!
    end

    def load_defaults!
      @style= {}
      load_file File.expand_path('../../../config/style.yml',__FILE__)
      self
    end

    def load_file(filename)
      @style.merge! YAML.load_file(filename)
      self
    end

    def [](*keys)
      keys.inject(@style.with_indifferent_access) {|style,key| style= style[key] if style}
    end

    def scope(*keys)
      style= self[*keys] || {}
      Style.new(style)
    end

    def to_gv(multiple_attributes=true)
      if multiple_attributes
        # Generate a bunch of lines
        style.map do |k,v|
          if v.is_a?(Hash)
            values= scope(k).to_gv(false)
            "#{k} [#{values}];"
          else
            "#{k} = #{escape_value v};"
          end
        end.join("\n")
      else
        # Put it all on one line
        style.to_a.map do |inner_key,inner_value|
          "#{inner_key}=#{escape_value inner_value}"
        end.join(', ')
      end
    end

    def stylise(node)
      return node if style.empty?
      "#{node} [#{to_gv false}]"
    end

    private
      def escape_value(v)
        v= v.to_s
        v= %|"#{v}"| unless v =~ /^[a-zA-Z0-9]*$/
        v
      end
  end
end
