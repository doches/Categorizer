require 'lib/LsaModel'
require 'lib/Cluster'

class LsaClutoAggloModel < LsaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lsa2.agglo.predicted.centroid.yaml")
  end
end
