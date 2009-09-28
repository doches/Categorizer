# Wrap a search for a word pair from InfoMap in Ruby.

require 'rubygems'
require 'escape'

# From http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/277157
def dot_product_e l1, l2
    sum = 0
    for i in 0...l1.size
        sum += l1[i] * l2[i]
    end
    sum
end

class Array
  def peek
    self[self.size-1]
  end
end

class InfoMap
  CacheLimit = 12

  attr_accessor :model, :model_dir, :search_count
  
  def initialize(model,model_dir=nil)
    self.model = model
    self.model_dir = model_dir
    self.search_count = 200
    
    @cache = [[],{}]
    @wordlist = nil
  end
  
  def wordlist
    if @wordlist.nil?
      @wordlist = IO.readlines(File.join(self.model_dir,self.model,"wordlist")).map { |x| x.strip }
    else
      return @wordlist
    end
  end
  
  def exemplars(word)
    args = ["associate"]
    args.push ["-m",model_dir] if not model_dir.nil?
    args.push ["-c",model]
    args.push word
    cmd = Escape.shell_command(args.flatten)
    ret = %x[#{cmd} 2> /dev/null]
    list = ret.split("\n").map { |x| x.strip }.map { |x| x.split(":") }
    return list
  end
  
  def vector(word)
    if @cache[0].include?(word)
      if not @cache[0].peek == word
        @cache[0].delete(word)
        @cache[0].push(word)
      end
      return @cache[1][word]
    end
  
    args = ["associate"]
    args.push ["-q","-t"]
    args.push ["-m",model_dir] if not model_dir.nil?
    args.push ["-c",model]
    args.push word
    begin
      cmd = Escape.shell_command(args.flatten)
    rescue
      p args.flatten
      raise $!
    end
    ret = %x[#{cmd} 2> /dev/null]
    vector = ret.split(" ").map { |x| x.to_f }
    
    # Update cache
    if @cache[0].size > CacheLimit
      del = @cache[0].shift
      @cache[1].delete(del)
    end
    @cache[0].push word
    @cache[1][word] = vector
    
    # Return vector
    return vector
  end
  
  def sim_to_vector(word,v)
    vector = [vector(word),v]
    sim = dot_product_e(*vector)/(vector.map { |x| x.size }.inject(0) { |sum,c| sum += c })
    return sim
  end
  
  def similarity(a,b)
    vector = [a,b].map { |x| vector(x) }
    sim = dot_product_e(*vector)/(vector.map { |x| x.size }.inject(0) { |sum,c| sum += c })
    return sim
  end
  
  alias sim similarity
end
