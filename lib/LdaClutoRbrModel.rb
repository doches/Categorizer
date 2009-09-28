require 'lib/LdaModel'
require 'lib/Cluster'

class LdaClutoRbrModel < LdaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lda2.rbr.predicted.centroid.yaml")
  end
end
