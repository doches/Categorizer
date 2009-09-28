require 'lib/categorymodel'
require 'lib/concept'
require 'lib/ldasim'

class ConceptModel < CategoryModel
  attr_reader :words
  
  def initialize(label)
    throw "Concept models must be initialized with a category label!" if not label.is_a? String
    @word = label
    LDASimilarity.setup("moose",9999)

    @concept = Concept.new(LDASimilarity.model.vector(label))
  end
  
  def similarity(word)
    word_concept = Concept.new(LDASimilarity.model.vector(word))
    Concept.degree(word_concept,@concept)
  end
end
