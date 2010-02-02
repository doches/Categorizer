require 'lib/Report'
require 'lib/Models'

# Produce GNUPlot graphs from raw Naming/Generation/Typicality data
module Graph
  # An object that treats missingmethod calls as accesses on a hash @attrib
  class HashObject
    def initialize
      @attribs = {}
    end
    
    # Beautiful hack that lets you access GNUPlot options (terminal, size, output, xrange, etc.)
    # via hash syntax.
    def method_missing(sym,*args,&blk)
      if sym.to_s =~ /^(.+)=$/
        @attribs[$1] = args[0]
      elsif @attribs.include?(sym.to_s)
        return @attribs[sym.to_s]
      end
      return nil
    end  
  end
  
  # Abstract class from which data-specific plots inherit. Sets some
  # default options for GNUPlot (such as terminal type and output) so
  # as to unify resulting graphs.
  #
  # Could do with a bit more customization, so plots are even more 
  # homogenous.
  class Plot < HashObject
    attr_accessor :tmpdir,:tmpdir
    attr_reader :data

    # Create a new Plot. 'output' is used to name the resulting file,
    # regardless of term type (e.g. resulting graph will be in "output.<type>").
    # GNUPlot variables can be accessed via has syntax, as in the example.
    #
    # Example usage (won't work, because by default Plot doesn't know about any data).
    #   plot = Plot.new("foo")
    #   plot.xrange = "[0:19]"
    #   plot.render
    def initialize(output)
      super()
      @tmpdir = "reports"
      @output = output
      @attribs = {
        "terminal" => "postscript",
        "size" => "0.5,0.5",
        "output" => "\"#{output}.eps\"",
        "xrange" => "[0:9]",
        "yrange" => "[0:1]"
      }
    end
    
    # Produce a .plt file, render the graph, and convert the resulting .eps into a more useful PDF.
    def render
      plt = self.to_plt.split("/").pop
      old_dir = Dir.getwd
      Dir.chdir(@tmpdir)
      `gnuplot #{plt} && epstopdf #{@output}.eps`
      3.times do 
        `pdf90 #{@output}.pdf --outfile rotate_temp.pdf && mv rotate_temp.pdf #{@output}.pdf`
      end
      Dir.chdir(old_dir)
      return File.join(@tmpdir,"#{@output}.eps")
    end
    
    protected
    
    # Write current attributes/data into a .plt file. Called by 'render'.
    # 'custom_text' is added to the end of the file, after all attributes have been set. Add references to data files here.
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
  
  # Generates pretty combined graphs for typicality rating + category naming.
  # Requires bargraph.pl, a scriptable layer over GNUPlot.
  #
  # +output+ is the filename to use for the final graph (and all temporary files);
  # +models+ should be a hash of Models#sym_to_class formatted model names => x-axis labels (short names) to use for input
  class CombinedPlot < HashObject
    attr_accessor :tmpdir
    attr_reader :data
    
    def initialize(output,models)
      @data = models
      @tmpdir = "reports"
      @attribs = {
        "colors" => "black,grey5",
        "yformat" => "%g",
        "max" => 1,
        "extraops" => "set y2range [0:1];set y2tics autofreq;set ylabel \"Proportion correct\";set y2label \"Average correlation\""
      }
      @output = output
    end
    
    def render(pdf=true)
      old_dir = Dir.getwd
      tempfile = self.to_bar
      Dir.chdir(@tmpdir)
      if pdf
        `bargraph.pl #{tempfile} > #{@output}.eps && epstopdf #{@output}.eps && rm #{@output}.eps`
      else
        `bargraph.pl #{tempfile} > #{@output}.eps`
      end
      Dir.chdir(old_dir)
    end
    
    def to_bar
      fname = "#{@output}.bar"
      file = File.join(@tmpdir,fname)
      file = File.open(file,"w")
      file.puts "=cluster;Category Naming;Typicality Ratings"
      @attribs.sort.each do |key,value|
        file.puts "#{key}=#{value}"
      end
      file.puts "=table"
      # Data
      @data.sort.each do |model,key|
        naming = Report::NamingData.new(File.join("results","naming",model+".report"),true)
        typicality = Report::TypicalityData.new(File.join("results","typicality",model+".report"),true)
        file.puts [key,naming.value,typicality.value].join("\t")
      end
      file.close
      return fname
    end
  end
  
  # Uses bargraph.pl to produce a barplot comparing multiple models in different spaces on the same task.
  # Do not use directly; instead, use one of the specialized ComparisonPlots (NamingComparisonPlot, TypicalityComparisonPlot, or GenerationComparisonPlot).
  #
  # usage:
  #   plot = ComparisonPlot.new("OutputGraph", {"model-name" => ["results1.report","results2.report"]...},["Space1","Space2"])
  #   plot.render()
  class ComparisonPlot < CombinedPlot
    attr_accessor :report_class
    
    def initialize(output,models,spaces)
      super(output,models)
      @attribs['extraops'] = "set yrange [0:1]; set ytics autofreq;"
      @spaces = spaces
      @report_class = nil
    end
    
    def to_bar
      fname = "#{@output}.bar"
      file = File.join(@tmpdir,fname)
      file = File.open(file,"w")
      file.puts "=cluster;#{@spaces.join(';')}"
      @attribs.sort.each do |key,value|
        file.puts "#{key}=#{value}"
      end
      file.puts "=norotate"
      file.puts "=table"
      # Data
      @data.sort.each do |model,reports|
        reports.map! { |filename| @report_class.new(filename).value }
        file.puts [model,reports].flatten.join("\t")
      end
      file.close
      return fname
    end
  end
  
  class NamingComparisonPlot < ComparisonPlot
    def initialize(output,models,spaces)
      super(output,models,spaces)
      @attribs['extraops'] += "set ylabel \"Proportion Correct\";"
      self.report_class = Report::NamingData
    end
  end
  
  class TypicalityComparisonPlot < ComparisonPlot
    def initialize(output,models,spaces)
      super(output,models,spaces)
      @attribs['extraops'] += "set ylabel \"Correlation w/ Typicality\";"
      self.report_class = Report::TypicalityData
    end
  end

  class GenerationComparisonPlot < ComparisonPlot
    def initialize(output,models,spaces)
      super(output,models,spaces)
      @attribs['extraops'] += "set ylabel \"Average Overlap\";set yrange [0:20];"
      self.report_class = Report::GenerationData
    end
  end

  # An abstract bar graph (e.g. a GNUPlot graph using "with boxes fs solid").
  # Subclass to provide data.
  class BarPlot < Plot
    def initialize(output,label_type=false)
      super(output)
      
      raise "BarPlot requires @data initialization before call to super() in constructor" if @data.nil?
      
      @rotate = !label_type
      self.boxwidth = "0.75"
      self.xrange = "[-1:#{@data.size}]"
      tics = []
      @data.sort! { |a,b| Models.class_to_label(a[0].filename.split("/").pop.split(".").shift,label_type) <=> Models.class_to_label(b[0].filename.split("/").pop.split(".").shift,label_type) }
      @data.each_with_index { |x,i| tics.push "\"#{Models.class_to_label(x[1].split('/').pop.split('.').shift,label_type)}\" #{i}" }
      self.xtics = "(#{tics.join(', ')}) #{@rotate ? "rotate" : ""}"
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
  
  # A plot of typicality (correlation) values.
  class TypicalityPlot < BarPlot
    # Create a Typicality plot from an array of Typicality.rb produced files, and save the resulting graph in 'output'.
    # [filenames]  Each file in 'filenames' should consist of two columns of numbers, one line per exemplar/category pair, with 
    #              generation frequency in the first column and the predicted similarity between the category and exemplar in the second.
    # [output]     The filename to use in producing the final graph (as well as any temporary or data files created therein).
    def initialize(filenames,output,space_label=false)
      @data = filenames.map { |filename| [Report::TypicalityData.new(filename),filename] }
      super(output,space_label)
      self.tmpdir += "/typicality"
      self.yrange = "[0:1.0]"
      self.ylabel = "\"Correlation w/ typicality ratings\""
    end
    
    # Get the p-value for each pair of correlations (via Regress). Has no effect on the graph produced, but 
    # this is usually the kind of thing you might want to talk about in the caption (for instance).
    def significance
      pairs = data.map { |f| [f[1].split("/").pop.split(".").shift,f[0].regress] }
      sigs = []
      for i in (0..pairs.size-2)
        for j in (i+1..pairs.size-1)
          sigs.push [pairs[i][0],pairs[j][0],Regress.diff_sig(pairs[i][1],pairs[j][1])]
        end
      end
      return sigs
    end
  end
  
  # A plot of generation values. Shows the average overlap between the n exemplars most similar to each category and the
  # n exemplars most frequently generated (by humans) when shown that category label.
  class GenerationPlot < BarPlot
    # Create a Generation plot from an array of Generation.rb produced files, and save the resulting graph in 'output'.
    # [filenames] Each file in 'filenames' should be of the form:
    #   
    #               category1: word1, word2, word3...
    #               category2: word4, word5, word6...
    #               ...
    # [output]    The filename to use in producing the final graph, as well as any temporary or data files created along the way.
    def initialize(filenames,output,space_label=false)
      @data = filenames.map { |filename| [Report::GenerationData.new(filename,filename.include?("Mcrae")),filename] }
      super(output,space_label)
      self.tmpdir += "/generation"
      self.yrange = "[0:20]"
      self.ylabel = "\"Average overlap (N/20 exemplars)\""
    end
  end
  
  # A plot of category naming values. Shows the proportion of exemplars labeled with the correct
  # category label.
  class NamingBarPlot < BarPlot
    # Create a Naming plot from an array of Naming.rb produced files, and save the resulting graph in 'output'.
    # [filenames] Each file in 'filenames' should be of the form:
    #
    #               exemplar1 (correct_category): category1 (sim)  category2 (sim)  category3 (sim)...
    #               exemplar2 ...
    # [output]    Used to name the final graph and any data/temporary files produced along the way (i.e. output.eps, output.dat, output.pdf)
    def initialize(filenames,output,space_label=false)
      @data = filenames.map { |filename| [Report::NamingData.new(filename),filename] }
      super(output,space_label)
      self.tmpdir += "/naming"
      self.ylabel = "\"Proportion correct\""
    end
  end
  
  # DEPRECATED
  #
  # A plot of category naming values. Shows the proportion of exemplars labeled with the correct
  # category label in an n-best fashion. The resulting graph is a line graph where the value at 
  # x=0 is the proportion of correctly labeled exemplars, x=1 is the proportion of exemplars for whom the 
  # correct category label was either the most similar or second most similiar, x=2 most similar, second most, or third most, etc...
  class NamingPlot < Plot
    # Create a Naming plot from an array of Naming.rb produced files, and save the resulting graph in 'output'.
    # [filenames] Each file in 'filenames' should be of the form:
    #
    #               exemplar1 (correct_category): category1 (sim)  category2 (sim)  category3 (sim)...
    #               exemplar2 ...
    # [output]    Used to name the final graph and any data/temporary files produced along the way (i.e. output.eps, output.dat, output.pdf)
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
