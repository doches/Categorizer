require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLsaClutoRbModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lsa"
    
    init_cluster("mcrae.rb.predicted.yaml")
  end
end
