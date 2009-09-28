require 'lib/lda'

class LDASimilarity
  def LDASimilarity.setup(server,port)
    @@lda = LDA.new(server,port)
  end
  
  def LDASimilarity.model
    @@lda
  end
  
  def LDASimilarity.sim(a,b)
    #@@lda.sim(a,b)
    @@lda.vector_similarity(a,b)
  end
end
