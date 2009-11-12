# Generates a pretty two-axis plot comparing typicality rating and category naming.

require 'lib/Graph'

input = {
  "McraeDepspaceClutoRb" => "Top-Down",
  "McraeDepspaceClutoAgglo" => "Bottom-Up",
  "McraeDepspaceClutoGraph" => "Graph",
  "DepspaceBaselineCosine" => "Baseline",
#  "LsaBaselineCosine" => "LSA",
#  "LdaBaselineCosine" => "LDA",
#  "DepspaceBaselineCosine" => "Depspace"
}

output = "McraeDepspaceCluto"

graph = Graph::CombinedPlot.new(output,input)
graph.render
`evince reports/#{output}.pdf` if ARGV.include?("--view") or ARGV.include?("-v")
