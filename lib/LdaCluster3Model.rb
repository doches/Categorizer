require 'lib/LdaModel'
require 'lib/Cluster'

class LdaCluster3Model < LdaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("cluster3.yaml")
  end
end
