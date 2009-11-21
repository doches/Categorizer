require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLsaClutoDirectModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lsa"
    
    init_cluster("mcrae.direct.predicted.yaml")
  end
end
