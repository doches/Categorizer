require 'lib/Oracle'
require 'lib/Model'
require 'legacy/ncosine'

module Baseline
  attr_accessor :debug
  
  # Initialize Cluster mixin. Must be called MANUALLY!
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
  
  def similarity(word,label)
    sims = []
    word_vector = cache(word)
    if not word_vector or word_vector.size <= 1 or word_vector.uniq.size <= 1
      STDERR.puts "No vector for '#{word}', letting sim(#{word},#{label}) = 0" if @debug
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
  
  # Called internally to find the similarity between a word and a cluster-label (i.e. "food-34")
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
        sim += cos
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
