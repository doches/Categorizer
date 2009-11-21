require 'lib/Model'
require 'lib/BaselineCosine'

class McraeDepspaceBaselineModel < Model
  include BaselineCosine
  
  def initialize
    super
    @datapath = "data/depspace"
    
    init_baseline
  end
end
