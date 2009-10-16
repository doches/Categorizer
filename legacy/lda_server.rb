require 'yaml'

class Phi
  attr_reader :hits, :misses, :words

	def initialize(model_path,name,cache_limit=100)
		# Build wordmap
		@words = {}
		STDERR.print "Reading wordmap..."
		fin = File.open(File.join(model_path,"wordmap.txt"),"r")
		last = 0
		fin.each_line do |line|
		  word,index = *(line.strip.split(" "))
		  @words[word.to_s] = index.to_i
		end
		fin.close()
		STDERR.puts "OK"
		
	  # Build P(w_z) dist.
	  STDERR.print "Reading vectors"
	  @topics = {} # { w_i => [z_0, z_1, z_2] }
		fin = File.open(File.join(model_path,"#{name}.phi"),"r")
		last = 0
		fin.each_line do |line|
		  probs = line.strip.split(" ")
		  
		  # Pre-fill with empty arrays
		  if not @topics.include?(0)
		    (0..probs.size).each { |i| @topics[i] = [] }
		  end
		  probs.each_with_index { |prob,i| @topics[i].push prob.to_f }
		  STDERR.print "."
		end
		fin.close()
		STDERR.puts "OK"
		
		@vocab_size = @topics[0].size
		
		@cache = {}
		@cache_limit = cache_limit
		@hits = 0
		@misses = 0
	end
	
	def vector(word)
	  word = word.upcase.to_s
	  if @cache_limit > 0
  	  if @cache[word]
	      @hits += 1
	      return @cache[word]
  	  else
	      @misses += 1
  	    index = @words[word]
	      if index.nil?
	        # We didn't find the word, so return a vector of all zeroes (possibly we could do something
	        # more informative here, but all my later code knows to reject all-zero vectors, so this ought
	        # to be ok for a while. This iteration, anyway.
	        #
	        # Sigh.
	        return Array.new(@vocab_size,0.0)
	      end
	      if @cache.size > @cache_limit
	        @cache.delete(@cache.keys[rand*@cache.keys.size])
  	    end
	      @cache[word] = @topics[index]
	      return @cache[word]
	    end
	  else
	    index = @words[word]
	    if index.nil?
	      return Array.new(@vocab_size,0.0)
	    else
	      return @topics[index]
	    end
	  end
	end
end 

def usage()
  STDERR.puts "Usage: ruby #{__FILE__} [OPTIONS]"
  STDERR.puts "OPTIONS:"
  STDERR.puts "\t--port|-p N     Port number on which to listen for requests (defaults to 9999)"
  STDERR.puts "\t--model|-m PATH Path to model directory (defaults to '.')"
  STDERR.puts "\t--name|-n NAME  Name of model (defaults to model-final)"
  STDERR.puts "\t--help|-h       Display this help text"
end

if __FILE__ == $0
  if ARGV.include?("-h") or ARGV.include?("--help")
    usage()
    exit(0)
  end
  require 'socket'
  port = 9999
  port = ARGV.include?("-p") ? ARGV[ARGV.index("-p")+1].to_i : port
  port = ARGV.include?("--port") ? ARGV[ARGV.index("--port")+1].to_i : port
  model = "."
  model = ARGV.include?("-m") ? ARGV[ARGV.index("-m")+1].to_s : model
  model = ARGV.include?("--model") ? ARGV[ARGV.index("--model")+1].to_s : model
  name = "model-final"
  name = ARGV.include?("-n") ? ARGV[ARGV.index("-n")+1].to_s : name
  name = ARGV.include?("--name") ? ARGV[ARGV.index("--name")+1].to_s : name
  cache = 1000
  cache = ARGV.include?("-c") ? ARGV[ARGV.index("-c")+1].to_i : cache
  cache = ARGV.include?("--cache") ? ARGV[ARGV.index("--cache")+1].to_i : cache

  phi = Phi.new(model,name,cache)
  STDERR.puts "Listening for connections on #{port}"
  server = TCPServer.new(`hostname`.strip,port)
  count = 0
  while (session = server.accept)
    begin
    word = session.gets.strip
    if word == "_close_phi_session"
      session.close
      break
    end
    rescue
      STDERR.puts $!
    end
    begin
      STDERR.puts word
      session.print phi.vector(word).to_yaml
    rescue
      STDERR.puts $!
    end
    session.close
    count += 1
    STDERR.puts "#{phi.hits} / #{count}" if count % 1000 == 0
  end
  STDERR.puts count
end
