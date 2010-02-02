require 'lib/LsaModel'
require 'lib/Cluster'

class LsaClutoGraphModel < LsaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lsa2.graph.predicted.centroid.yaml")
  end
end
