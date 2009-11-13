require 'lib/Model'
require 'lib/ClusterCosine'

class McraeDepspaceClutoGraphModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/depspace"
    
    init_cluster("mcrae.graph.predicted.yaml")
  end
end
