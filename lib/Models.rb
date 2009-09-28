Dir.foreach("lib") { |file| require "lib/#{file}" if file =~ /Model\.rb$/ }

class Models
  def Models.load(sym)
    return eval("#{Models.sym_to_class(sym)}Model.new")
  end
  
  def Models.output_path(sym)
    return Models.sym_to_class(sym)+".report"
  end
  
  def Models.sym_to_class(sym)
    return sym.to_s.gsub(":","").split("_").map { |x| x.capitalize }.join("")
  end
end
