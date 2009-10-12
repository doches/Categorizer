require 'lib/Report'

module Graph
  class Plot
    attr_accessor :tmpdir,:tmpdir
    attr_reader :data

    def initialize(output)
      @tmpdir = "reports"
      @output = output
      @attribs = {
        "terminal" => "postscript",
        "size" => "1,1",
        "output" => "\"#{output}.eps\"",
        "xrange" => "[0:9]",
        "yrange" => "[0:1]"
      }    
    end

    def method_missing(sym,*args,&blk)
      if sym.to_s =~ /^(.+)=$/
        @attribs[$1] = args[0]
      elsif @attribs.include?(sym.to_s)
        return @attribs[sym.to_s]
      end
      return nil
    end
    
    def render
      plt = self.to_plt.split("/").pop
      Dir.chdir(@tmpdir)
      `gnuplot #{plt} && epstopdf #{@output}.eps`
    end
    
    def to_plt(custom_text = "")
      file = "#{@tmpdir}/#{@output}.plt"
      fname = file
      file = File.open(file,"w")
      @attribs.each_pair do |key,value|
        file.puts "set #{key} #{value}"
      end
      file.puts custom_text
      file.close
      return fname
    end
  end
  
  class BarPlot < Plot
    def initialize(output)
      super(output)
      
      raise "BarPlot requires @data initialization before call to super() in constructor" if @data.nil?
      
      self.boxwidth = "0.75"
      self.xrange = "[-1:#{@data.size}]"
      tics = []
      @data.each_with_index { |x,i| tics.push "\"#{x[1].split('/').pop.split('.').shift}\" #{i}" }
      self.xtics = "(#{tics.join(', ')}) rotate"
    end
    def to_dat(force=false)
      file = @output + ".dat"
      
      fout = File.open("#{@tmpdir}/#{file}","w")
      @data.each { |datum| fout.puts datum[0].value }
      fout.close
      return file
    end
    
    def to_plt
      return super("plot \"#{self.to_dat}\" with boxes fs solid notitle")
    end
  end
  
  class TypicalityPlot < BarPlot
    def initialize(filenames,output)
      @data = filenames.map { |filename| [Report::TypicalityData.new(filename),filename] }
      super(output)
      self.tmpdir += "/typicality"
      self.yrange = "[0:0.5]"
      self.ylabel = "\"Correlation between similarity/generation frequency\""
    end
  end
  
  class GenerationPlot < BarPlot
    def initialize(filenames,output)
      @data = filenames.map { |filename| [Report::GenerationData.new(filename),filename] }
      super(output)
      self.tmpdir += "/generation"
      self.yrange = "[0:10]"
      self.ylabel = "\"Average overlap between top 20 exemplars\""
    end
  end
  
  class NamingBarPlot < BarPlot
    def initialize(filenames,output)
      @data = filenames.map { |filename| [Report::NamingData.new(filename),filename] }
      super(output)
      self.tmpdir += "/naming"
      self.ylabel = "\"Proportion Correct\""
    end
  end
  
  class NamingPlot < Plot
    def initialize(filenames,output)
      super(output)
      self.tmpdir += "/naming"
      
      @data = filenames.map { |filename| [Report::NamingData.new(filename),filename] }
      self.ylabel = "\"Proportion Correct\""
      self.xlabel = "\"N-best categories\""
    end
    
    def to_dat(force=false)
      files = []
      @data.each do |datum|
        output = datum[1].split("/").pop.split(".")
        output.pop
        output = output.join("_")
        filename = output + ".dat"
        if not File.exists?("#{@tmpdir}/#{filename}") or force
          fout = File.open("#{@tmpdir}/#{filename}","w")
          fout.puts datum[0].scores.join("\n")
          fout.close
        end
        files.push filename
      end
      return files
    end
    
    def to_plt
      dats = self.to_dat
      text = dats.map { |dat| "\"#{dat}\" with linespoints title \"#{dat.split('.')[0]}\"" }
      return super("plot #{text.join(", \\\n\t")}")
      file.close
      return fname
    end
  end
end
