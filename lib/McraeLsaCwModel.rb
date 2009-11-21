require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLsaCwModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lsa"
    
    init_cluster("cw-mcrae.predicted.yaml")
  end
end
