require 'lib/categorymodel'
require 'lib/ldasim'

class ExemplarLDAModel < CategoryModel
  attr_reader :words

  def initialize(words,server,port=9999)
    throw "Exemplar models must be initialized with an Array of words!" if not words.is_a? Array
    
    @words = words
    LDASimilarity.setup(server,port)
  end
  
  def add_exemplar(word)
    @words.push word
  end
  
  def similarity(word)
    sim = 0
    @words.each do |exemplar|
      sim += LDASimilarity.sim(exemplar,word)
    end
    sim
  end
end
