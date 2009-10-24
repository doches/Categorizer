require 'lib/Model'
require 'legacy/depspace'
require 'remotehash'

class DepspaceModel < Model
  def initialize
    super
    
    @datapath = "data/depspace/"
    @model = nil
    #@legacy_model = DependencySpace.new(@datapath + "wide_length.vectors",true)
    @model = RemoteHash.new("mcfadden",9998)
  end
  
  def vector(word)
    #return @legacy_model.vector(word)
    str = @model[word]
    begin
      return str.split(" ").map { |x| x.to_f }
    rescue # BAD IDEA!
      return [0]
    end
  end
  
  # Close out RemoteHash, if using it.
  def finish
    @model.release if not @model.nil? and @model.is_a?(RemoteHash)
  end
end
