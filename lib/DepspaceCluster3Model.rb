require 'lib/DepspaceModel'
require 'lib/Cluster'

class DepspaceCluster3Model < DepspaceModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("cluster3.yaml")
  end
end
