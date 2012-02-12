require 'gec/gec_dsl'

module TextToDiagram::Gec
  class Grapher
    def initialize
      reset!
    end

    def reset!
      @dsl= Dsl.new
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
        "subgraph cluster#{i+=1} {\n#{c}\n}"
      end.join("\n\n")

      # Generate complete graph
%|digraph G {
style="rounded,filled"; color=black; fillcolor=lightgrey;
node [color=black,fillcolor=white,shape=box,style="rounded,filled"];
edge [arrowhead=dot];

#{cluster_gv}
}|
    end

  end
end
