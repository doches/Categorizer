class Cosine
  @cosine_wordmap = nil
  @cosine_matrix = nil

  def initialize(wordmap,matrix)
    @cosine_wordmap = YAML.load_file(wordmap)
    @cosine_matrix = YAML.load_file(matrix)
  end
  
  def include?(word)
    return @cosine_wordmap.include?(word)
  end
  
  def distance(word_1,word_2)
    index1 = @cosine_wordmap.index(word_1)
    index2 = @cosine_wordmap.index(word_2)
    
    raise "\"#{word_1}\" not found in wordmap" if index1.nil?
    raise "\"#{word_2}\" not found in wordmap" if index2.nil?
    
    return @cosine_matrix[index1][index2]
  end
end
