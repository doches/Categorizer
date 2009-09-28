require 'lib/Model'
require 'legacy/infomap'

class LsaModel < Model
  def initialize
    super
    
    @datapath = "data/lsa/"
    @legacy_model = InfoMap.new("bnc_az",@datapath)
  end
  
  def vector(word)
    return @legacy_model.vector(word)
  end
end
