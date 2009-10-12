# A simple struct-style object for dealing with exemplars.
# The Oracle returns an array of Exemplar objects by default.
class Exemplar
  # The word this exemplar represents (i.e. "apple")
  attr_accessor :word
  # The correct category for this exemplar (i.e. "fruit")
  attr_accessor :category
  # The frequency with which this #word was generated (given the #category) in the Mechanical Turk data.
  attr_accessor :frequency
  
  # Create a new Exemplar from a word, category label, and frequency.
  def initialize(word,category,freq)
    @word = word
    @category = category
    @frequency = freq
  end
end
