require 'lib/Model'
require 'lib/ClusterCosine'

class McraeMcraeCwModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/mcrae"
    
    init_cluster("cw-mcrae.predicted.yaml")
  end
end
