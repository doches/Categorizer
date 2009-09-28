require 'lib/LdaModel'
require 'lib/Cluster'

class LdaAutoclassModel < LdaModel
  include Cluster
  
  def initialize
    super
    
    init_cluster("autoclass.yaml")
  end
end
