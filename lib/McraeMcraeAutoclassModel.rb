require 'lib/Model'
require 'lib/ClusterCosine'

class McraeMcraeAutoclassModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/mcrae"
    
    init_cluster("mcrae_autoclass.yaml")
  end
end
