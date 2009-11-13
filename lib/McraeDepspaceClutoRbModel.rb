require 'lib/Model'
require 'lib/ClusterCosine'

class McraeDepspaceClutoRbModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/depspace"
    
    init_cluster("mcrae.rb.predicted.yaml")
  end
end
