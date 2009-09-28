require 'narray'
require 'yaml'

class LDA
  Epsilon = 1.0e-10
  
  def LDA.epsilon
    Epsilon
  end
  
  def initialize(server,port)
    @server = server
    @port = port
  end
  
  def vector(word)
  	return false if not word =~ /^[a-zA-Z0-9]+$/
    str = `echo #{word.gsub("'","")} | nc #{@server} #{@port}`
    vec = YAML.load(str)
    NVector.to_na(vec) if vec
  end
  
  def fix_notation(float)
    return float.to_s if not float.to_s.include?("e")
    
    mantissa,exponent = *(float.to_s).split("e-")
    
    exponent = exponent.to_i - 1
    str = "0."
    exponent.times { str += "0" }
    str += mantissa.to_s.gsub(".","")
    
    return str
  end
end

if __FILE__ == $0
  server = ARGV.size > 2 ? ARGV.shift : "localhost"
  port = ARGV.size > 2 ? ARGV.shift.to_i : 9999
  lda = LDA.new(server,port)
  w1 = ARGV.shift
  w2 = ARGV.shift
  #puts "Vector(cosine): #{lda.vector_similarity(w1,w2)}"
  #puts "Griffiths:      #{lda.similarity(w1,w2)}"
  puts lda.similarity(w1,w2).to_f
end
