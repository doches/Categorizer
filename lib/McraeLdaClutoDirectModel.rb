require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLdaClutoDirectModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lda"
    
    init_cluster("mcrae.direct.predicted.yaml")
  end
end
