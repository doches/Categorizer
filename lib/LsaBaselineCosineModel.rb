require 'lib/Model'
require 'lib/BaselineCosine'

class LsaBaselineCosineModel < Model
  include BaselineCosine
  
  def initialize
    super
    @datapath = "data/lsa"
    
    init_baseline
  end
end
