require 'lib/Model'
require 'legacy/ncosine'

# A mix-in abstracting away the mechanics of a categorization model based on
# some external clustering information. Differs from a Baseline model in that,
# where a Baseline model uses information from the Oracle to determine which exemplars
# belong to which categories, a Cluster model uses the output of some clustering algorithm.
# This output is in a YAML-formatted file contained a hash mapping category labels (salted
# with indices) to a list of exemplars.
#
# For example, a hash might be something like:
#   "fruit-1" => ["apple","orange","pear"],
#   "fruit-2" => ["banana","pomegranate"],
#   "food-1" => ["pizza"]
#
# Note that the actual indices attached to category labels is almost entirely irrelevant;
# they're only used to distinguish multiple categories sharing the same label.
module Cluster
  # Boolean indicating whether the model should print verbose information about 
  # errors encountered. If set to +true+, a Cluster model will spam STDERR with
  # messages about:
  # * words whose vectors either don't exist or contain only one unique element,
  # * word/category pairs for which a +nil+ or +NaN+ similarity is returned,
  # * the similarity betweene very word/category pair.
  # Defaults to +false+.
  attr_accessor :debug
  
  # Called manually during the implementing model's constructor to initialize the
  # cluster model. Loads the predicted category data in +filename+ from a model-specific datapath.
  #
  # @datapath should be specified in an implementing model _before_ calling +init_cluster+.
  def init_cluster(filename)
    raise "no datapath" if @datapath.nil?
    @predicted = YAML.load_file(@datapath + filename)
    @debug = false 
  end

  # Compute the similarity between a word and a category label. Basically, this method
  # gets the vector for the word, does some sanity checking, then passes control
  # off to #similarity_cluster which does the real work. It does a little more sanity checking on 
  # the result (to account for wild discrepancies between legacy models regarding invalid vectors/similarities).
  #
  # Will return a similarity of +0.0+ if an invalid vector or similarity is encountered anywhere in the
  # computation. This is silent, unless #Cluster.debug is set to true, in which case it will spam a
  # warning to standard error.
  #
  # The method of computing similarity differs from that of a Baseline model in one critical aspect:
  # in a Cluster model there may be multiple categories with the same label. To resolve this, a Cluster
  # model computes the similarity between the given word and each category that matches the given label, returning
  # only the similarity between the closest-matching category (e.g. the highest possible similarity).
  def similarity(word,label)
    sims = []
    word_vector = cache(word)
    if not word_vector or word_vector.size <= 1 or word_vector.uniq.size <= 1
      STDERR.puts "No vector for '#{word}', letting sim(#{word},#{label}) = 0" if @debug
      return 0.0
    end
    word_vector = NVector.to_na(word_vector)
    @predicted.keys.reject { |clabel| not clabel =~ /^#{label}\-[0-9]+$/ }.each do |clabel|
      sim = similarity_cluster(word_vector,clabel)
      STDERR.puts "sim_cluster(#{word},#{clabel}) = #{sim}" if @debug and false
      sims.push sim
    end
    if sims.size <= 0
      STDERR.puts "No cluster-labels matching #{label} found, letting sim(#{word},#{label}) = 0" if @debug
#      STDERR.puts @predicted.keys.inspect
      raise "No cluster-labels matching #{label} found!"
      return rand
    else
      begin
        sims.reject! { |x| x.nan? } 
        sim = sims.sort()[0]
        return sim || 0.0
      rescue
        STDERR.puts word,label
        STDERR.puts sims
        raise $!
      end
    end
  end
  
  # Called by #similarity to get the similarity between a word vector and a category label.
  # 
  # Returns the similarity between the vector and the label, as computed by a simple GCM-like summing of individual similaritie$
  # May raise a RuntimeError ("complex error") if the computed cosine similarity is a Complex number (in which case something t$
  #
  # NOTE: the similarity is normalized by the size of the cluster, which is critical as clusters may be variable-sized (unlike the categories in, say, a Baseline model).
  def similarity_cluster(word_vector,clabel)
    sim = 0
    @predicted[clabel].each do |exemplar|
      exemplar_vector = cache(exemplar)
      if not exemplar_vector or exemplar_vector.size <= 1
        STDERR.puts "No vector for '#{exemplar}', ignoring in sim_cluster(<something>,#{clabel})" if @debug
      else
        exemplar_vector = NVector.to_na(exemplar_vector)
        sim += cosine(word_vector,exemplar_vector)
      end
    end
    return sim / @predicted[clabel].size.to_f
  end
  
  # In a Cluster model category labels have the same vectors as normal words, so this is just an alias for #cache.
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
