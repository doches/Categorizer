require 'lib/Oracle'
require 'lib/Model'
require 'legacy/ncosine'

# A mix-in abstracting away the mechanics of a baseline (or Oracle) model.
# A Baseline model is one in which categories are grouped into the correct
# category labels by means of oracle information (e.g. from Mechanical Turk).
module Baseline
  # Boolean indicating whether the model should print verbose information about 
  # errors encountered. If set to +true+, a Baseline model will spam STDERR with
  # messages about:
  # * words whose vectors either don't exist or contain only one unique element,
  # * word/category pairs for which a +nil+ or +NaN+ similarity is returned,
  # * the similarity betweene very word/category pair.
  attr_accessor :debug
  
  # Called manually during the implementing model's constructor to initialize the
  # baseline model. Loads data from the Oracle and builds a list of predicted (correct, in this case)
  # category labels.
  def init_baseline
    @predicted = {}
    Oracle.raw.each_pair do |category,exemplars|
      @predicted[category] = []
      exemplars.each_pair do |word,freq|
        @predicted[category].push [word,freq]
      end
      @predicted[category] = @predicted[category].sort { |a,b| b[1] <=> a[1] }[0..9].map { |x| x[0] }
    end
    @debug = false
  end
  
  # Compute the similarity between a word and a category label. Basically, this method
  # gets the vector for the word, does some sanity checking, then passes control
  # off to #similarity_cluster which does the real work. It does a little more sanity checking on 
  # the result (to account for wild discrepancies between legacy models regarding invalid vectors/similarities).
  #
  # Will return a similarity of +0.0+ if an invalid vector or similarity is encountered anywhere in the
  # computation. This is silent, unless #Baseline.debug is set to true, in which case it will spam a
  # warning to standard error.
  def similarity(word,label)
    sims = []
    word_vector = cache(word)
    if not word_vector or word_vector.size <= 1 or word_vector.uniq.size <= 1
      #STDERR.puts "No vector for '#{word}', letting sim(#{word},#{label}) = 0" if @debug
      return 0.0
    end
    word_vector = NVector.to_na(word_vector)
    sim = similarity_cluster(word_vector,label)
    if sim and not sim.nan?
      STDERR.puts "sim(#{word},#{label}) = #{sim}" if @debug
      return sim
    else
      STDERR.puts "Unreasonable similarity '#{sim}' for sim(#{word},#{label}), returning 0.0" if @debug
      return 0.0
    end
  end
  
  # Called by #similarity to get the similarity between a word vector and a category label. While this doesn't
  # make a terribly large amount of sense in the case of a Baseline model, breaking up the problem in this fashion makes it
  # _considerably_ easier to implement more interesting models (i.e. Cluster).
  #
  # Returns the similarity between the vector and the label, as computed by a simple GCM-like summing of individual similarities.
  # May raise a RuntimeError ("complex error") if the computed cosine similarity is a Complex number (in which case something terribly has happened and all trains should be stopped immediately).
  #
  # NOTE: the similarity is normalized by the size of the cluster.
  def similarity_cluster(word_vector,clabel)
    sim = 0
    @predicted[clabel].each do |exemplar|
      exemplar_vector = cache(exemplar)
      if not exemplar_vector or exemplar_vector.size <= 1
        STDERR.puts "No vector for '#{exemplar}', ignoring in sim_cluster(<something>,#{clabel})" if @debug
      else
        exemplar_vector = NVector.to_na(exemplar_vector)
        cos = cosine(word_vector,exemplar_vector)
        if cos.is_a?(Complex)
          STDERR.puts word_vector.inspect
          STDERR.puts exemplar
          STDERR.puts exemplar_vector.inspect
          STDERR.puts " -"
          STDERR.puts dot_product_n(word_vector,exemplar_vector)
          STDERR.puts dot_product_n(exemplar_vector,exemplar_vector)
          STDERR.puts dot_product_n(word_vector,word_vector)
          word_vector.each { |x| STDERR.puts x if x < 0 }
          raise "complex error"
        end
        sim += cos if not cos.nan?
      end
    end
    return sim / @predicted[clabel].size.to_f
  end
  
  # In a Baseline model category vectors are the same as normal word vectors, so this is
  # just an alias for #cache.
  def category_vector(word)
    cache(word)
  end
  
  # Check and see whether a word has a valid vector, incidentally putting it into the cache in the process.
  # Could be used for pre-emptive loading of vectors if one were to do something _really_ clever in the future.
  def query(word)
    v = cache(word)
    if v and v.size > 1 and v.uniq.size > 1
      return true
    else
      return false
    end
  end
end
