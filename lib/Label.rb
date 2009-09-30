require 'legacy/nconcept'

module Label
	# method is one of [:degree,:lin,:weedsprec,:balprec,:balapinc,:cosine]
  def init_label(method)
    @method = method
    
    @last_label = [nil,nil] # cache
  end
  
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
        return 0.0
      else
        return sim
      end
    else
      return 0.0
    end
  end
  
  def category_vector(label)
    cache(label)
  end
end
