require 'lib/LsaModel'
require 'legacy/nconcept'

class LsaLabelModel < LsaModel
	# method is one of [:degree,:lin,:weedsprec,:balprec,:balapinc,:cosine]
  def initialize(method)
    super()
    @method = method
    
    @last_label = [nil,nil] # cache
  end
  
  def similarity(word,label)
    # One-off caching
    if @last_label[0] != label
      @last_label = [label,Concept.new(category_vector(label))]
    end

    # Do entailment
    sim = @last_label[1].entails(Concept.new(@legacy_model.vector(word)),@method)
    if sim.nan?
      return 0
    else
      return sim
    end
  end
  
  def category_vector(label)
    @legacy_model.vector(label)
  end
end
