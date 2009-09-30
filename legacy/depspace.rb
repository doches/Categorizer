require 'progressbar'

class DependencySpace
  def initialize(file,progress=false)
    @progress = progress
    if file =~ /vectors$/
      load_from_vectors(file)
    else
      load_from_yaml(file)
    end
    
    @cache = {}
  end
  
  def load_from_yaml(file)
    @map = YAML.load_file("#{file}.yaml")
    @headers = YAML.load_file("#{file}.headers.yaml")
  end
  
  def load_from_vectors(vectorfile)
    lines = IO.readlines(vectorfile) # ouch
    @headers = lines.shift
    @map = {}
    pbar = ProgressBar.new("Loading",lines.size) if @progress
    lines.each do |line|
      word,dims = *line.split(": ")
      @map[word] = dims.split(" ").map { |x| x.to_i }
      pbar.inc if @progress
    end
    pbar.finish if @progress
  end
  
  def vector(word)
    return @map[word]
  end
  
  def similarity(word,list)
    sim = 0
    a = vector(word)
    return 0.0 if a.nil?
    list.each { |x| 
      temp = nil
      temp ||= @cache["#{word}#{x}"]
      temp ||=@cache["#{x}#{word}"]
      if temp.nil?
        temp = 0.0
        b = vector(x)
        if not a.nil? and not b.nil?
          temp = cosine(vector(word),vector(x))
        else
#            STDERR.puts "No vector for \"#{word}\"" if not a.nil?
 #           STDERR.puts "No vector for \"#{x}\"" if not b.nil?
        end
        temp = 0.0 if temp.nil? or temp.nan?
        @cache["#{word}#{x}"] = temp
      else
#        STDERR.print "!"
      end
      sim += temp
    }
    return sim
  end
  
  def dump(filename)
    fout = File.open("#{filename}.yaml","w")
    fout.puts @map.to_yaml
    fout.close
    fout = File.open("#{filename}.headers.yaml","w")
    fout.puts @headers.to_yaml
    fout.close
  end
end
