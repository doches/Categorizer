require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLdaClutoGraphModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lda"
    
    init_cluster("mcrae.graph.predicted.yaml")
  end
end
