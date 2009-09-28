require 'lib/categorymodel'
require 'lib/infomapsim'

class PrototypeModel < CategoryModel
  def initialize(word)
    super
    
    InfomapSimilarity.setup("bnc_az","/afs/inf.ed.ac.uk/user/s08/s0897549/vector/data_work")
  end
  
  def similarity(word)
    InfomapSimilarity.sim(@word,word)
  end
end
