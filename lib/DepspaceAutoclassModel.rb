require 'lib/DepspaceModel'
require 'lib/Cluster'

class DepspaceAutoclassModel < DepspaceModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("autoclass.yaml")
  end
end
