require 'spec_helper'
require 'text_to_diagram/style'

describe TextToDiagram::Style do
  #it(:style) {described_class.new}

  context "given a bunch of mock style data," do
    subject {
      style= described_class.new
      style.style= {gec: {
        norm: {cluster: {style: 'abc,def', color: 'black'}, node: {color: '#123456', a: 1, b: 2}},
        'diff' => {node: {a: 3, b: 4}, edge: {color: "#876234"}}
      }}
      style
    }

    context "when accessing styles via []," do
      it "should return nil when keys point to something that doesn't exist" do
        subject[:non_existant, :a].should be_nil
      end

      it "should return the values that they key points to" do
        subject[:gec, 'diff', :node].should == {a: 3, b: 4}.with_indifferent_access
      end

      it "should ignore the key type and only use key value" do
        subject['gec', :diff, :node].should == {a: 3, b: 4}.with_indifferent_access
      end
    end

    it "should return a scoped version of itself" do
      scoped= subject.scope(:gec, :norm, :cluster)
      scoped.should be_a_kind_of(described_class)
      scoped.style.should == {style: 'abc,def', color: 'black'}.with_indifferent_access
    end
  end

  it "should convert into gv correctly" do
    style= described_class.new
    style.style= {style: "rounded,filled", color: 'black', node: {color: 'red', shape: 'box'}}
    style.to_gv.should == %|style = "rounded,filled";\ncolor = black;\nnode [color=red, shape=box];|
  end

end
