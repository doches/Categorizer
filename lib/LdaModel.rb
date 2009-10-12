require 'lib/Model'
require 'legacy/lda'
require 'legacy/lda_server'

# Wraps a legacy LDA model in a common interface.
class LdaModel < Model
  # The default server to use (currently "bunnocks").
  Server = "bunnocks"
  # The default model path to use (currently model_lda_bnc on DICE).
  ModelPath = "/home/s0897549/model_lda_bnc/"
  # The default model name to use (currently "model-final")
  ModelName = "model-final"

  # Load an LDA model. If +source+ is an existing directory it will load
  # a Phi model, which loads the LDA space into memory; otherwise, +source+
  # is assumed to be the hostname of a machine on which a Phi server is already 
  # running, and it loads an RPC version of the space which queries this server for vectors.
  # +name+ is only used in the former case, when loading a space directly.
  #
  # Using a remote server introduces some network latency, as well as (if too many
  # clients are using the same server) extra lookup time. However, loading the
  # LDA space into memory takes an inordinate amount of time, so you may save time loading 
  # once into a remote server and taking the hit with regard to network latency. YMMV.
  def initialize(source=Server,name=ModelName)
    super()
    
    @datapath = "data/lda/"
    @legacy_model = nil
    if File.exist?(source)
      @legacy_model = Phi.new(ModelPath,name)
    else
      @legacy_model = LDA.new(source,9999)
    end
  end
  
  # Get the LDA-space vector (using topics as dimensions) for this word.
  def vector(word)
    return @legacy_model.vector(word)
  end
end
