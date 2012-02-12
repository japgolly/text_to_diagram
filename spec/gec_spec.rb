require 'rubygems'
require 'rspec'
$:<< File.expand_path('../../lib',__FILE__)
require 'gec'

def normalise_gv(x)
  x.split(/[\r\n]+/).map do |l|
    l.gsub(/^\s+|\s+$/,'')
  end.join("\n")
    .gsub(/\n{2,}/,"\n")
    .gsub(/\A\n+|\n+\Z/,'')
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

def wrap_graph(inner_graph)
  %|digraph G {
    style="rounded,filled"; color=black; fillcolor=lightgrey;
    node [color=black,fillcolor=white,shape=box,style="rounded,filled"];
    edge [arrowhead=dot];
    #{inner_graph}
  }|
end

disabledness= 'node[fillcolor=lightgrey,fontcolor="#aaaaaa",color="#aaaaaa"]; edge[color="#aaaaaa"];'


describe TextToDiagram::GecGrapher do
  let(:gec) {described_class.new}

  context "when generating a 3-node GEC" do

    it "should generate it all by default" do
      gec.parse %|gec3 'User'|
      gec.generate_gv.should be_same_graph_as(%|
        subgraph cluster0 {
          label = "User (GEC3)";
          "User";
          "User Type" -> "User";
          "User" -> "User->User";
          "User" -> "User->User";
        }|)
    end

    it "should disable the Type node on request" do
      gec.parse %|gec3 'User', type: disabled|
      gec.generate_gv.should be_same_graph_as(%|
        subgraph cluster0 {
          label = "User (GEC3)";
          "User";
          "User" -> "User->User";
          "User" -> "User->User";
          #{disabledness}
          "User Type" -> "User";
        }|)
    end
  end
end
