require 'lib/infomap'
require 'lib/concept'

class InfomapSimilarity
  def InfomapSimilarity.setup(model,model_dir=nil)
    @@infomap = InfoMap.new(model,model_dir)
  end
  
  def InfomapSimilarity.model
    @@infomap
  end
  
  def InfomapSimilarity.sim(a,b)
    av = @@infomap.vector(a)
    bv = @@infomap.vector(b)
    
    dot_product_e(av,bv)
  end
end
