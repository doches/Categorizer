require 'lib/Model'
require 'lib/BaselineCosine'

class McraeBaselineCosineModel < Model
  include BaselineCosine
  
  def initialize
    super
    @datapath = "data/mcrae"
    
    init_baseline
  end
end
