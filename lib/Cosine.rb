# Used to find the distance between two words from a pre-computed
# list of cosines (wordmap+matrix)
class Cosine
  @cosine_wordmap = nil
  @cosine_matrix = nil
  @underscore_wordmap = nil

  attr_reader :underscore_wordmap

  # Create a new Cosine index from the specified wordmap (yaml-encoded array of words)
  # and matrix (yaml-encoded array of vectors, in which each element is a cosine dist).
  #
  # Setting +underscore_hack+ to true enables a fallback search for missing words: if
  # a word is not found in the wordmap, we search through a secondary map containing
  # all of the ambiguous (*_(label)) words.
  def initialize(wordmap,matrix,underscore_hack=false)
    @cosine_wordmap = YAML.load_file(wordmap)
    @cosine_matrix = YAML.load_file(matrix)
    
    if underscore_hack
      @underscore_wordmap = {}
      @cosine_wordmap.each_with_index do |word,index|
        p word
        if word.include?("_")# and not @underscore_wordmap.include?(word.split("_")[0])
          @underscore_wordmap[word.split("_")[0]] = index
        end
      end
    end
  end
  
  # Get a list of the words in this index
  def words
    if @underscore_wordmap.nil?
      return @cosine_wordmap.dup
    else
      return [@cosine_wordmap,@underscore_wordmap.keys].flatten
    end
  end
  
  # Check and see if the specified word is in the Index
  def include?(word)
    if @underscore_wordmap.nil?
      return @cosine_wordmap.include?(word)
    else
      if @cosine_wordmap.include?(word)
        return true
      else
        return @underscore_wordmap.include?(word)
      end
    end
  end
  
  # Get the distance between two words. Raises a RuntimeException if 
  # either word is not found.
  def distance(word_1,word_2)
    index1 = @cosine_wordmap.index(word_1)
    index2 = @cosine_wordmap.index(word_2)
    
    if index1.nil?
      if @underscore_wordmap.nil?
        raise "\"#{word_1}\" not found in wordmap" if index1.nil?
      else
        index1 = @underscore_wordmap[word_1]
        if index1.nil?
          raise "\"#{word_1}\" not found in wordmap" if index1.nil?
        end
      end
    end
    if index2.nil?
      if @underscore_wordmap.nil?
        raise "\"#{word_2}\" not found in wordmap" if index2.nil?
      else
        index2 = @underscore_wordmap[word_2]
        if index2.nil?
          raise "\"#{word_2}\" not found in wordmap" if index2.nil?
        end
      end
    end
    
    return @cosine_matrix[index1][index2]
  end
end
