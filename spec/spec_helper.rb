Bundler.require :test
#$:<< File.expand_path('../../lib',__FILE__)

module TextToDiagram
  module SpecHelpers

    def normalise_gv(x)
      x.split(/[\r\n]+/).map do |l|
        l.gsub(/^\s+|\s+$/,'')
      end.join("\n")
        .gsub(/\n{2,}/,"\n")
        .gsub(/\A\n+|\n+\Z/,'')
    end

    def wrap_graph(inner_graph)
      %|digraph G {
        style="rounded,filled"; color=black; fillcolor=lightgrey;
        node [color=black,fillcolor=white,shape=box,style="rounded,filled"];
        edge [arrowhead=dot];
        #{inner_graph}
      }|
    end

  end
end

RSpec.configure do |c|
  c.include TextToDiagram::SpecHelpers
end

RSpec::Matchers.define :be_same_graph_as do |graph|
  match do |actual|
    actual= normalise_gv(actual)
    graph= wrap_graph(graph) unless graph['digraph']
    graph= normalise_gv(graph)
    puts "#{'='*80}\n#{actual}\n#{'='*80}" unless actual == graph
    actual == graph
  end
end

