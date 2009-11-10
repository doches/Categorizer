require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLdaClutoRbModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lda"
    
    init_cluster("mcrae.rb.predicted.yaml")
  end
end
