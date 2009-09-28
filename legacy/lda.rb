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
    YAML.load(str)
  end
  
  def similarity(w1,w2)
    v1 = vector(w1).map { |p| p == 0.0 ? Epsilon : p}#.map { |p| -(Math.log(p)/Math.log(2)) }
    v2 = vector(w2).map { |p| p == 0.0 ? Epsilon : p}#.map { |p| -(Math.log(p)/Math.log(2)) }
    begin
      a = (0..(v2.size-1)).inject(0) { |sum,i| sum += (v1[i] * v2[i]) }
      b = v2.inject(0) { |sum,i| sum += i }
    rescue
      p w1
      p v1
      p w2
      p v2
      throw $!
    end
    return a/b.to_f
  end
  
  alias sim similarity
  
  def vector_similarity(w1,w2)
    begin
      v1,v2 = *([w1,w2].map { |x| vector(x).map { |p| p == 0.0 ? Epsilon : p} })
      cosine(v1,v2)
    rescue
      raise $!
    end
  end
  
  def cosine(a,b)
    mag = [a,b].map { |v| v.inject(0) { |s,x| s+=x**2 } }.map { |x| x**0.5 }
    dot_product(a,b)/(mag.inject(1) { |s,x| s *= x }).to_f
  end
  
  def dot_product(a,b)
    sum = 0
    (0..(a.size-1)).each { |i| sum += (a[i] * b[i]) }
    return sum
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
