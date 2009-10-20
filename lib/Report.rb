require 'lib/Oracle'
require 'lib/Regress'

# The Report module provides wrapper objects that handle parsing the 
# reports produced by Naming.rb, Typicality.rb, and Generation.rb.
# Right now these are only used by the classes in the Graph module.
module Report
  # Represents one result (e.g. line) from a Naming report.
  # You probably don't want to instantiate this directly, as it's kind of useless
  # (it's only a struct) -- used by NamingData to make the parsing function a 
  # teeny bit prettier.
  class NamingResult
    attr_accessor :exemplar,:correct,:labels
    def initialize(exemplar,correct,categories)
      @exemplar = exemplar
      @correct = correct
      @labels = categories
    end
  end
  
  # Process a Naming report into meaningful results
  class NamingData
    # An array of NamingResult objects, one per line
    attr_reader :results
    
    # Load a report from 'filename'
    def initialize(filename)
      oracle = Oracle.raw
      
      @results = []
      IO.foreach(filename) do |line|
        exemplar,categories = *line.strip.split(": ")
        exemplar =~ /^([a-zA-Z0-9]+) \(([0-9a-zA-Z]+)\)$/
        exemplar, correct = $1, $2
        categories = categories.split("  ").map { |x| x.split(" ")[0] }
        @results.push NamingResult.new(exemplar,correct,categories)
      end
    end
    
    # Get an array of scores (0..9)
    def scores
      scores = (0..9).map { |x| 0 }
      @results.each do |result|
        found = false
        scores.each_with_index do |s,i|
          found ||= result.correct == result.labels[i]
          scores[i] += 1 if found
        end
      end
      scores.map! { |x| x / @results.size.to_f }
      return scores
    end
    
    # Return the proportion labeled correctly in 1 try
    def value
      scores[0]
    end
  end
  
  # Represents a typicality (correlation) file. 
  class TypicalityData
    # The file represented by this object
    attr_reader :filename
    # The correlation coefficient computed by +regress+
    attr_reader :correlation
    # The number of items (lines) used to compute the #correlation
    attr_reader :count
    # The Regress object used to compute the correlation (contains additional statistics)
    attr_reader :regress
    
    # Parse a Typicality report.
    # 
    # [filename] A file consist of two columns of tab-delimited numbers,
    #            corresponding to generation frequency and category similarity
    def initialize(filename)
      @filename = filename
      data = `cat #{filename}`.split("\n").map { |line| line.strip.split("\t").map { |i| i.to_f } }.reject { |pair| pair[1] == 0.0 }
      @regress = Regress.new(data)
      @correlation = @regress.r
      @count = @regress.num_cases
#      @correlation = `cat #{filename} | ruby hacks/filter_typicality.rb | regress`.split("\n").pop.split(" ").shift
#      @count = `cat #{filename} | wc -l`.strip.to_i
    end
    
    # Alias for correlation
    alias value correlation
  end
  
  # Represents an exemplar generation report
  #
  # File should consist of n-lines, one per category, with each line formatted
  # as:
  # category: exemplar1, exemplar2, ...
  #
  # Categories should not appear multiple times.
  class GenerationData
    # The file represented by the object
    attr_reader :filename
    # A hash mapping category labels to an array of exemplars
    attr_reader :categories
    # The average overlap between the generated exemplars and the Oracle.
    attr_reader :average
    
    # Load a Generation.rb report and compute the average overlap between
    # the generated exemplars and those of the Oracle.
    def initialize(filename)
      oracle = Oracle.raw

      @filename = filename
      @categories = {}
      empty = []
      IO.foreach(filename) do |line|
        label,exemplars = *line.strip.split(": ")
        exemplars = exemplars.nil? ? [] : exemplars.split(", ")
        @categories[label] = exemplars if not exemplars.size == 0
        empty.push label if exemplars.nil? or exemplars.size <= 1
      end
      
#      raise "No exemplars generated for #{empty.join(', ')}" if empty.size > 1

      @overlaps = {}
      @categories.each_pair do |category,exemplars|
        best = oracle[category].map { |x| x }.sort { |a,b| b[1] <=> a[1] }[0..20].map { |x| x[0] }
        @overlaps[category] = best.reject { |x| not exemplars.include?(x) }
      end
      
      @average = @overlaps.values.inject(0) { |s,x| s += x.size } / @overlaps.size.to_f
    end
    
    # How many categories were predicted?
    def size
      return @categories.size
    end
    
    # Alias for average
    alias value average
  end
end
