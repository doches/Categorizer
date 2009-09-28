require 'lib/LsaModel'
require 'lib/Cluster'

class LsaClutoRbrModel < LsaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lsa2.rbr.predicted.centroid.yaml")
  end
end
