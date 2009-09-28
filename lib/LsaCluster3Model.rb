require 'lib/LsaModel'
require 'lib/Cluster'

class LsaCluster3Model < LsaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("cluster3.yaml")
  end
end
