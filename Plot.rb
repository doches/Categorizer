require 'lib/Graph'
require 'lib/Report'

# Draws a plot of the specified model results. 
#
# Usage: Ruby Plot.rb -t <gen|typ|nam> -r <regex> -o <prefix>
regex = Regexp.compile(ARGV[ARGV.index("-r")+1])
task = ARGV[ARGV.index("-t")+1].downcase
prefix = ARGV[ARGV.index("-o")+1]

files = []
Dir.foreach("results/#{task}/") do |file|
  files.push File.join("results/#{task}",file) if file.gsub(".result","") =~ regex
end

paths = []
workdir = Dir.getwd
STDERR.puts "Plotting #{files.map { |x| x.split("/").pop }.join(", ")} into #{prefix}..."
graph = nil
case task
  when "naming"
    graph = Graph::NamingBarPlot.new(files,prefix)
  when "generation"
    graph = Graph::GenerationPlot.new(files,prefix)
  when "typicality"
    graph = Graph::TypicalityPlot.new(files,prefix)
  else
    raise "Unrecognized task \"#{task}\" -- should be one of \"nam\",\"gen\",\"typ\""
end
paths.push graph.render
Dir.chdir(workdir)

if ARGV.include?("-v")
  `evince #{paths[0]}`
end
