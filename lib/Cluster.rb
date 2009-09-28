require 'lib/Model'
require 'legacy/ncosine'

module Cluster
  attr_accessor :debug
  
  # Initialize Cluster mixin. Must be called MANUALLY!
  def init_cluster(filename)
    raise "no datapath" if @datapath.nil?
    @predicted = YAML.load_file(@datapath + filename)
    @debug = false
  end
  
  def similarity(word,label)
    sims = []
    word_vector = cache(word)
    if not word_vector or word_vector.size <= 1 or word_vector.uniq.size <= 1
      STDERR.puts "No vector for '#{word}', letting sim(#{word},#{label}) = 0" if @debug
      return 0.0
    end
    word_vector = NVector.to_na(word_vector)
    @predicted.keys.reject { |clabel| not clabel =~ /^#{label}\-[0-9]+$/ }.each do |clabel|
      sims.push similarity_cluster(word_vector,clabel)
    end
    if sims.size <= 0
#      STDERR.puts "No cluster-labels matching #{label} found, letting sim(#{word},#{label}) = 0" if @debug
      return 0.0
    else
      begin
        sims.reject! { |x| x.nan? } 
        sim = sims.sort()[0]
#        STDERR.puts "#{word} #{label} #{sim}"
        return sim || 0.0
      rescue
        p word,label
        p sims
        raise $!
      end
    end
  end
  
  # Called internally to find the similarity between a word and a cluster-label (i.e. "food-34")
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
  
  # Category vectors are the same as normal vectors
  def category_vector(word)
    vector(word)
  end
  
  def query(word)
    v = cache(word)
    if v and v.size > 1 and v.uniq.size > 1
      return true
    else
      return false
    end
  end
end
