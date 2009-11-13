require 'lib/Vectors'

class Mcrae
  def initialize
    @data = Vector::SparseVectorFile.new("/home/s0897549/Categorizer/data/mcrae/mcrae_sparse.vectors").data
  end
  
  def each_pair(&blk)
    @data.each_pair do |key,value|
      blk.call(key,value)
    end
  end
end
