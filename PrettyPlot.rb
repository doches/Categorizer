# Generates a pretty two-axis plot comparing typicality rating and category naming.

require 'lib/Graph'

input = {
#  "McraeLsaClutoRb" => "Top-Down",
#  "McraeLsaClutoAgglo" => "Bottom-Up",
#  "McraeLsaClutoGraph" => "Graph",
  "McraeBaselineCosine" => "McRae",
  "LsaBaselineCosine" => "LSA",
  "LdaBaselineCosine" => "LDA",
  "DepspaceBaselineCosine" => "Depspace"
}

graph = Graph::CombinedPlot.new("McraeBaseline",input)
graph.render
