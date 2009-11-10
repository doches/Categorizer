require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLsaClutoGraphModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lsa"
    
    init_cluster("mcrae.graph.predicted.yaml")
  end
end
