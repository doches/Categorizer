# Represents an abstract category. Subclass and override the +similarity+ method
# to vary the type of model, and mix in different wordsim modules to vary the
# word-level similarity function.
class CategoryModel
  # Create a new category based on the given word.
  def initialize(word)
    @word = word
  end
  
  # Calculate the similarity of stimulus to this category. Override this method
  # to vary between prototype, exemplar, and interpolated models.
  def similiary(stimulus)
    throw :not_implemented
  end
end
