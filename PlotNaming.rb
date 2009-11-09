require 'lib/Graph'
require 'lib/Report'

cats = {}

Dir.foreach("results/naming/") do |file|
  if file =~ /(Lsa|Lda|Depspace|Mcrae)(Cluster3|Cluto|Autoclass|Baseline|Label|Cw)Cosine\.report$/
    if `cat results/naming/#{file} | wc -l`.strip.to_i > 0
      cats[$2] ||= []
      cats[$2].push "results/naming/"+file
    end
  end
end

if ARGV.include?("--all")
  cats = {"All" => cats.values.flatten}
end  

workdir = Dir.getwd
cats.each_pair do |method,files|
  STDERR.puts "Plotting #{files.map { |x| x.split("/").pop }.join(", ")} into #{method}..."
  graph = Graph::NamingBarPlot.new(files,method)
  graph.render
  Dir.chdir(workdir)
end
