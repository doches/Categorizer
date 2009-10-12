require 'lib/DepspaceModel'
require 'lib/Baseline'

class DepspaceBaselineModel < DepspaceModel
  include Baseline
  
  def initialize
    super
    
    init_baseline
  end
end
