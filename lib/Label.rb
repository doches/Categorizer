require 'legacy/nconcept'

# A mix-in abstracting away the mechanics of a categorization model based on
# a vector entailment function. Unlike the Cluster and Baseline mixins (which represent exemplar models), in a
# Label model categories are represented by a prototype -- specifically, the vector of their category label.
#
# This mix-in can use a number of similarity functions (from in nconcept.rb):
# * degree
# * lin
# * weedsprec
# * balprec
# * cosine
module Label
	# Create a Label model using one of a number of possible similarity functions. See nconcept.rb for implementation details, or
	# <b>Directional Distributional Similarity for Lexical Expansion</b> (Kotlerman et al. 2009) and <b>Towards Context-sensitive Information Inference</b> (Song and Bruza 2003) for more academic descriptions.
	# [method] One of [:degree,:lin,:weedsprec,:balprec,:balapinc,:cosine] 
  def init_label(method)
    @method = method
    
    @last_label = [nil,nil] # label cache
  end
  
  # Compute the similarity between a +word+ and a category +label+. This is basically the similarity between
  # the two vectors, computed by the similarity function specified when the model was created.
  #
  # Note, the model will return a similarity of 0.0 if either vector is bad (nil or contains only one unique item)
  # or if the resulting similarity is +NaN+. This is done silently.
  def similarity(word,label)
    # One-off caching
    if @last_label[0] != label
      @last_label = [label,Concept.new(cache(label))]
    end

    # Do entailment
    vec = cache(word)
    if @last_label[1] and @last_label[1].uniq.size > 1 and vec and vec.uniq.size > 1
      sim = @last_label[1].entails(Concept.new(cache(word)),@method)
      if sim.nan?
        STDERR.puts "similarity(#{word},#{label}) = NaN, letting sim = 0.0"
        return 0.0
      else
        return sim
      end
    else
      if @last_label[1].nil?
        STDERR.puts "#{label} has nil vector"
      elsif @last_label[1].uniq.size <= 1
        STDERR.puts "#{label} has zero vector"
      elsif vec.nil?
        STDERR.puts "#{word} has nil vector"
      elsif vec.uniq.size <= 1
        STDERR.puts "#{word} has zero vector"
      else
        raise "Avoided sim() because of bad vector when I shouldn't have"
      end
      return 0.0
    end
  end
  
  # Category vectors are drawn from the same space as word vectors, so this is just an alias for #cache.
  def category_vector(label)
    cache(label)
  end
end
