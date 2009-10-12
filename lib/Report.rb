require 'lib/Oracle'

# The Report module provides wrapper objects that handle parsing the 
# reports produced by Naming.rb, Typicality.rb, and Generation.rb.
# Right now these are only used by the classes in the Graph module.
module Report
  # Represents one result (e.g. line) from a Naming report
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
  # 
  # File should consist of two columns of tab-delimited numbers,
  # corresponding to generation frequency and category similarity
  class TypicalityData
    attr_reader :filename, :correlation, :count
    def initialize(filename)
      @filename = filename
      @correlation = `cat #{filename} | ruby hacks/filter_typicality.rb | regress`.split("\n").pop.split(" ").shift
      @count = `cat #{filename} | wc -l`.strip.to_i
    end
    
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
    attr_reader :filename, :categories, :average
    
    def initialize(filename)
      oracle = Oracle.raw

      @filename = filename
      @categories = {}
      empty = []
      IO.foreach(filename) do |line|
        label,exemplars = *line.strip.split(": ")
        exemplars = exemplars.split(", ")
        @categories[label] = exemplars
        empty.push label if exemplars.nil? or exemplars.size <= 1
      end
      raise "No exemplars generated for #{empty.join(', ')}" if empty.size > 1

      @overlaps = {}
      @categories.each_pair do |category,exemplars|
        best = oracle[category].map { |x| x }.sort { |a,b| b[1] <=> a[1] }[0..20].map { |x| x[0] }
        @overlaps[category] = best.reject { |x| not exemplars.include?(x) }
      end
      
      @average = @overlaps.values.inject(0) { |s,x| s += x.size } / @overlaps.size.to_f
    end
    
    def size
      return @categories.size
    end
    
    alias value average
  end
end
