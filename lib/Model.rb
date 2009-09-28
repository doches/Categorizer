class Model
  def initialize
    @last_label = [nil,nil]
    
    @cache = {}
  end
  
  # lookup the vector for a word, first checking in our cache
  def cache(word)
    if @cache.keys.include?(word.to_sym)
      return @cache[word.to_sym]
    else
      @cache[word.to_sym] = vector(word)
      return @cache[word.to_sym]
    end
  end
  
  # Return similarity (distance, measure, etc.) between a word (string) and a category (string, label)
  def similarity(word,label)
    raise "Virtual method"
  end
  
  # Get vector representation for a category (string, label)
  def category_vector(label)
    raise "Virtual method"
  end
  
  def query(word)
    return cache(word).size > 1
  end
  
  # Check and see if a word has a corresponding vector, coincidentally putting it into
  # the cache for category labels.
#  def query(label)
#    if @last_label[0] != label
#      @last_label = [label,Concept.new(category_vector(label))]
#    end
#    if @last_label[1].nil? or @last_label[1][0] == 0.0
#      return false
#    else
#      return true
#    end
#  end
end
