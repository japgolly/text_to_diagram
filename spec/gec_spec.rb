require 'spec_helper'
require 'gec'

disabledness= TextToDiagram::Style.default.scope(:gec, :disabled).to_gv

describe TextToDiagram::Gec::Grapher do
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

    it "should disable the Tree node on request" do
      gec.parse %|gec3 'User', tree: disabled|
      gec.generate_gv.should be_same_graph_as(%|
        subgraph cluster0 {
          label = "User (GEC3)";
          "User";
          "User Type" -> "User";
          #{disabledness}
          "User" -> "User->User";
          "User" -> "User->User";
        }|)
    end

    it "should disable the Type and Tree nodes on request" do
      gec.parse %|gec3 'User', tree: disabled, type: disabled|
      gec.generate_gv.should be_same_graph_as(%|
        subgraph cluster0 {
          label = "User (GEC3)";
          "User";
          #{disabledness}
          "User Type" -> "User";
          "User" -> "User->User";
          "User" -> "User->User";
        }|)
    end

  end
end
