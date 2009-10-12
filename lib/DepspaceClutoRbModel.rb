require 'lib/DepspaceModel'
require 'lib/Cluster'

class DepspaceClutoRbModel < DepspaceModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("rb.predicted.yaml")
  end
end
