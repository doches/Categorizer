require 'lib/LsaModel'
require 'lib/Cluster'

class LsaCwModel < LsaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lsa.cw.yaml")
  end
end
