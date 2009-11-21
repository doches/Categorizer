require 'lib/Model'
require 'lib/BaselineCosine'

class McraeLdaBaselineModel < Model
  include BaselineCosine
  
  def initialize
    super
    @datapath = "data/lda"
    
    init_baseline
  end
end
