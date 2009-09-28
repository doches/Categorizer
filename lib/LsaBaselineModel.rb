require 'lib/LsaModel'
require 'lib/Baseline'

class LsaBaselineModel < LsaModel
  include Baseline
  
  def initialize
    super
    
    init_baseline
  end
end
