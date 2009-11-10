require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLdaClutoAggloModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lda"
    
    init_cluster("mcrae.agglo.predicted.yaml")
  end
end
