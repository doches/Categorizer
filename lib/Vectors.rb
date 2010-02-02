# Contains several abstractions for dealing with particular types of vectors.
module Vector
  # Basic abstract vector class, replicating minimal array functionality
  class Vector
    @size = 0
    
    # Get value at +index+
    def [](index)
      @values[index]
    end
    
    # Store +value+ at +index+
    def []=(index,value)
      @values[index] = value
      if index >= @size
        @size = index+1
      end
    end
  end
  
  # A sparse vector in which most entries are 0
  class SparseVector < Vector
    # Get the size of this (real, not sparse) vector
    attr_accessor :size
    # Access raw value map
    attr_reader :values
    # THe default value for non-specified elements. Defaults to 0.0
    attr_accessor :default
    
    # Create a new SparseVector. Pass in a string of index-value pairs to preset some values, and a size to pad out with zero values.
    def initialize(string=nil,size=0)
      @default = 0.0
      if string.nil?
        @values = {}
        @size = 0
      else
        elements = string.split(" ") 
        raise ArgumentError.new("SparseVector.new expects a string of index-value pairs") if not elements.size % 2 == 0
        @values = {}
        last_index = nil
        last_used_index = 0
        elements.each do |value|
          if last_index.nil?
            last_index = value.to_i
          else
            @values[last_index] = value.to_f
            last_used_index = last_index
            last_index = nil
          end
        end
        if last_used_index > size
          @size = last_used_index
        else
          @size = size
        end
      end
    end
    
    # Iterate over entries (including zeroes)
    def each(&blk)
      (0..@size-1).each { |i| blk.call(self.[](i)) }
    end
    
    # Iterate over entries (including zeroes) with indices
    def each_with_index(&blk)
      (0..@size-1).each { |i| blk.call(self.[](i),i) }
    end
    
    # Replicate Array#join
    def join(tween)
      str = ""
      array = []
      self.each { |v| array.push v }
      return array.join(tween)
    end
    
    # Get value at +index+
    def [](index)
      if @values.include?(index)
        return @values[index]
      else
        return @default
      end
    end
    
    # Convert this SparseVector to an Array
    def to_array
      array = []
      self.each { |x| array.push x }
      return array
    end
  end
  
  # A file containing vectors
  class VectorFile
    # Load vectors from +filename+
    def initialize(filename)
      @file = IO.readlines(filename)
    end
    
    # Iterate over item-vector pairs
    def each_pair(&blk)
      @data.each_pair do |label,vector|
        blk.call(label,vector)
      end
    end
    
    def [](label)
      @data[label]
    end
    
    def vector(label)
      @data[label]
    end
    
    def entry(label,index)
      @data[label][index]
    end
    
    def keys
      @data.keys
    end
    
    def values
      @data.values
    end
    
    def size
      @data.size
    end
  end
  
  class DenseVectorFile < VectorFile
    def initialize(filename)
      super
      
      rows = @file.map { |line| line.split(" ",2) }
      @data = {}
      rows.each do |pair|
        @data[pair[0]] = pair[1].split(" ").map { |x| x.to_f }
      end
      @size = data.values[0].size
    end
  end
  
  class SparseVectorFile < VectorFile
    attr_reader :data
    
    def initialize(filename)
      super
      @size = @file.shift.to_i
      rows = @file.map { |line| line.split(" ",2) }
      @data = {}
      rows.each do |pair|
        @data[pair[0]] = SparseVector.new(pair[1],@size)
      end
    end
  end
  
  class TriangularVectorFile < VectorFile
    def initialize(filename)
      super
      
      @data = []
      @keys = []
      @file.map { |line| line.split(" ",2) }.each do |label,vector|
        @data.push vector.split(" ").map { |x| x.to_f }
        @keys.push label
      end
    end
    
    def vector(label)
      return @data[@keys.index(label)]
    end
    
    def distance(w1,w2)
      i1 = @keys.index(w1)
      i2 = @keys.index(w2)
      i1,i2 = i2,i1 if i2 < i1
      return @data[i1][i2-i1]
    end
  end
end
