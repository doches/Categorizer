require 'lib/Model'
require 'lib/ClusterCosine'

class McraeMcraeClutoRbModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/mcrae"
    
    init_cluster("mcrae.rb.predicted.yaml")
  end
end
