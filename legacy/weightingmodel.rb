require 'lib/categorymodel'
require 'lib/infomapsim'
require 'lib/concept'

class ConceptModel < CategoryModel
  attr_reader :words
  
  def initialize(words)
    throw "Concept models must be initialized with a category label and a list of words!" if not (words.is_a? Array and words[0].is_a? String and words[1].is_a? Array)
  
    @label = words[0]
    @words = words[1]
    InfomapSimilarity.setup("bnc_az","/afs/inf.ed.ac.uk/user/s08/s0897549/vector/data_work")
    @category = Concept.new(InfomapSimilarity.model.vector(@label))
    @exemplars = @words.map { |x| [Concept.dominate(@category,Concept.new(InfomapSimilarity.model.vector(x))),x] }
  end
  
  def similarity(word)
    word_concept = Concept.new(InfomapSimilarity.model.vector(word))
    sum = 0
    @exemplars.each do |x|
      x,x_word = *x
      vector = [x,word_concept]
      sim = dot_product_e(*vector)/(vector.map { |x| x.size }.inject(0) { |sum,c| sum += c })
      STDERR.puts word_concept[0..5].inspect
      STDERR.puts x[0..5].inspect
      STDERR.puts "#{word}:#{x_word} = #{sim}"
      sum += sim
    end
    return sum
    #Concept.degree(word_concept,@concept)
  end
end
