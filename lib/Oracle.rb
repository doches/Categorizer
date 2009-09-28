require 'lib/Exemplar'

class Oracle
  @@yaml = nil
  
  def Oracle.init
    @@yaml = YAML.load_file("data/categories.yaml") if not @@yaml
  end
  
  def Oracle.raw
    Oracle.init
    @@yaml
  end
    
  def Oracle.exemplars  
    Oracle.init
    exemplars = []
    @@yaml.each_pair do |category,list|
      list.each_pair do |word,freq|
        exemplars.push Exemplar.new(word,category,freq)
      end
    end
    return exemplars
  end
  
  def Oracle.categories
    Oracle.init
    return @@yaml.keys
  end
end
