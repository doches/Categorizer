require 'lib/LsaModel'
require 'lib/Cluster'

class LsaAutoclassModel < LsaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("autoclass.yaml")
  end
end
