require 'lib/Exemplar'

# Abstracts the oracle data in +data/categories.yaml+. This class is mainly used
# for evaluation (when we want to compare the performance of a model against our
# human participants) or for training a supervised or semi-supervised model. As
# all of my models are currently at least semi-supervised, this gets used a lot...
#
# You don't instantiate an Oracle -- instead, use the class
# methods to access whatever piece of data you need. The actual loading of data
# is handled internally by a singleton object, so multiple, independent references
# to oracle data only require a single loading of the file.
class Oracle
  @@yaml = nil
  
  # Load +data/categories.yaml+ if we haven't done so already.
  def Oracle.init
    @@yaml = YAML.load_file("data/categories.yaml") if not @@yaml
  end
  
  # Get a hashmap of category labels => exemplar lists (Arrays)
  def Oracle.raw
    Oracle.init
    @@yaml
  end
   
  # Get a list of all exemplars
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
  
  # Get a list of category labels
  def Oracle.categories
    Oracle.init
    return @@yaml.keys
  end
end
