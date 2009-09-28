require 'lib/categorymodel'
require 'lib/ldasim'
require 'lib/concept'

class ExemplarLDAModel < CategoryModel
  attr_reader :words
  Epsilon = 1.0e-10
  
  def initialize(words,phi)
    throw "Exemplar models must be initialized with an Array of words!" if not words.is_a? Array
    
    @words = words
    @phi = phi
    @centroid = nil
  end
  
  def add_exemplar(word)
    @words.push word
  end
  
  def calc_centroid(words)
    words = words.map { |x| vector(x) }
    centroid = Array.new(words[0].size,0)
    words.each { |w| w.each_with_index { |v,i| centroid[i] += v }}
    return centroid
  end
  
  def update_centroid
    @centroid = (@concept ? Concept.new(@words[0]) : calc_centroid(@words))
  end
  
  def similarity(word)
    @centroid = self.update_centroid if @centroid.nil?
    centroid = @centroid
    centroid = self.calc_centroid(@words.reject { |x| x == word }) if @words.include?(word)
    sim = vector_similarity(centroid,word)
    return sim
  end
  
  def cosine_similarity(word)
    return self.similarity(word)
  end
  
  def prob_similarity(word)
    if @centroid.nil?
      @centroid = @words.map { |word| vector(word) }
    end
    
    sum = 0
    v = vector(word)
    @centroid.each { |v2| sum += p_similarity(v,v2) }
    return sum
  end
  
  def concept_similarity(word)
    word_concept = Concept.new(vector(word))
    if @centroid.nil?
      @centroid = Concept.new(vector(@words[0]))
    end
    sim = Concept.degree(word_concept,@centroid)
    return sim
  end
  
  def p_similarity(w1,w2)
    v1 = (w1.is_a?(Array) ? w1 : vector(w1))
    v2 = (w2.is_a?(Array) ? w2 : vector(w2))
    
    num = 0
    div = 0
    for i in (0..v1.size-1)
      num += v2[i] * v1[i]
      div += v1[i]
    end
    return num/div.to_f
  end
  
  def vector_similarity(w1,w2)
    begin
      if w1.is_a? Array
        v1 = w1
        v2 = vector(w2).map { |p| p == 0.0 ? Epsilon : p }
      else
        v1,v2 = *([w1,w2].map { |x| vector(x).map { |p| p == 0.0 ? Epsilon : p} })
      end
      cosine(v1,v2)
    rescue
      raise $!
    end
  end
  
  def cosine(a,b)
    mag = [a,b].map { |v| v.inject(0) { |s,x| s+=x**2 } }.map { |x| x**0.5 }
    dot_product(a,b)/(mag.inject(1) { |s,x| s *= x }).to_f
  end
  
  def dot_product(a,b)
    sum = 0
    (0..(a.size-1)).each { |i| sum += (a[i] * b[i]) }
    return sum
  end
  
  def vector(word)
    @phi.vector(word)
  end
end
