require 'lib/LsaModel'
require 'lib/Cluster'

class LsaClutoRbModel < LsaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lsa2.rb.predicted.centroid.yaml")
  end
end
