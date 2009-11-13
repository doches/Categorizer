require 'lib/Model'
require 'lib/ClusterCosine'

class McraeDepspaceClutoAggloModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/depspace"
    
    init_cluster("mcrae.agglo.predicted.yaml")
  end
end
