#!/usr/bin/env ruby

unless ARGV.length == 1
  puts "Usage: #{File.basename __FILE__} <ERD file>"
  exit 1
end

def change_ext(filename,ext)
  #filename= filename.sub(/\.[^.]*$/,'') unless filename.end_with?(".#{ext}")
  "#{filename}.#{ext}"
end
def to_label(str)
  str.gsub('\n',"\n").inspect.gsub(/ ([^\r\n]{4,})(?! )/,'\\n\1')
end
entities= {}
relations= []

# Read data
src_file= ARGV[0]
src_rows= File.read(src_file).split(/[\r\n]+/).reject{|l| l =~ /^\s*(#.*)?$/}
ei= 0
src_rows.each do |l|
  raise "Incorrect format: #{l.inspect}" unless l =~ /^\s*(.+?)\s*<\s*(.+?)\s* ([^>]+)\s* (.+?)\s*>\s*(.+?)\s*$/
  e1,r1,r,r2,e2 = $1,$2,$3,$4,$5
  e1,e2 = [e1,e2].map{|e| entities[e]||= "e#{ei+=1}"}
  relations<< {name: r, e1: e1, e2: e2, r1: r1, r2: r2}
end
puts "Read #{src_rows.size} lines from #{src_file}"
puts "  #{entities.size} entities."
puts "  #{relations.size} relationships."

# Create graph
entity_data= entities.map{|k,v| %!#{v} [label=#{to_label k}];!}
ri=0
relation_data= relations.map do |r|
  id= "r#{ri+=1}"
  %!
    #{id} [label=#{to_label r[:name]}];
    #{r[:e1]} -> #{id} [label=#{to_label r[:r1]}];
    #{id} -> #{r[:e2]} [label=#{to_label r[:r2]}];
  !.strip.gsub(/\s*\n+\s*/, ' ')
end
graph= <<-EOB
digraph ERD {
  node [style=filled];

  // Entities
  node [shape=box, color="#1117A8", fontcolor="#1117A8", fillcolor="#96CAFE"];
#{entity_data.map{|l| "  #{l}"}.join "\n"}

  // Relations
  node [shape=diamond, color="#FEBB51", fontcolor="#333333", fillcolor="#FEFE82"];
  edge [dir=none];
#{relation_data.map{|l| "  #{l}"}.join "\n"}
}
EOB

# Save graphviz file
gv_file= change_ext(src_file,'gv')
puts "Creating graph src: #{gv_file}"
File.write gv_file, graph

# Create graph
graph_format= "png"
graph_file= change_ext(src_file,graph_format)
puts "Creating graph: #{graph_file}"
system "dot -T#{graph_format} -o#{graph_file.inspect} #{gv_file.inspect}"

# Done
puts "Done."
