require 'lib/Model'
require 'lib/BaselineCosine'

class LdaBaselineCosineModel < Model
  include BaselineCosine
  
  def initialize
    super
    @datapath = "data/lda"
    
    init_baseline
  end
end
