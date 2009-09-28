require 'lib/LdaModel'
require 'lib/Cluster'

class LdaClutoGraphModel < LdaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lda2.graph.predicted.centroid.yaml")
  end
end
