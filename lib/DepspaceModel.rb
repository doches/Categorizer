require 'lib/Model'
require 'legacy/depspace'

class DepspaceModel < Model
  def initialize
    super
    
    @datapath = "data/depspace/"
    @legacy_model = DependencySpace.new(@datapath + "wide_length.vectors",true)
  end
  
  def vector(word)
    return @legacy_model.vector(word)
  end
end
