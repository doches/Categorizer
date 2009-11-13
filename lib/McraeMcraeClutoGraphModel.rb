require 'lib/Model'
require 'lib/ClusterCosine'

class McraeMcraeClutoGraphModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/mcrae"
    
    init_cluster("mcrae.graph.predicted.yaml")
  end
end
