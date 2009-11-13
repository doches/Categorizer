require 'lib/Model'
require 'lib/ClusterCosine'

class McraeDepspaceClutoRbrModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/depspace"
    
    init_cluster("mcrae.rbr.predicted.yaml")
  end
end
