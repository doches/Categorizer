require 'lib/DepspaceModel'
require 'lib/Cluster'

class DepspaceClutoGraphModel < DepspaceModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("graph.predicted.yaml")
  end
end
