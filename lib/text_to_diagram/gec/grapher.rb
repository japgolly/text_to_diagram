require 'text_to_diagram/gec/dsl'
require 'text_to_diagram/style'
require 'text_to_diagram/helpers'

module TextToDiagram::Gec
  class Grapher
    attr_reader :style

    def initialize
      reset!
    end

    def reset!
      @style= TextToDiagram::Style.default.scope(:gec)
      @dsl= Dsl.new(@style)
      self
    end

    def style=(style)
      @style= style[:gec] ? style.scope(:gec) : style
      @dsl.style= @style
    end

    def parse(text)
      @dsl.instance_eval(text)
      self
    end

    def generate_gv
      # Generate clusters
      i= -1
      cluster_gv= @dsl.clusters.map do |c|
        "subgraph cluster#{i+=1} {\n#{c.indent 2}\n}"
      end.join("\n\n")

      # Generate externals
      external_gv= @dsl.externals.map{|l| l+';'}.join("\n")

      # Generate complete graph
%|digraph G {
#{@style.scope(:normal).to_gv.indent 2}

#{cluster_gv.indent 2}

#{@style.scope(:external).to_gv.indent 2}
#{external_gv.indent 2}
}|
    end

  end
end
