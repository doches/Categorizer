require 'lib/DepspaceModel'
require 'lib/Cluster'

class DepspaceClutoRbrModel < DepspaceModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("rbr.predicted.yaml")
  end
end
