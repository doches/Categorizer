require 'lib/Model'
require 'lib/Joel'

class JoelModel < Model
  ModelPath = "/disk/scratch/joelspace/mcrae/"
  
  def initialize(path=ModelPath)
    super()
    
    @datapath = path
    @model = JoelSpace.new(path)
  end
  
  def vector(word)
    return @model[word]
  end
end
