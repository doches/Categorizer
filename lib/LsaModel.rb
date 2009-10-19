require 'lib/Model'
require 'legacy/infomap'

# Wraps the legacy InfoMap model in a common interface.
class LsaModel < Model
  # The default path for loading the InfoMap model. Currently +data/lsa+ on DICE.
  ModelPath = "data/lsa/"
  # The default model to load, currently "bnc_az"
  ModelName = "bnc_az"
  
  # Create an InfoMap-backed Model, loading from the 
  # model named +name+ in +path+. Defaults to the DICE
  # location where my LSA model is stored.
  def initialize(path=ModelPath,name=ModelName)
    super()
    
    @datapath = path
    @legacy_model = InfoMap.new(name,@datapath)
  end
  
  # Get the LSA representation for a word.
  def vector(word)
    return @legacy_model.vector(word)
  end
end
