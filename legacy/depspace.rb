require 'progressbar'

class DependencySpace
  def initialize(file,progress=false,scale=100.0)
    @progress = progress
    if file =~ /vectors$/
      load_from_vectors(file)
    else
      load_from_yaml(file)
    end
    
    @cache = {}
    @scale = scale
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
    @scale ||= 100.0
    c = 0
    lines.each do |line|
      word,dims = *line.split(": ")
      @map[word] = dims.split(" ").map { |x| x.to_f }#/@scale }
      pbar.inc if @progress
      c += 1
      if c % 100 == 0
        #puts "#{word} = #{dims.split(' ')[0..4].join(',')}..."
      end
    end
    pbar.finish if @progress
    STDERR.puts "#{@map.keys.size} vectors loaded"
  end
  
  def vector(word)
    return @map[word]
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
