require 'lib/Graph'
require 'lib/Report'

cats = {}

Dir.foreach("results/typicality/") do |file|
  if file =~ /(Lsa|Lda|Depspace|Mcrae)(Cluster3|Cluto|Autoclass|Baseline|Label|Cw)([^\.]*)Cosine\.report$/
    if `cat results/typicality/#{file} | wc -l`.strip.to_i > 0
      cats[$2] ||= []
      cats[$2].push "results/typicality/"+file
    end
  end
end

dir = Dir.getwd

if ARGV.include?("--all")
  cats = {"All" => cats.values.flatten}
end

cats.each_pair do |method,files|
  STDERR.puts "Plotting #{files.map { |x| x.split("/").pop }.join(", ")} into #{method}..."
  graph = Graph::TypicalityPlot.new(files,method)
  graph.render
  Dir.chdir(dir)
end
