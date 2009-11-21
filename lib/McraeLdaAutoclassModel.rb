require 'lib/Model'
require 'lib/ClusterCosine'

class McraeLdaAutoclassModel < Model
  include ClusterCosine
  
  def initialize
    super
    @datapath = "data/lda"
    
    init_cluster("mcrae_autoclass.yaml")
  end
end
