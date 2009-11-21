require 'lib/Model'
require 'lib/ClusterCosine'

class McraeDepspaceClutoDirectModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/depspace"
    
    init_cluster("mcrae.direct.predicted.yaml")
  end
end
