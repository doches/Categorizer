# Generates a pretty two-axis plot comparing typicality rating and category naming.

require 'lib/Graph'

model = ARGV[0].capitalize

input = {
  "McraeDepspace#{model}" => "Depspace",
  "McraeLsa#{model}" => "LSA",
  "McraeLda#{model}" => "LDA",
  "McraeMcrae#{model}" => "Mcrae",
#  "LsaBaselineCosine" => "LSA",
#  "LdaBaselineCosine" => "LDA",
#  "DepspaceBaselineCosine" => "Depspace"
}

output = "Mcrae#{model}"

graph = Graph::CombinedPlot.new(output,input)
graph.render
`evince reports/#{output}.pdf` if ARGV.include?("--view") or ARGV.include?("-v")
