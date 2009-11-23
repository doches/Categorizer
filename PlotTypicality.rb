require 'lib/Graph'
require 'lib/Report'

cats = {}

if not ARGV.include?("--r")
  Dir.foreach("results/typicality/") do |file|
    if file =~ /(Lsa|Lda|Depspace|Mcrae)(Cluster3|Cluto|Autoclass|Baseline|Label|Cw)([^\.]*)Cosine\.report$/
      if `cat results/typicality/#{file} | wc -l`.strip.to_i > 0
        cats[$2] ||= []
        cats[$2].push "results/typicality/"+file
      end
    end
  end
else # find models based on regex
  regex = Regexp.compile(ARGV[ARGV.index("--r")+1])
  cats["Regex"] = []
  Dir.foreach("results/typicality/") do |file|
    cats["Regex"].push File.join("results/typicality",file) if file.gsub(".result","") =~ regex
  end
end


dir = Dir.getwd

if ARGV.include?("--all")
  cats = {"All" => cats.values.flatten}
end

paths = []
cats.each_pair do |method,files|
  STDERR.puts "Plotting #{files.map { |x| x.split("/").pop }.join(", ")} into #{method}..."
  graph = Graph::TypicalityPlot.new(files,method)
  paths.push graph.render
  Dir.chdir(dir)
end

if paths.size > 1
  puts paths.join("\n")
elsif ARGV.include?("-v")
  `evince #{paths[0]}`
end
