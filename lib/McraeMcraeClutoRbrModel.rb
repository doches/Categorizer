require 'lib/Model'
require 'lib/ClusterCosine'

class McraeMcraeClutoRbrModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/mcrae"
    
    init_cluster("mcrae.rbr.predicted.yaml")
  end
end
