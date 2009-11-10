require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLsaClutoAggloModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lsa"
    
    init_cluster("mcrae.agglo.predicted.yaml")
  end
end
