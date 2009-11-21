require 'lib/Model'
require 'lib/BaselineCosine'

class McraeLsaBaselineModel < Model
  include BaselineCosine
  
  def initialize
    super
    @datapath = "data/lsa"
    
    init_baseline
  end
end
