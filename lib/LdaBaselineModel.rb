require 'lib/LdaModel'
require 'lib/Baseline'

class LdaBaselineModel < LdaModel
  include Baseline
  
  def initialize
    super
    
    init_baseline
  end
end
