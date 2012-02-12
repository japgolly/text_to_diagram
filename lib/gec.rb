module TextToDiagram
  class GecGrapher
    def initialize
      reset!
    end

    def reset!
      @clusters= []
    end

    def parse(text)
      instance_eval(text)
      self
    end

    def gec3(name,options={})
      entity= %|"#{name}"|
      type= %|"#{name} Type"|
      tree= %|"#{name}->#{name}"|

      lines= []
      lines<< %|label = "#{name} (GEC3)"|
      lines<< entity
      lines<< %|#{type} -> #{entity}|
      2.times.each{ lines<< %|#{entity} -> #{tree}| }

      @clusters<< lines.map{|l| "#{l};"}.join("\n")
    end

    def generate_gv
      # Generate clusters
      i= -1
      cluster_gv= @clusters.map do |c|
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
