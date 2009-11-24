require 'lib/Oracle'
require 'lib/Model'
require 'lib/Cosine'


# A mix-in abstracting away the mechanics of a baseline (or Oracle) model.
# A Baseline model is one in which categories are grouped into the correct
# category labels by means of oracle information (e.g. from Mechanical Turk).
#
# BaselineCosine differs from Baseline in that cosines are pre-computed.
module BaselineCosine
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
    Oracle.mcrae_raw.each_pair do |category,exemplars|
      @predicted[category] = []
      exemplars.each_pair do |word,freq|
        @predicted[category].push [word,freq]
      end
      @predicted[category] = @predicted[category].sort { |a,b| b[1] <=> a[1] }[0..9].map { |x| x[0] }
    end
    @debug = false
    @cosines = Cosine.new(File.join(@datapath,"cosine_wordmap.yaml"),File.join(@datapath,"cosine_matrix.yaml"))
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
    if @cosines.include?(word)
      sim = similarity_cluster(word,label)
    elsif word.include?("_")
      word = word.split("_")[0]
      sim = similarity_cluster(word,label)
    else
      STDERR.puts "\'#{word}\' not in list of pre-computed cosines, sim(#{word},#{label}) = 0" if @debug
      sim = 0.0
    end
    return sim
  end
  
  # Called by #similarity to get the similarity between a word vector and a category label. While this doesn't
  # make a terribly large amount of sense in the case of a Baseline model, breaking up the problem in this fashion makes it
  # _considerably_ easier to implement more interesting models (i.e. Cluster).
  #
  # Returns the similarity between the vector and the label, as computed by a simple GCM-like summing of individual similarities.
  # May raise a RuntimeError ("complex error") if the computed cosine similarity is a Complex number (in which case something terribly has happened and all trains should be stopped immediately).
  #
  # NOTE: the similarity is normalized by the size of the cluster.
  def similarity_cluster(word,label)
    sim = 0
    exemplars = @predicted[label].reject { |exemplar| not @cosines.include?(exemplar) }
    exemplars.each do |exemplar|
      sim += @cosines.distance(word,exemplar)
    end
    return sim / exemplars.size.to_f
  end
  
  # In a Baseline model category vectors are the same as normal word vectors, so this is
  # just an alias for #cache.
  def category_vector(word)
    raise "No vectors in *Cosine models"
  end
  
  # Check and see whether a word has a valid vector, incidentally putting it into the cache in the process.
  # Could be used for pre-emptive loading of vectors if one were to do something _really_ clever in the future.
  def query(word)
    @cosines.include?(word)
  end
end
