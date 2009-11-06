require 'lib/Model'
require 'lib/BaselineCosine'

class DepspaceBaselineCosineModel < Model
  include BaselineCosine
  
  def initialize
    super
    @datapath = "data/depspace"
    
    init_baseline
  end
end
