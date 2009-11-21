require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLsaAutoclassModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lsa"
    
    init_cluster("mcrae_autoclass.yaml")
  end
end
