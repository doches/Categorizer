require 'lib/Model'
require 'lib/ClusterCosine'

class McraeMcraeClutoDirectModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/mcrae"
    
    init_cluster("mcrae.direct.predicted.yaml")
  end
end
