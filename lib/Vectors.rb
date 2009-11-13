module Vector
  class Vector
    def []=(index,value)
      @values[index] = value
    end
  end
  
  class SparseVector < Vector
    def initialize(string)
      elements = string.split(" ") 
      raise ArgumentError.new("SparseVector.new expects a string of index-value pairs") if not elements.size % 2 == 0
      @values = {}
      last_index = nil
      elements.each do |value|
        if last_index.nil?
          last_index = value.to_i
        else
          @values[last_index] = value.to_f
          last_index = nil
        end
      end
    end
    
    def [](index)
      if @values.include?(index)
        return @values[index]
      else
        return 0.0
      end
    end
  end
  
  class VectorFile
    def initialize(filename)
      @file = IO.readlines(filename)
    end
  end
  
  class SparseVectorFile < VectorFile
    attr_reader :data
    
    def initialize(filename)
      super
      
      rows = @file.map { |line| line.split(" ",2) }
      @data = {}
      rows.each do |pair|
        @data[pair[0]] = SparseVector.new(pair[1])
      end
    end
    
    def each_pair(&blk)
      @data.each_pair do |label,vector|
        blk.call(label,vector)
      end
    end
  end
end
