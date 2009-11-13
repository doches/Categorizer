require 'lib/Model'
require 'lib/ClusterCosine'

class McraeMcraeClutoAggloModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/mcrae"
    
    init_cluster("mcrae.agglo.predicted.yaml")
  end
end
