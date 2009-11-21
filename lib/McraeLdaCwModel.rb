require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLdaCwModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lda"
    
    init_cluster("cw-mcrae.predicted.yaml")
  end
end
