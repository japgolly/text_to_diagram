module TextToDiagram
  class GecGrapher
    def initialize
      reset!
    end

    def reset!
      @dsl= GecDsl.new
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

  class GecDsl
    attr_reader :clusters

    def initialize
      @clusters= []
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
        lines<< 'node[fillcolor=lightgrey,fontcolor="#aaaaaa",color="#aaaaaa"]; edge[color="#aaaaaa"]'
        lines.concat disabled
      end

      @clusters<< lines.map{|l| "#{l};"}.join("\n")
    end

    def disabled; :disabled end
  end
end
