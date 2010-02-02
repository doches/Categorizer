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
  @@mcrae = nil
  
  @@mturk_file = "categories.yaml"
  
  # Change what data source the oracle uses for mturk words
  def Oracle.data=(filename)
    @@mturk_file = filename
  end
  
  # Load +data/categories.yaml+ if we haven't done so already.
  def Oracle.init
    @@yaml = YAML.load_file("data/#{@@mturk_file}") if not @@yaml
  end
  
  def Oracle.init_mcrae
    @@mcrae = YAML.load_file("data/mcrae_categories.yaml") if not @@mcrae
  end
  
  # Get raw hashmap for mcrae categories
  def Oracle.mcrae_raw
    Oracle.init_mcrae
    @@mcrae
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
        if freq.is_a?(Array)
          exemplars.push Exemplar.new(word,category,freq[0],freq[1])
        else
          exemplars.push Exemplar.new(word,category,freq)
        end
      end
    end
    return exemplars
  end
  
  def Oracle.mcrae_exemplars
    Oracle.init_mcrae
    exemplars = []
    @@mcrae.each_pair do |category,list|
      list.each_pair do |word,typ|
        exemplars.push Exemplar.new(word,category,0,typ)
      end
    end
    return exemplars
  end
  
  # Get a list of category labels
  def Oracle.categories
    Oracle.init
    return @@yaml.keys
  end
  
  def Oracle.mcrae_categories
    Oracle.init_mcrae
    return @@mcrae.keys
  end
end
