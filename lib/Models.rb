require 'lib/String'

# Dynamically load anything that _might_ be a subclass of Model in the +lib/+ directory. Any file
# that ends in "Model.rb" is loaded (which catches some useless stuff like LsaModel, but also gets
# everything it should.
Dir.foreach("lib") { |file| require "lib/#{file}" if file =~ /Model\.rb$/ }

# Helper class to create a specific model from a symbolic identifier.
class Models
  # Load a model dynamically based on a symbol. Models.load(sym) will return an instance
  # of the model specified by sym, as specified in the following scheme.
  #
  # [sym] A symbol of the form :<space>_<model>_<submodel>. The components 
  #       of the symbol are transformed into a intercapped class name with "Model" appended, so
  #       +:lsa_cluto_rb+ becomes LsaClutoRbModel
  def Models.load(sym)
    return eval("#{Models.sym_to_class(sym)}Model.new")
  end
  
  # Shortcut for producing a model-specific filename used for reporting. 
  # [sym] A symbol of the same form as used in #Models.load.
  #
  #       For example, the symbol :lsa_cluto_rb will return the filename
  #       "LsaClutoRbModel.report"
  def Models.output_path(sym)
    return Models.sym_to_class(sym)+".report"
  end
  
  # Used internally to transform symbolic names (i.e. +:lsa_cluto_rb+) into intercapped model class names (i.e. LsaClutoRbModel). Returns a string of the class name.
  def Models.sym_to_class(sym)
    return sym.to_s.gsub(":","").split("_").map { |x| x.capitalize }.join("")
  end
  
  # Generate a graph-friendly name for this model. If +use_space_label+ is true, returns the
  # space of the class; otherwise, returns a descriptive moniker for the clustering model used.
  def Models.class_to_label(class_name,use_space_label=false)
    label = class_name
    pieces = class_name.split_intercapped
    if pieces[0] == "Mcrae" # Discard 'mcrae' indicator
      pieces.shift
    end
    
    space = pieces.shift
    return space if use_space_label
    
    model = pieces.shift
    case model
      when "Cluto"
        submodel = pieces.shift
        case submodel
          when "Rb"
            label = "Top-Down"
          when "Rbr"
            label = "Top-Down"
          when "Graph"
            label = "Graph"
          when "Agglo"
            label = "Bottom-Up"
          when "Bagglo"
            label = "Bottom-Up"
          when "Direct"
            label = "K-Means"
        end
      when "Baseline"
        label = "Oracle"
      when "Cw"
        label = "Graph-Non"
      when "Autoclass"
        label = "Bayesian"
    end
    
#    label = "\"#{label}\"" if label.include?(" ")
    return label
  end
end
