require 'lib/Graph'
require 'lib/Report'

cats = {}

cosine = ARGV.include?("--cosine") ? "Cosine" : ""

if not ARGV.include?("--r")
  Dir.foreach("results/naming/") do |file|
    if file =~ /(Lsa|Lda|Depspace|Mcrae|McraeLsa|McraeLda|McraeDepspace)(Cluster3|Cluto|Autoclass|Baseline|Label|Cw)#{cosine}\.report$/
      if `cat results/naming/#{file} | wc -l`.strip.to_i > 0
        cats[$2] ||= []
        cats[$2].push "results/naming/"+file
      end
    end
  end
else # find models based on regex
  regex = Regexp.compile(ARGV[ARGV.index("--r")+1])
  cats["Regex"] = []
  Dir.foreach("results/naming/") do |file|
    cats["Regex"].push File.join("results/naming",file) if file.gsub(".result","") =~ regex
  end
end

if ARGV.include?("--all")
  cats = {"All" => cats.values.flatten}
end  

paths = []
workdir = Dir.getwd
cats.each_pair do |method,files|
  STDERR.puts "Plotting #{files.map { |x| x.split("/").pop }.join(", ")} into #{method}..."
  graph = Graph::NamingBarPlot.new(files,method)
  paths.push graph.render
  Dir.chdir(workdir)
end

if paths.size > 1
  puts paths.join("\n")
elsif ARGV.include?("-v")
  `evince #{paths[0]}`
end
