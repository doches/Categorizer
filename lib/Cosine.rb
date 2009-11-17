# Used to find the distance between two words from a pre-computed
# list of cosines (wordmap+matrix)
class Cosine
  @cosine_wordmap = nil
  @cosine_matrix = nil

  # Create a new Cosine index from the specified wordmap (yaml-encoded array of words)
  # and matrix (yaml-encoded array of vectors, in which each element is a cosine dist).
  def initialize(wordmap,matrix)
    @cosine_wordmap = YAML.load_file(wordmap)
    @cosine_matrix = YAML.load_file(matrix)
  end
  
  # Get a list of the words in this index
  def words
    return @cosine_wordmap.dup
  end
  
  # Check and see if the specified word is in the Index
  def include?(word)
    return @cosine_wordmap.include?(word)
  end
  
  # Get the distance between two words. Raises a RuntimeException if 
  # either word is not found.
  def distance(word_1,word_2)
    index1 = @cosine_wordmap.index(word_1)
    index2 = @cosine_wordmap.index(word_2)
    
    raise "\"#{word_1}\" not found in wordmap" if index1.nil?
    raise "\"#{word_2}\" not found in wordmap" if index2.nil?
    
    return @cosine_matrix[index1][index2]
  end
end
