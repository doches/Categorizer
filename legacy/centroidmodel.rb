require 'lib/categorymodel'
require 'lib/infomapsim'

class CentroidModel < CategoryModel
  attr_reader :words

  def initialize(words)
    throw "Centroid models must be initialized with an Array of words!" if not words.is_a? Array
    
    @words = words
    InfomapSimilarity.setup("bnc_az","/afs/inf.ed.ac.uk/user/s08/s0897549/vector/data_work")
    update_centroid
  end
  
  def add_exemplar(word)
    @words.push word
  end
  
  def update_centroid
    @centroid = @words.map { |word| InfomapSimilarity.model.vector(word) }
    base = @centroid.shift
    @centroid.each { |vector| base.each_with_index { |v,i| base[i] = v + vector[i] } }
    @centroid = base
  end
  
  def similarity(word)
    return InfomapSimilarity.model.sim_to_vector(word,@centroid)
  end
end
