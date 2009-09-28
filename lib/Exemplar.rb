class Exemplar
  attr_accessor :word,:category,:frequency
  
  def initialize(word,category,freq)
    @word = word
    @category = category
    @frequency = freq
  end
end
