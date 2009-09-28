require 'lib/categorymodel'
require 'lib/infomapsim'
require 'lib/concept'

class ConceptModel < CategoryModel
  attr_reader :words,:concept
  
  def initialize(words)
    throw "Concept models must be initialized with a category label!" if not words.is_a? String
  
    @label = words
    InfomapSimilarity.setup("bnc_az","/afs/inf.ed.ac.uk/user/s08/s0897549/vector/data_work")
    @concept = Concept.new(InfomapSimilarity.model.vector(@label))
  end
  
  def similarity(word)
    word_concept = Concept.new(InfomapSimilarity.model.vector(word))
    Concept.degree(word_concept,@concept)
  end
end
