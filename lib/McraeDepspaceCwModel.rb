require 'lib/Model'
require 'lib/ClusterCosine'

class McraeDepspaceCwModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/depspace"
    
    init_cluster("cw-mcrae.predicted.yaml")
  end
end
