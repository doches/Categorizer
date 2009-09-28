require 'lib/Graph'
require 'lib/Report'

cats = {}

Dir.foreach("results/generation/") do |file|
  if file =~ /(Lsa|Lda)(Cluster3|Cluto|Autoclass|Baseline|Label|Cw)([^\.]*)\.report$/
    if `cat results/generation/#{file} | wc -l`.strip.to_i > 0
      cats[$2] ||= []
      cats[$2].push "results/generation/"+file
    end
  end
end

dir = Dir.getwd

if ARGV.include?("--all")
  cats = {"All" => cats.values.flatten}
end

cats.each_pair do |method,files|
  STDERR.puts "Plotting #{files.map { |x| x.split("/").pop }.join(", ")} into #{method}..."
  graph = Graph::GenerationPlot.new(files,method)
  graph.render
  Dir.chdir(dir)
end
