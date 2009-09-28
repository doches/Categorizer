require 'lib/Model'
require 'legacy/lda'
require 'legacy/lda_server'

class LdaModel < Model
  def initialize
    super
    
    @datapath = "data/lda/"
    @legacy_model = Phi.new("/home/s0897549/model_lda_bnc/","model-final")
    #@legacy_model = LDA.new("bunnocks",9999)
    
  end
  
  def vector(word)
    return @legacy_model.vector(word)
  end
end
