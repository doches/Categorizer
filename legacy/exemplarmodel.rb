require 'lib/categorymodel'
require 'lib/infomapsim'

class ExemplarModel < CategoryModel
  attr_reader :words

  def initialize(words)
    throw "Exemplar models must be initialized with an Array of words!" if not words.is_a? Array
    
    @words = words
    InfomapSimilarity.setup("bnc_az","/afs/inf.ed.ac.uk/user/s08/s0897549/vector/data_work")
  end
  
  def add_exemplar(word)
    @words.push word
  end
  
  def similarity(word)
    sim = 0
    @words.each do |exemplar|
      sim += InfomapSimilarity.sim(exemplar,word)
    end
    sim
  end
end
