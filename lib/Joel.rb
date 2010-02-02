require 'lib/Vectors'
require 'legacy/ncosine'
# require 'progressbar'

class JoelSpace
  # Get a list of words in this space
  attr_accessor :nouns
  
  # Load a JoelSpace from files in the given +dir+
  def initialize(dir)
    nouns = IO.readlines(File.join(dir,"selected_nouns")).map { |x| x.strip.split(";")[1] }
    thetas = IO.readlines(File.join(dir,"selected_noun_thetas")).map { |x| x.strip.split(" ").map { |y| y.to_f } }
    betas = IO.readlines(File.join(dir,"selected_noun_betas")).map { |x| x.strip.split(";").map { |y| y.to_i } }
    
    @vectors = {}
    uniform_distribution = (0..299).map { |x| 1.0/300 }
    nouns.each do |noun| 
      @vectors[noun] = Vector::SparseVector.new
      @vectors[noun].default = uniform_distribution
    end
    
    max = 0
    betas.each do |beta|
      word,theta = nouns[beta[0]],thetas[beta[1]]
      @vectors[word][beta[1]] = theta
      max = beta[1] if beta[1] > max
    end
    
    @vectors.values.each { |vector| vector.size = max }
    @nouns = nouns
  end
  
  def [](word)
    if @vectors[word].nil?
#      STDERR.puts "No vector for '#{word}'"
      return []
    end
    return @vectors[word].to_array.flatten
  end
end

if __FILE__ == $0
  if ARGV.include?("-matrix")
    space = JoelSpace.new(".")

    fout = File.open("joel_sim.wordmap","w")
    fout.puts space.nouns.join("\n")
    fout.close

    fout = File.open("joel_sim.matrix","w")
    space.nouns.each_with_index do |word,i|
      progress = ProgressBar.new("#{i}",space.nouns.size-i)
      row = []
      space.nouns[i..space.nouns.size-1].each_with_index do |word2,i2|
        row[i2] = cosine_safe(space[word],space[word2])
        progress.inc
      end
      fout.puts row.join(" ")
      fout.flush
      progress.finish
    end
    fout.close
  elsif ARGV.include?("-sim")
    ARGV.reject! { |x| x == "-sim" }
    
    space = JoelSpace.new(".")
    puts cosine_safe(space[ARGV[0]],space[ARGV[1]])
  end
end
