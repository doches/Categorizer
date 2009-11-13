module Vector
  class Vector
    def []=(index,value)
      @values[index] = value
    end
  end
  
  class SparseVector < Vector
    attr_reader :size
    
    def initialize(string,size)
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
      @size = size
    end
    
    def each(&blk)
      (0..@size-1).each { |i| blk.call(self.[](i)) }
    end
    
    def each_with_index(&blk)
      (0..@size-1).each { |i| blk.call(self.[](i),i) }
    end
    
    def join(tween)
      str = ""
      array = []
      self.each { |v| array.push v }
      return array.join(tween)
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
      @size = @file.shift.to_i
      rows = @file.map { |line| line.split(" ",2) }
      @data = {}
      rows.each do |pair|
        @data[pair[0]] = SparseVector.new(pair[1],@size)
      end
    end
    
    def each_pair(&blk)
      @data.each_pair do |label,vector|
        blk.call(label,vector)
      end
    end
  end
end
