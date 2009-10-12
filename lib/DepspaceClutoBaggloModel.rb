require 'lib/DepspaceModel'
require 'lib/Cluster'

class DepspaceClutoBaggloModel < DepspaceModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("bagglo.predicted.yaml")
  end
end
