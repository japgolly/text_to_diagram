require 'text_to_diagram/gec/dsl'
require 'text_to_diagram/style'
require 'text_to_diagram/helpers'

module TextToDiagram::Gec
  class Grapher
    def initialize
      reset!
    end

    def reset!
      @style= TextToDiagram::Style.default.scope(:gec)
      @dsl= Dsl.new(@style)
      self
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

      # Generate complete graph
%|digraph G {
#{@style.scope(:normal).to_gv.indent 2}

#{cluster_gv.indent 2}
}|
    end

  end
end
