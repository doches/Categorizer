require 'lib/LsaModel'
require 'lib/Cluster'

class LsaClutoBaggloModel < LsaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lsa2.bagglo.predicted.centroid.yaml")
  end
end
