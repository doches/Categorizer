require 'lib/LdaModel'
require 'lib/Cluster'

class LdaClutoBaggloModel < LdaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lda2.bagglo.predicted.centroid.yaml")
  end
end
