require 'lib/LdaModel'
require 'lib/Cluster'

class LdaClutoAggloModel < LdaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lda2.agglo.predicted.centroid.yaml")
  end
end
