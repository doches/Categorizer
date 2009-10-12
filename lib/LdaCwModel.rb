require 'lib/LdaModel'
require 'lib/Cluster'

class LdaCwModel < LdaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("lda.cw.yaml")
  end
end
