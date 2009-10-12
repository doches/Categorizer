require 'lib/DepspaceModel'
require 'lib/Cluster'

class DepspaceClutoAggloModel < DepspaceModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("agglo.predicted.yaml")
  end
end
