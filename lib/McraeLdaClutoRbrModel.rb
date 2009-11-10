require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLdaClutoRbrModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lda"
    
    init_cluster("mcrae.rbr.predicted.yaml")
  end
end
