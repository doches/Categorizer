require 'lib/LdaModel'
require 'lib/Cluster'

class LdaClutoRbModel < LdaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lda2.rb.predicted.centroid.yaml")
  end
end
