require 'spec_helper'
require 'text_to_diagram/gec'

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
          "User" -> "User-->User";
          "User" -> "User-->User";
        }|)
    end

    it "should disable the Type node on request" do
      gec.parse %|gec3 'User', type: disabled|
      gec.generate_gv.should be_same_graph_as(%|
        subgraph cluster0 {
          label = "User (GEC3)";
          "User";
          "User" -> "User-->User";
          "User" -> "User-->User";
          #{disabledness}
          "User Type" -> "User";
        }|)
    end

    it "should disable the Tree node on request" do
      gec.parse %|gec3 'User', role: disabled|
      gec.generate_gv.should be_same_graph_as(%|
        subgraph cluster0 {
          label = "User (GEC3)";
          "User";
          "User Type" -> "User";
          #{disabledness}
          "User" -> "User-->User";
          "User" -> "User-->User";
        }|)
    end

    it "should disable the Type and Tree nodes on request" do
      gec.parse %|gec3 'User', role: disabled, type: disabled|
      gec.generate_gv.should be_same_graph_as(%|
        subgraph cluster0 {
          label = "User (GEC3)";
          "User";
          #{disabledness}
          "User Type" -> "User";
          "User" -> "User-->User";
          "User" -> "User-->User";
        }|)
    end

  end # context

  context "when generating a 6-node GEC" do

    it "should generate it all by default" do
      gec.parse %|gec6 'Contact'|
      gec.generate_gv.should be_same_graph_as(%|
        subgraph cluster0 {
          label = "Contact (GEC6)";
          "Contact";
          "Contact" -> "Contact:Type mappings";
          "Contact Type" -> "Contact:Type mappings";
          "Contact" -> "Contact --(Role)--> Contact";
          "Contact" -> "Contact --(Role)--> Contact";
          "Contact Type" -> "Contact Type --(Role)--> Contact Type";
          "Contact Type" -> "Contact Type --(Role)--> Contact Type";
          "Contact Role" -> "Contact Type --(Role)--> Contact Type";
          "Contact Role" -> "Contact --(Role)--> Contact";
        }|)
    end

  end # context

  context "when generating externals" do

    it "should connection a pair of GEC3s correctly" do
      gec.parse %|gec3 'User'\n gec3 :Book\n extn :User, :Book|
      gec.generate_gv.should be_same_graph_as(%|
        subgraph cluster0 {
          label = "User (GEC3)";
          "User";
          "User Type" -> "User";
          "User" -> "User-->User";
          "User" -> "User-->User";
        }
        subgraph cluster1 {
          label = "Book (GEC3)";
          "Book";
          "Book Type" -> "Book";
          "Book" -> "Book-->Book";
          "Book" -> "Book-->Book";
        }
        "User" -> "User Books";
        "Book" -> "User Books";
      |)
    end

  end # context
end
