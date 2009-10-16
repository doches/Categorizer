require 'lib/Model'
require 'legacy/depspace'
#require 'remotehash'

class DepspaceModel < Model
  def initialize
    super
    
    @datapath = "data/depspace/"
    @legacy_model = DependencySpace.new(@datapath + "wide_length.vectors",true)
    #@model = RemoteHash.new("mcfadden",9998)
  end
  
  def vector(word)
    return @legacy_model.vector(word)
    #return @model[word]
  end
end
