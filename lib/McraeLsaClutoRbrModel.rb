require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLsaClutoRbrModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lsa"
    
    init_cluster("mcrae.rbr.predicted.yaml")
  end
end
